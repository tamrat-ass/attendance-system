import { NextResponse } from "next/server";
import { db } from "@/lib/db";
import nodemailer from "nodemailer";
import crypto from "crypto";

// Generate secure token for QR code validation (matches mobile app)
function generateSecureToken(studentId: number, fullName: string, phone: string): string {
  const data = `${studentId}_${fullName}_${phone}_mk_attendance`;
  const hash = crypto.createHash('sha256').update(data).digest('hex');
  return hash.substring(0, 16); // Use first 16 characters
}

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

// CREATE STUDENT - Enhanced Duplicate Validation v2026010113
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

    // ✅ CHECK FOR DUPLICATE STUDENTS - Enhanced validation (v2026010113)
    console.log('🔍 Checking for duplicate student:', full_name.trim(), phone.trim());
    
    // Check for duplicate by name
    const [existingByName]: any = await db.query(
      "SELECT id, full_name, phone, class, gender, email FROM students WHERE full_name = ?",
      [full_name.trim()]
    );

    if (existingByName && existingByName.length > 0) {
      const existing = existingByName[0];
      console.log('❌ DUPLICATE NAME FOUND - Student with same name already exists:', existing.full_name, '(ID:', existing.id, ')');
      
      return NextResponse.json(
        { 
          message: `Student with name "${full_name}" already exists in the system`,
          error: "DUPLICATE_NAME",
          existingStudent: {
            id: existing.id,
            full_name: existing.full_name,
            phone: existing.phone,
            class: existing.class,
            gender: existing.gender,
            email: existing.email
          }
        },
        { status: 409 } // 409 Conflict status code for duplicates
      );
    }

    // Check for duplicate by phone number
    const [existingByPhone]: any = await db.query(
      "SELECT id, full_name, phone, class, gender, email FROM students WHERE phone = ?",
      [phone.trim()]
    );

    if (existingByPhone && existingByPhone.length > 0) {
      const existing = existingByPhone[0];
      console.log('❌ DUPLICATE PHONE FOUND - Student with same phone already exists:', existing.phone, '(Name:', existing.full_name, ')');
      
      return NextResponse.json(
        { 
          message: `Student with phone number "${phone}" already exists in the system`,
          error: "DUPLICATE_PHONE",
          existingStudent: {
            id: existing.id,
            full_name: existing.full_name,
            phone: existing.phone,
            class: existing.class,
            gender: existing.gender,
            email: existing.email
          }
        },
        { status: 409 } // 409 Conflict status code for duplicates
      );
    }

    console.log('✅ No duplicate found - proceeding with registration');

    // Use 'Male' as default if gender is empty
    const finalGender = gender && gender.trim() ? gender.trim() : 'Male';
    const finalEmail = email.trim(); // Email is required, no need for null check

    // Generate QR code data first (non-expiring - no timestamp)
    const tempQrData = {
      full_name: full_name,
      class: studentClass,
      phone: phone,
      gender: finalGender // Add gender to initial QR data too
    };
    
    // Insert student and get the ID
    const [result]: any = await db.query(
      "INSERT INTO students (full_name, phone, class, gender, email, qr_code) VALUES (?, ?, ?, ?, ?, ?)",
      [full_name, phone, studentClass, finalGender, finalEmail, JSON.stringify(tempQrData)]
    );

    let studentId = result.insertId;
    
    // Debug logging
    console.log(`📊 Database result:`, result);
    console.log(`📊 Student ID from insertId:`, studentId);
    
    // Fallback: if insertId is undefined, query for the student we just created
    if (!studentId) {
      console.log(`⚠️ insertId is undefined, querying for student...`);
      const [studentQuery]: any = await db.query(
        "SELECT id FROM students WHERE full_name = ? AND phone = ? ORDER BY id DESC LIMIT 1",
        [full_name, phone]
      );
      
      if (studentQuery && studentQuery.length > 0) {
        studentId = studentQuery[0].id;
        console.log(`✅ Found student ID via query: ${studentId}`);
      } else {
        // Last resort: use timestamp as ID
        studentId = Date.now();
        console.log(`⚠️ Using timestamp as fallback ID: ${studentId}`);
      }
    }
    
    console.log(`📊 Final student ID: ${studentId}`);

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

        // Generate complete QR code data matching mobile app format
        const qrData = {
          student_id: studentId,
          full_name: full_name,
          class: studentClass,
          phone: phone,
          gender: finalGender, // Add gender to QR code data
          timestamp: Date.now(),
          token: generateSecureToken(studentId, full_name, phone)
        };
        
        console.log(`📧 Generated QR data:`, JSON.stringify(qrData));
        
        // Generate QR code using API service (no package needed)
        let qrCodeImage = '';
        try {
          // Use QR Server API to generate QR code
          const qrText = JSON.stringify(qrData);
          const encodedText = encodeURIComponent(qrText);
          qrCodeImage = `https://api.qrserver.com/v1/create-qr-code/?size=200x200&color=000000&data=${encodedText}`;
          console.log(`📧 QR code URL generated: ${qrCodeImage}`);
        } catch (qrError: any) {
          console.log(`⚠️ QR code generation failed: ${qrError.message}`);
          // Continue without QR image - email will still work
        }
        
        // Update the student record with complete QR data including student_id
        try {
          await db.query(
            "UPDATE students SET qr_code = ? WHERE id = ?",
            [JSON.stringify(qrData), studentId]
          );
          console.log(`📧 QR code saved to database for student ${studentId}`);
        } catch (qrError) {
          console.error('Failed to save QR code to database:', qrError);
        }

        // Create email content
        const emailHtml = `
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <div style="background: linear-gradient(135deg, #8B0000, #B22222); padding: 15px; text-align: center;">
              <h1 style="color: white; margin: 0; font-size: 20px;">MK Attendance System</h1>
              <p style="color: white; margin: 3px 0; font-size: 12px;">Student Registration Confirmation</p>
            </div>
            
            <div style="padding: 30px; background: #f9f9f9;">
              <h2 style="color: #333; font-size: 18px;">Welcome, ${full_name}!</h2>
              <p style="color: #666; font-size: 13px;">
                Congratulations! You have been successfully registered in the MK Attendance System.
              </p>
              
              <div style="background: white; padding: 20px; border-radius: 8px; margin: 20px 0;">
                <h3 style="color: #8B0000; margin-top: 0;">Your Registration Details:</h3>
                <table style="width: 100%; border-collapse: collapse;">
                  <tr>
                    <td style="padding: 8px 0; font-weight: bold; color: #333;">Registration ID:</td>
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
                
                ${qrCodeImage ? `
                  <div style="background: white; padding: 25px; margin: 15px auto; text-align: center; border: 3px solid #8B0000; border-radius: 10px; max-width: 250px;">
                    <img src="${qrCodeImage}" alt="Your QR Code" style="width: 150px; height: 150px; display: block; margin: 0 auto;" />
                    <p style="color: #8B0000; font-weight: bold; margin: 15px 0 0 0; font-size: 14px;">Scan this QR code for attendance</p>
                  </div>
                ` : ''}
                
                <p style="color: #666; font-size: 14px;">
                  <strong>How to use:</strong><br>
                  • Show this QR code to your coordinator for attendance<br>
                  • Your QR code will be used for attendance tracking<br>
                  • Keep this email safe for future reference
                </p>
                
                <!-- YouTube Channel Promotion -->
                <div style="background: #ff0000; color: white; padding: 15px; border-radius: 8px; margin: 20px 0; text-align: center; border: 2px solid #ffffff;">
                  <p style="margin: 0; font-size: 16px; font-weight: bold;">📺 Follow us on YouTube!</p>
                  <a href="https://youtube.com/@-zemawetibebzmk7905" 
                     style="color: white; text-decoration: none; font-size: 14px; display: block; margin-top: 8px; background: #cc0000; padding: 8px; border-radius: 5px;">
                    🔔 ➤ Subscribe: youtube.com/@-zemawetibebzmk7905 ⬅
                  </a>
                  <p style="margin: 5px 0 0 0; font-size: 12px; background: #990000; padding: 5px; border-radius: 3px;">
                    ⭐ Don't miss our latest videos! ⭐
                  </p>
                </div>
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
        
        // Log successful email to database
        try {
          await db.query(
            "INSERT INTO email_logs (type, recipient, sender, content, status, student_id) VALUES (?, ?, ?, ?, ?, ?)",
            ['registration', finalEmail, process.env.SMTP_USER, 'Welcome to MK Attendance System - Your QR Code', 'success', studentId]
          );
          console.log(`📝 Email logged to database`);
        } catch (logError) {
          console.error('Failed to log email:', logError);
        }
      } else {
        console.log(`⚠️ Email not configured - SMTP credentials missing`);
      }
    } catch (emailError: any) {
      console.log(`⚠️ Email failed but student created: ${emailError}`);
      console.error('Full email error:', emailError);
      
      // Log failed email to database
      try {
        await db.query(
          "INSERT INTO email_logs (type, recipient, sender, content, status, error_message, student_id) VALUES (?, ?, ?, ?, ?, ?, ?)",
          ['registration', finalEmail, process.env.SMTP_USER || 'system', 'Welcome to MK Attendance System - Your QR Code', 'failed', emailError.message, studentId]
        );
        console.log(`📝 Failed email logged to database`);
      } catch (logError) {
        console.error('Failed to log email error:', logError);
      }
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
