import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/db';
import nodemailer from 'nodemailer';
import crypto from 'crypto';

// Generate secure token for QR code validation (matches mobile app)
function generateSecureToken(studentId: number, fullName: string, phone: string): string {
  const data = `${studentId}_${fullName}_${phone}_mk_attendance`;
  const hash = crypto.createHash('sha256').update(data).digest('hex');
  return hash.substring(0, 16); // Use first 16 characters
}

// Email configuration
const EMAIL_CONFIG = {
  service: 'gmail',
  host: 'smtp.gmail.com',
  port: 587,
  secure: false,
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS,
  },
};

// Create transporter
let transporter: any = null;
try {
  if (process.env.SMTP_USER && process.env.SMTP_PASS) {
    transporter = nodemailer.createTransport(EMAIL_CONFIG);
  }
} catch (error) {
  console.error('Failed to create email transporter:', error);
}

// Generate QR code and email content for a student
async function generateQRAndEmail(student: any, studentId: number) {
  // Generate complete QR code data matching mobile app format
  const qrData = {
    student_id: studentId,
    full_name: student.full_name,
    class: student.class,
    phone: student.phone,
    timestamp: Date.now(),
    token: generateSecureToken(studentId, student.full_name, student.phone)
  };
  
  // Generate QR code using API service
  const qrText = JSON.stringify(qrData);
  const encodedText = encodeURIComponent(qrText);
  const qrCodeImage = `https://api.qrserver.com/v1/create-qr-code/?size=200x200&color=000000&data=${encodedText}`;
  
  // Create email content
  const emailHtml = `
    <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
      <div style="background: linear-gradient(135deg, #8B0000, #B22222); padding: 15px; text-align: center;">
        <h1 style="color: white; margin: 0; font-size: 20px;">MK Attendance System</h1>
        <p style="color: white; margin: 3px 0; font-size: 12px;">Student Registration Confirmation</p>
      </div>
      
      <div style="padding: 30px; background: #f9f9f9;">
        <h2 style="color: #333; font-size: 18px;">Welcome, ${student.full_name}!</h2>
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
              <td style="padding: 8px 0; color: #666;">${student.full_name}</td>
            </tr>
            <tr>
              <td style="padding: 8px 0; font-weight: bold; color: #333;">Class:</td>
              <td style="padding: 8px 0; color: #666;">${student.class}</td>
            </tr>
            <tr>
              <td style="padding: 8px 0; font-weight: bold; color: #333;">Phone:</td>
              <td style="padding: 8px 0; color: #666;">${student.phone}</td>
            </tr>
            <tr>
              <td style="padding: 8px 0; font-weight: bold; color: #333;">Gender:</td>
              <td style="padding: 8px 0; color: #666;">${student.gender}</td>
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
  
  return { qrData, qrCodeImage, emailHtml };
}

// Send email to a student
async function sendRegistrationEmail(student: any, studentId: number, emailHtml: string) {
  if (!transporter || !student.email) {
    return { success: false, error: 'Email not configured or no email address' };
  }
  
  try {
    await transporter.sendMail({
      from: `"MK Attendance System" <${process.env.SMTP_USER}>`,
      to: student.email,
      subject: "Welcome to MK Attendance System - Your QR Code",
      html: emailHtml,
    });
    
    // Log successful email to database
    try {
      await db.query(
        "INSERT INTO email_logs (type, recipient, sender, content, status, student_id) VALUES (?, ?, ?, ?, ?, ?)",
        ['bulk', student.email, process.env.SMTP_USER, 'Welcome to MK Attendance System - Your QR Code', 'success', studentId]
      );
    } catch (logError) {
      console.error('Failed to log email:', logError);
    }
    
    return { success: true };
  } catch (error: any) {
    // Log failed email to database
    try {
      await db.query(
        "INSERT INTO email_logs (type, recipient, sender, content, status, error_message, student_id) VALUES (?, ?, ?, ?, ?, ?, ?)",
        ['bulk', student.email, process.env.SMTP_USER || 'system', 'Welcome to MK Attendance System - Your QR Code', 'failed', error.message, studentId]
      );
    } catch (logError) {
      console.error('Failed to log email error:', logError);
    }
    
    return { success: false, error: error.message };
  }
}

export async function POST(request: NextRequest) {
  try {
    const { students } = await request.json();

    console.log('=== BULK UPLOAD WITH EMAIL START ===');
    console.log('Number of students to upload:', students?.length);

    if (!students || !Array.isArray(students) || students.length === 0) {
      return NextResponse.json(
        { success: false, message: 'Invalid student data' },
        { status: 400 }
      );
    }

    // Comprehensive validation of all students
    const validationErrors: string[] = [];
    
    for (let i = 0; i < students.length; i++) {
      const student = students[i];
      const rowNum = i + 1;
      
      // Check required fields
      if (!student.full_name || student.full_name.trim() === '') {
        validationErrors.push(`Row ${rowNum}: Missing full name`);
      }
      if (!student.phone || student.phone.trim() === '') {
        validationErrors.push(`Row ${rowNum}: Missing phone number`);
      }
      if (!student.class || student.class.trim() === '') {
        validationErrors.push(`Row ${rowNum}: Missing class`);
      }
      if (!student.email || student.email.trim() === '') {
        validationErrors.push(`Row ${rowNum}: Missing email address`);
      }
      
      // Validate phone number format (exactly 10 digits starting with 09)
      if (student.phone && !/^09\d{8}$/.test(student.phone.trim())) {
        validationErrors.push(`Row ${rowNum}: Invalid phone "${student.phone}" (must be 09xxxxxxxx)`);
      }
      
      // Validate email format - must be @gmail.com
      if (student.email && !/^[\w-\.]+@gmail\.com$/.test(student.email.trim())) {
        validationErrors.push(`Row ${rowNum}: Invalid email "${student.email}" (must be @gmail.com)`);
      }
      
      // Validate gender (allow flexible input)
      if (student.gender && !['Male', 'Female', 'male', 'female', 'M', 'F', 'm', 'f'].includes(student.gender)) {
        validationErrors.push(`Row ${rowNum}: Invalid gender "${student.gender}" (must be Male or Female)`);
      }
      
      // Validate name length
      if (student.full_name && student.full_name.trim().length < 2) {
        validationErrors.push(`Row ${rowNum}: Full name too short (minimum 2 characters)`);
      }
      
      // Validate class name
      if (student.class && student.class.trim().length < 1) {
        validationErrors.push(`Row ${rowNum}: Class name too short`);
      }
    }
    
    // Return validation errors if any
    if (validationErrors.length > 0) {
      const errorMessage = `Validation failed for ${validationErrors.length} row(s):\n\n${validationErrors.slice(0, 10).join('\n')}${validationErrors.length > 10 ? `\n... and ${validationErrors.length - 10} more errors` : ''}`;
      
      return NextResponse.json(
        { 
          success: false, 
          message: errorMessage,
          errors: validationErrors,
          errorCount: validationErrors.length
        },
        { status: 400 }
      );
    }

    try {
      // Check existing students count BEFORE upload
      const [beforeCount]: any = await db.query('SELECT COUNT(*) as count FROM students');
      console.log('Students in database BEFORE upload:', beforeCount[0].count);

      // Get all existing students to check for duplicates
      const [existingStudents]: any = await db.query(
        'SELECT full_name, phone, email FROM students'
      );

      console.log('Total existing students in database:', existingStudents.length);

      // Create a Set of existing student identifiers (name + phone combination)
      const existingSet = new Set(
        existingStudents.map((s: any) => `${s.full_name.toLowerCase().trim()}|${s.phone.trim()}`)
      );

      const insertedStudents = [];
      const skippedStudents = [];
      const emailResults = [];
      
      for (const student of students) {
        const identifier = `${student.full_name.toLowerCase().trim()}|${student.phone.trim()}`;
        
        console.log('Checking student:', student.full_name, '| Identifier:', identifier);
        
        // Check if student already exists
        if (existingSet.has(identifier)) {
          console.log('✗ SKIPPING duplicate student:', student.full_name, student.phone);
          skippedStudents.push({
            ...student,
            reason: 'Duplicate (same name and phone already exists)'
          });
          continue;
        }

        console.log('✓ INSERTING new student:', student.full_name);
        
        // Normalize gender value - read from student data
        let normalizedGender = 'Male'; // Default fallback
        if (student.gender) {
          const genderLower = student.gender.toLowerCase().trim();
          // Check for female variations
          if (genderLower === 'female' || genderLower === 'f' || genderLower.startsWith('fem')) {
            normalizedGender = 'Female';
          }
          // Check for male variations
          else if (genderLower === 'male' || genderLower === 'm' || genderLower.startsWith('mal')) {
            normalizedGender = 'Male';
          }
        }
        
        // Ensure email is provided and valid
        const finalEmail = student.email.trim();
        
        try {
          // Insert student with email
          const [result] = await db.execute(
            'INSERT INTO students (full_name, phone, gender, class, email, qr_code) VALUES (?, ?, ?, ?, ?, ?)',
            [student.full_name.trim(), student.phone.trim(), normalizedGender, student.class.trim(), finalEmail, '{}']
          );
          
          let studentId = (result as any).insertId;
          
          // Debug logging
          console.log(`📊 Database result:`, result);
          console.log(`📊 Student ID from insertId:`, studentId);
          
          // Fallback: if insertId is undefined, query for the student we just created
          if (!studentId) {
            console.log(`⚠️ insertId is undefined, querying for student...`);
            const [studentQuery]: any = await db.query(
              "SELECT id FROM students WHERE full_name = ? AND phone = ? ORDER BY id DESC LIMIT 1",
              [student.full_name.trim(), student.phone.trim()]
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
          
          // Generate QR code and email content
          const { qrData, qrCodeImage, emailHtml } = await generateQRAndEmail({
            ...student,
            full_name: student.full_name.trim(),
            phone: student.phone.trim(),
            gender: normalizedGender,
            class: student.class.trim(),
            email: finalEmail
          }, studentId);
          
          // Update student record with complete QR data
          try {
            await db.query(
              "UPDATE students SET qr_code = ? WHERE id = ?",
              [JSON.stringify(qrData), studentId]
            );
            console.log(`📧 QR code saved to database for student ${studentId}`);
          } catch (qrError) {
            console.error('Failed to save QR code to database:', qrError);
          }
          
          const newStudent = {
            id: studentId,
            full_name: student.full_name.trim(),
            phone: student.phone.trim(),
            gender: normalizedGender,
            class: student.class.trim(),
            email: finalEmail
          };
          
          insertedStudents.push(newStudent);
          
          // Send registration email
          console.log(`🔄 Sending registration email to ${finalEmail}`);
          const emailResult = await sendRegistrationEmail(newStudent, studentId, emailHtml);
          
          emailResults.push({
            student_id: studentId,
            student_name: student.full_name.trim(),
            email: finalEmail,
            success: emailResult.success,
            error: emailResult.error || null
          });
          
          if (emailResult.success) {
            console.log(`✅ Registration email sent to ${finalEmail}`);
          } else {
            console.log(`⚠️ Failed to send email to ${finalEmail}: ${emailResult.error}`);
          }
          
          // Add to existing set to prevent duplicates within the same upload
          existingSet.add(identifier);
        } catch (insertError: any) {
          console.error('Error inserting student:', student.full_name, insertError);
          skippedStudents.push({
            ...student,
            reason: 'Database insertion failed: ' + (insertError.message || 'Unknown error')
          });
        }
      }

      // Check existing students count AFTER upload
      const [afterCount]: any = await db.query('SELECT COUNT(*) as count FROM students');
      console.log('Students in database AFTER upload:', afterCount[0].count);
      console.log('Inserted:', insertedStudents.length, 'Skipped:', skippedStudents.length);
      
      // Email summary
      const emailsSent = emailResults.filter(r => r.success).length;
      const emailsFailed = emailResults.filter(r => !r.success).length;
      console.log('Emails sent:', emailsSent, 'Emails failed:', emailsFailed);
      console.log('=== BULK UPLOAD WITH EMAIL COMPLETE ===');

      return NextResponse.json({
        success: true,
        message: `Successfully processed ${students.length} students: ${insertedStudents.length} added${skippedStudents.length > 0 ? `, ${skippedStudents.length} skipped` : ''}. Emails: ${emailsSent} sent, ${emailsFailed} failed.`,
        data: insertedStudents,
        skipped: skippedStudents,
        emailResults: emailResults,
        summary: {
          total: students.length,
          inserted: insertedStudents.length,
          skipped: skippedStudents.length,
          emailsSent: emailsSent,
          emailsFailed: emailsFailed
        }
      });
    } catch (error: any) {
      console.error('Bulk upload database error:', error);
      return NextResponse.json(
        { 
          success: false, 
          message: `Database error: ${error.message || 'Failed to process students'}`,
          error: 'DATABASE_ERROR'
        },
        { status: 500 }
      );
    }
  } catch (error: any) {
    console.error('Bulk upload with email error:', error);
    return NextResponse.json(
      { success: false, message: error.message || 'Failed to upload students with email' },
      { status: 500 }
    );
  }
}