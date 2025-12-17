import { NextResponse } from "next/server";
import { db } from "@/lib/db";
import nodemailer from "nodemailer";

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

    // Send registration email directly (non-blocking)
    let emailSent = false;
    try {
      console.log(`🔄 Attempting to send registration email to ${finalEmail}`);
      console.log(`�  Student ID: ${studentId}`);
      console.log(`📧 SMTP_USER: ${process.env.SMTP_USER ? 'Set' : 'NOT SET'}`);
      console.log(`📧 SMTP_PASS: ${process.env.SMTP_PASS ? 'Set (length: ' + process.env.SMTP_PASS.length + ')' : 'NOT SET'}`);
      
      // Check if email is configured
      if (process.env.SMTP_USER && process.env.SMTP_PASS) {
        // Create transporter
        const transporter = nodemailer.createTransport({
          service: 'gmail',
          host: 'smtp.gmail.com',
          port: 587,
          secure: false,
          auth: {
            user: process.env.SMTP_USER,
            pass: process.env.SMTP_PASS,
          },
        });

        // Generate QR code data
        const qrData = {
          student_id: studentId,
          full_name: full_name,
          class: studentClass,
          phone: phone,
          timestamp: Date.now()
        };
        
        console.log(`📧 Generated QR data:`, JSON.stringify(qrData));

        // Create email content
        const emailHtml = `
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <div style="background: linear-gradient(135deg, #8B0000, #B22222); padding: 20px; text-align: center;">
              <h1 style="color: white; margin: 0;">MK Attendance System</h1>
              <p style="color: white; margin: 5px 0;">Student Registration Confirmation</p>
            </div>
            
            <div style="padding: 30px; background: #f9f9f9;">
              <h2 style="color: #333;">Welcome, ${full_name}!</h2>
              <p style="color: #666; font-size: 16px;">
                Congratulations! You have been successfully registered in the MK Attendance System.
              </p>
              
              <div style="background: white; padding: 20px; border-radius: 8px; margin: 20px 0;">
                <h3 style="color: #8B0000; margin-top: 0;">Your Registration Details:</h3>
                <table style="width: 100%; border-collapse: collapse;">
                  <tr>
                    <td style="padding: 8px 0; font-weight: bold; color: #333;">Student ID:</td>
                    <td style="padding: 8px 0; color: #666;">${studentId}</td>
                  </tr>
                  <tr>
                    <td style="padding: 8px 0; font-weight: bold; color: #333;">Full Name:</td>
                    <td style="padding: 8px 0; color: #666;">${full_name}</td>
                  </tr>
                  <tr>
                    <td style="padding: 8px 0; font-weight: bold; color: #333;">Class:</td>
                    <td style="padding: 8px 0; color: #666;">${studentClass}</td>
                  </tr>
                  <tr>
                    <td style="padding: 8px 0; font-weight: bold; color: #333;">Phone:</td>
                    <td style="padding: 8px 0; color: #666;">${phone}</td>
                  </tr>
                  <tr>
                    <td style="padding: 8px 0; font-weight: bold; color: #333;">Gender:</td>
                    <td style="padding: 8px 0; color: #666;">${finalGender}</td>
                  </tr>
                </table>
              </div>
              
              <div style="background: white; padding: 20px; border-radius: 8px; margin: 20px 0; text-align: center;">
                <h3 style="color: #8B0000; margin-top: 0;">Your Personal QR Code</h3>
                <div style="background: #f5f5f5; padding: 15px; border-radius: 5px; margin: 15px 0; font-family: monospace; word-break: break-all;">
                  ${JSON.stringify(qrData, null, 2)}
                </div>
                <p style="color: #666; font-size: 14px;">
                  <strong>How to use:</strong><br>
                  • Show this information to your coordinator for QR code generation<br>
                  • Your QR code will be used for attendance tracking<br>
                  • Keep this email safe for future reference
                </p>
              </div>
              
              <div style="background: #e8f4fd; padding: 15px; border-radius: 8px; border-left: 4px solid #2196F3;">
                <p style="margin: 0; color: #1976D2;">
                  <strong>Important:</strong> Your QR code is unique to you. 
                  It will be used for attendance tracking in your classes.
                </p>
              </div>
            </div>
            
            <div style="background: #333; padding: 20px; text-align: center;">
              <p style="color: #ccc; margin: 0; font-size: 14px;">
                © ${new Date().getFullYear()} MK Attendance System. All rights reserved.
              </p>
            </div>
          </div>
        `;

        // Send email
        await transporter.sendMail({
          from: `"MK Attendance System" <${process.env.SMTP_USER}>`,
          to: finalEmail,
          subject: "Welcome to MK Attendance System - Your QR Code",
          html: emailHtml,
        });

        emailSent = true;
        console.log(`✅ Registration email sent to ${finalEmail}`);
      } else {
        console.log(`⚠️ Email not configured - SMTP credentials missing`);
      }
    } catch (emailError) {
      console.log(`⚠️ Email failed but student created: ${emailError}`);
      console.error('Full email error:', emailError);
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
