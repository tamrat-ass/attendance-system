import { NextResponse } from "next/server";
import { db } from "@/lib/db";

// GET ALL STUDENTS with filters, search, pagination
export async function GET(req: Request) {
  try {
    const { searchParams } = new URL(req.url);

    const search = searchParams.get("search");
    const name = searchParams.get("name");
    const phone = searchParams.get("phone");
    const studentClass = searchParams.get("class");

    const page = Number(searchParams.get("page")) || 1;
    const limit = Number(searchParams.get("limit")) || 1000; // Increased from 20 to 1000
    const offset = (page - 1) * limit;

    // Build dynamic SQL
    let sql = "SELECT * FROM students";
    const conditions: string[] = [];
    const values: any[] = [];

    if (search) {
      const trimmedSearch = search.trim();
      
      // Smart Search Logic
      if (/^09\d{8}$/.test(trimmedSearch)) {
        // Phone number search (09xxxxxxxx - exact match)
        console.log('🔍 Smart Search: Phone number detected -', trimmedSearch);
        conditions.push("phone = ?");
        values.push(trimmedSearch);
      } else if (/^\d+$/.test(trimmedSearch)) {
        // Student ID search (digits only, not starting with 09)
        console.log('🔍 Smart Search: Student ID detected -', trimmedSearch);
        conditions.push("id = ?");
        values.push(parseInt(trimmedSearch));
      } else {
        // Name search (contains letters or mixed characters)
        console.log('🔍 Smart Search: Name search detected -', trimmedSearch);
        conditions.push("(full_name LIKE ? OR class LIKE ?)");
        values.push(`%${trimmedSearch}%`, `%${trimmedSearch}%`);
      }
    }

    if (name) {
      conditions.push("full_name LIKE ?");
      values.push(`%${name}%`);
    }

    if (phone) {
      conditions.push("phone LIKE ?");
      values.push(`%${phone}%`);
    }

    if (studentClass) {
      conditions.push("class = ?");
      values.push(studentClass);
    }

    if (conditions.length > 0) {
      sql += " WHERE " + conditions.join(" AND ");
    }

    sql += " ORDER BY id ASC LIMIT ? OFFSET ?";
    values.push(limit, offset);

    const [rows]: any = await db.query(sql, values);

    return NextResponse.json({
      message: "Students fetched successfully",
      page,
      limit,
      count: rows.length,
      data: rows,
    });
  } catch (error: any) {
    return NextResponse.json(
      { message: "Error fetching students", error: error.message },
      { status: 500 }
    );
  }
}

// CREATE STUDENT
export async function POST(req: Request) {
  try {
    const body = await req.json();
    const { full_name, phone, class: studentClass, gender, email } = body;

    if (!full_name || !phone || !studentClass || !email) {
      return NextResponse.json(
        { message: "Name, phone, class, and email are required" },
        { status: 400 }
      );
    }

    // Validate phone number format (exactly 10 digits starting with 09)
    if (!/^09\d{8}$/.test(phone)) {
      return NextResponse.json(
        { message: "Phone number must be exactly 10 digits and start with 09" },
        { status: 400 }
      );
    }

    // Validate email format - REQUIRED and must be @gmail.com
    if (!email || !email.trim()) {
      return NextResponse.json(
        { message: "Email address is required" },
        { status: 400 }
      );
    }
    
    if (!/^[\w-\.]+@gmail\.com$/.test(email.trim())) {
      return NextResponse.json(
        { message: "Please provide a valid @gmail.com email address" },
        { status: 400 }
      );
    }

    // Use 'Male' as default if gender is empty
    const finalGender = gender && gender.trim() ? gender.trim() : 'Male';
    const finalEmail = email.trim(); // Email is required, no need for null check

    // Insert student and get the ID
    const [result]: any = await db.query(
      "INSERT INTO students (full_name, phone, class, gender, email) VALUES (?, ?, ?, ?, ?)",
      [full_name, phone, studentClass, finalGender, finalEmail]
    );

    const studentId = result.insertId;

    // Try to send registration email (non-blocking)
    let emailSent = false;
    try {
      const emailResponse = await fetch(`${process.env.NEXT_PUBLIC_BASE_URL || 'https://mk-attendance.vercel.app'}/api/notifications/registration`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          student_id: studentId,
          full_name,
          email: finalEmail,
          phone,
          class: studentClass,
          gender: finalGender,
        }),
      });
      
      if (emailResponse.ok) {
        emailSent = true;
        console.log(`✅ Registration email sent to ${finalEmail}`);
      }
    } catch (emailError) {
      console.log(`⚠️ Email failed but student created: ${emailError}`);
    }

    return NextResponse.json({ 
      message: "Student created successfully" + (emailSent ? " and registration email sent!" : ""),
      student_id: studentId,
      email_sent: emailSent
    });
  } catch (error: any) {
    return NextResponse.json(
      { message: "Error creating student", error: error.message },
      { status: 500 }
    );
  }
}
