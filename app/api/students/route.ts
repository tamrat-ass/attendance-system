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
      conditions.push("(full_name LIKE ? OR phone LIKE ? OR class LIKE ?)");
      values.push(`%${search}%`, `%${search}%`, `%${search}%`);
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
    const { full_name, phone, class: studentClass, gender } = body;

    if (!full_name || !phone || !studentClass || !gender) {
      return NextResponse.json(
        { message: "Missing required fields" },
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

    await db.query(
      "INSERT INTO students (full_name, phone, class, gender) VALUES (?, ?, ?, ?)",
      [full_name, phone, studentClass, gender]
    );

    return NextResponse.json({ message: "Student created successfully" });
  } catch (error: any) {
    return NextResponse.json(
      { message: "Error creating student", error: error.message },
      { status: 500 }
    );
  }
}
