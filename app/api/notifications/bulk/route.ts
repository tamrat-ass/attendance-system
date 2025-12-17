import { NextResponse } from "next/server";
import { db } from "@/lib/db";
import nodemailer from "nodemailer";

// Email configuration
const EMAIL_CONFIG = {
  host: process.env.SMTP_HOST || 'smtp.gmail.com',
  port: parseInt(process.env.SMTP_PORT || '587'),
  secure: false,
  auth: {
    user: process.env.SMTP_USER || 'your-email@gmail.com',
    pass: process.env.SMTP_PASS || 'your-app-password',
  },
};

const transporter = nodemailer.createTransporter(EMAIL_CONFIG);

export async function POST(req: Request) {
  try {
    const body = await req.json();
    const { message, student_ids, sender_name } = body;

    if (!message || !student_ids || !Array.isArray(student_ids) || student_ids.length === 0) {
      return NextResponse.json(
        { message: "Message and student IDs are required" },
        { status: 400 }
      );
    }

    // Get students with email addresses
    const placeholders = student_ids.map(() => '?').join(',');
    const [students]: any = await db.query(
      `SELECT id, full_name, email, class FROM students WHERE id IN (${placeholders}) AND email IS NOT NULL AND email != ''`,
      student_ids
    );

    if (students.length === 0) {
      return NextResponse.json(
        { message: "No students found with email addresses" },
        { status: 404 }
      );
    }

    let sentCount = 0;
    let failedCount = 0;
    const results = [];

    // Send emails to each student
    for (const student of students) {
      const emailSubject = "Message from MK Attendance System";
      const emailHtml = `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <div style="background: linear-gradient(135deg, #6A5ACD, #9370DB); padding: 20px; text-align: center;">
            <h1 style="color: white; margin: 0;">MK Attendance System</h1>
            <p style="color: white; margin: 5px 0;">Message from ${sender_name || 'Administration'}</p>
          </div>
          
          <div style="padding: 30px; background: #f9f9f9;">
            <h2 style="color: #333;">Hello, ${student.full_name}!</h2>
            
            <div style="background: white; padding: 20px; border-radius: 8px; margin: 20px 0; border-left: 4px solid #6A5ACD;">
              <div style="color: #333; font-size: 16px; line-height: 1.6;">
                ${message.replace(/\n/g, '<br>')}
              </div>
            </div>
            
            <div style="background: #e8f4fd; padding: 15px; border-radius: 8px; margin-top: 20px;">
              <p style="margin: 0; color: #1976D2; font-size: 14px;">
                <strong>Student Details:</strong><br>
                Name: ${student.full_name}<br>
                Class: ${student.class}<br>
                Student ID: ${student.id}
              </p>
            </div>
            
            <p style="color: #666; margin-top: 20px; font-size: 14px;">
              If you have any questions about this message, please contact your school administration.
            </p>
          </div>
          
          <div style="background: #333; padding: 20px; text-align: center;">
            <p style="color: #ccc; margin: 0; font-size: 14px;">
              © ${new Date().getFullYear()} MK Attendance System. All rights reserved.
            </p>
          </div>
        </div>
      `;

      const mailOptions = {
        from: `"MK Attendance System" <${EMAIL_CONFIG.auth.user}>`,
        to: student.email,
        subject: emailSubject,
        html: emailHtml,
      };

      let emailStatus = 'failed';
      let errorMessage = '';

      try {
        await transporter.sendMail(mailOptions);
        emailStatus = 'success';
        sentCount++;
        console.log(`✅ Bulk email sent to ${student.email}`);
      } catch (emailError: any) {
        console.error(`❌ Failed to send bulk email to ${student.email}:`, emailError);
        errorMessage = emailError.message;
        failedCount++;
      }

      // Log each email attempt
      try {
        await db.query(
          `INSERT INTO email_logs (type, recipient, sender, content, status, error_message, student_id, timestamp) 
           VALUES (?, ?, ?, ?, ?, ?, ?, NOW())`,
          [
            'bulk',
            student.email,
            sender_name || 'Admin',
            message.substring(0, 500), // Truncate long messages
            emailStatus,
            errorMessage,
            student.id
          ]
        );
      } catch (logError) {
        console.error('Failed to log email:', logError);
      }

      results.push({
        student_id: student.id,
        email: student.email,
        status: emailStatus,
        error: errorMessage
      });

      // Add small delay between emails to avoid rate limiting
      await new Promise(resolve => setTimeout(resolve, 100));
    }

    return NextResponse.json({
      message: `Bulk email completed. Sent: ${sentCount}, Failed: ${failedCount}`,
      sent_count: sentCount,
      failed_count: failedCount,
      total_students: students.length,
      results: results
    });

  } catch (error: any) {
    console.error('Bulk email error:', error);
    return NextResponse.json(
      { message: "Error sending bulk emails", error: error.message },
      { status: 500 }
    );
  }
}