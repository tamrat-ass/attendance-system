import { NextResponse } from "next/server";
import { db } from "@/lib/db";
import nodemailer from "nodemailer";

// Email configuration - requires environment variables
const EMAIL_CONFIG = {
  host: process.env.SMTP_HOST || 'smtp.gmail.com',
  port: parseInt(process.env.SMTP_PORT || '587'),
  secure: false, // true for 465, false for other ports
  auth: {
    user: process.env.SMTP_USER || 'tamrat.ass@gmail.com',
    pass: process.env.SMTP_PASS || 'your-gmail-app-password',
  },
};

// Create transporter
let transporter: any = null;
try {
  transporter = nodemailer.createTransport(EMAIL_CONFIG);
} catch (error) {
  console.error('Failed to create email transporter:', error);
}

export async function POST(req: Request) {
  try {
    const body = await req.json();
    const { student_id, full_name, email, phone, class: studentClass, gender, qr_code_data, qr_code_image } = body;

    if (!student_id || !full_name || !email) {
      return NextResponse.json(
        { message: "Student ID, name, and email are required" },
        { status: 400 }
      );
    }

    // Check if email is properly configured
    if (!transporter || !process.env.SMTP_USER || !process.env.SMTP_PASS) {
      console.log('⚠️ Email credentials not configured, skipping registration email');
      return NextResponse.json({ 
        message: "Student registered successfully (email not configured)",
        email_sent: false
      });
    }

    // Create email content with QR code
    const emailSubject = "Welcome to MK Attendance System - Your QR Code";
    const qrCodeSection = qr_code_image ? `
      <div style="background: white; padding: 20px; border-radius: 8px; margin: 20px 0; text-align: center;">
        <h3 style="color: #6A5ACD; margin-top: 0;">Your Personal QR Code</h3>
        <p style="color: #666; margin-bottom: 15px;">
          This QR code is unique to you and will be used for attendance tracking.
        </p>
        <img src="data:image/png;base64,${qr_code_image}" 
             alt="Student QR Code" 
             style="max-width: 200px; height: auto; border: 2px solid #6A5ACD; border-radius: 8px;" />
        <p style="color: #666; font-size: 14px; margin-top: 15px;">
          <strong>How to use:</strong><br>
          • Show this QR code to your teacher for attendance<br>
          • Keep this email safe for future reference<br>
          • Do not share your QR code with others
        </p>
      </div>
    ` : '';

    const emailHtml = `
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
        <div style="background: linear-gradient(135deg, #6A5ACD, #9370DB); padding: 20px; text-align: center;">
          <h1 style="color: white; margin: 0;">MK Attendance System</h1>
          <p style="color: white; margin: 5px 0;">Student Registration Confirmation</p>
        </div>
        
        <div style="padding: 30px; background: #f9f9f9;">
          <h2 style="color: #333;">Welcome, ${full_name}!</h2>
          <p style="color: #666; font-size: 16px;">
            Congratulations! You have been successfully registered in the MK Attendance System.
          </p>
          
          <div style="background: white; padding: 20px; border-radius: 8px; margin: 20px 0;">
            <h3 style="color: #6A5ACD; margin-top: 0;">Your Registration Details:</h3>
            <table style="width: 100%; border-collapse: collapse;">
              <tr>
                <td style="padding: 8px 0; font-weight: bold; color: #333;">Student ID:</td>
                <td style="padding: 8px 0; color: #666;">${student_id}</td>
              </tr>
              <tr>
                <td style="padding: 8px 0; font-weight: bold; color: #333;">Full Name:</td>
                <td style="padding: 8px 0; color: #666;">${full_name}</td>
              </tr>
              <tr>
                <td style="padding: 8px 0; font-weight: bold; color: #333;">Gender:</td>
                <td style="padding: 8px 0; color: #666;">${gender || 'Not specified'}</td>
              </tr>
              <tr>
                <td style="padding: 8px 0; font-weight: bold; color: #333;">Class:</td>
                <td style="padding: 8px 0; color: #666;">${studentClass}</td>
              </tr>
              <tr>
                <td style="padding: 8px 0; font-weight: bold; color: #333;">Phone Number:</td>
                <td style="padding: 8px 0; color: #666;">${phone}</td>
              </tr>
            </table>
          </div>
          
          ${qrCodeSection}
          
          <div style="background: #e8f4fd; padding: 15px; border-radius: 8px; border-left: 4px solid #2196F3;">
            <p style="margin: 0; color: #1976D2;">
              <strong>Important:</strong> Keep your QR code safe and do not share it with others. 
              It will be used for attendance tracking in your classes.
            </p>
          </div>
          
          <p style="color: #666; margin-top: 20px;">
            If you have any questions or need assistance, please contact your school administration.
          </p>
        </div>
        
        <div style="background: #333; padding: 20px; text-align: center;">
          <p style="color: #ccc; margin: 0; font-size: 14px;">
            © ${new Date().getFullYear()} MK Attendance System. All rights reserved.
          </p>
        </div>
      </div>
    `;

    // Send email
    const mailOptions = {
      from: `"MK Attendance System" <${EMAIL_CONFIG.auth.user}>`,
      to: email,
      subject: emailSubject,
      html: emailHtml,
    };

    let emailStatus = 'failed';
    let errorMessage = '';

    try {
      await transporter.sendMail(mailOptions);
      emailStatus = 'success';
      console.log(`✅ Registration email sent to ${email}`);
    } catch (emailError: any) {
      console.error(`❌ Failed to send registration email to ${email}:`, emailError);
      errorMessage = emailError.message;
    }

    // Log the email attempt
    try {
      await db.query(
        `INSERT INTO email_logs (type, recipient, sender, content, status, error_message, student_id, timestamp) 
         VALUES (?, ?, ?, ?, ?, ?, ?, NOW())`,
        [
          'registration',
          email,
          'System',
          `Registration confirmation for ${full_name}`,
          emailStatus,
          errorMessage,
          student_id
        ]
      );
    } catch (logError) {
      console.error('Failed to log email:', logError);
    }

    if (emailStatus === 'success') {
      return NextResponse.json({
        message: "Registration email sent successfully",
        status: "success"
      });
    } else {
      return NextResponse.json({
        message: "Failed to send registration email",
        error: errorMessage,
        status: "failed"
      }, { status: 500 });
    }

  } catch (error: any) {
    console.error('Registration email error:', error);
    return NextResponse.json(
      { message: "Error sending registration email", error: error.message },
      { status: 500 }
    );
  }
}