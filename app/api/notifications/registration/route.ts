import { NextResponse } from "next/server";
import { db } from "@/lib/db";
import nodemailer from "nodemailer";

// Email configuration - Gmail with App Password
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
  transporter = nodemailer.createTransporter(EMAIL_CONFIG);
} catch (error) {
  console.error('Failed to create email transporter:', error);
}

export async function POST(req: Request) {
  try {
    const body = await req.json();
    const { student_id, full_name, email, phone, class: studentClass, gender } = body;

    if (!student_id || !full_name || !email) {
      return NextResponse.json(
        { message: "Student ID, name, and email are required" },
        { status: 400 }
      );
    }

    // Check if email is configured
    if (!transporter || !process.env.SMTP_USER || !process.env.SMTP_PASS) {
      console.log('⚠️ Email not configured, skipping registration email');
      console.log('SMTP_USER:', process.env.SMTP_USER ? 'Set' : 'Not set');
      console.log('SMTP_PASS:', process.env.SMTP_PASS ? 'Set' : 'Not set');
      return NextResponse.json({ 
        message: "Student registered successfully (email not configured)",
        email_sent: false
      });
    }

    // Generate QR code data
    const qrData = {
      student_id: student_id,
      full_name: full_name,
      class: studentClass,
      phone: phone,
      timestamp: Date.now()
    };

    // Generate VERY SMALL QR code for mobile
    const qrText = JSON.stringify(qrData);
    const encodedText = encodeURIComponent(qrText);
    const qrCodeImage = `https://api.qrserver.com/v1/create-qr-code/?size=100x100&data=${encodedText}`;

    // Create mobile-first email content
    const emailSubject = "Welcome to MK Attendance System - Your QR Code";
    const emailHtml = `
      <!DOCTYPE html>
      <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>MK Attendance System</title>
        <style>
          body { margin: 0; padding: 0; font-family: Arial, sans-serif; }
          .container { max-width: 100%; margin: 0 auto; background: white; }
          .qr-box { 
            background: white; 
            border: 2px solid #dc3545; 
            border-radius: 8px; 
            padding: 40px; 
            margin: 15px auto; 
            width: 250px; 
            height: 200px; 
            text-align: center;
          }
          .qr-img { 
            width: 80px; 
            height: 80px; 
            margin: 0 auto; 
            display: block; 
          }
          @media only screen and (max-width: 480px) {
            .qr-box { 
              width: 220px !important; 
              height: 180px !important; 
              padding: 30px !important; 
            }
            .qr-img { 
              width: 70px !important; 
              height: 70px !important; 
            }
          }
        </style>
      </head>
      <body>
        <div class="container">
          <!-- Header -->
          <div style="background: linear-gradient(135deg, #6A5ACD, #9370DB); padding: 20px; text-align: center;">
            <h1 style="color: white; margin: 0; font-size: 22px;">MK Attendance System</h1>
            <p style="color: white; margin: 5px 0; font-size: 14px;">Student Registration Confirmation</p>
          </div>
          
          <!-- Content -->
          <div style="padding: 15px;">
            <h2 style="color: #333; font-size: 18px;">Welcome, ${full_name}!</h2>
            <p style="color: #666; font-size: 14px;">
              Congratulations! You have been successfully registered in the MK Attendance System.
            </p>
            
            <!-- Registration Details -->
            <div style="background: #f9f9f9; padding: 12px; border-radius: 6px; margin: 12px 0;">
              <h3 style="color: #6A5ACD; margin-top: 0; font-size: 16px;">Your Registration Details:</h3>
              <table style="width: 100%; font-size: 13px;">
                <tr>
                  <td style="padding: 4px 0; font-weight: bold; color: #333;">Registration ID:</td>
                  <td style="padding: 4px 0; color: #666;">${student_id}</td>
                </tr>
                <tr>
                  <td style="padding: 4px 0; font-weight: bold; color: #333;">Full Name:</td>
                  <td style="padding: 4px 0; color: #666;">${full_name}</td>
                </tr>
                <tr>
                  <td style="padding: 4px 0; font-weight: bold; color: #333;">Class:</td>
                  <td style="padding: 4px 0; color: #666;">${studentClass}</td>
                </tr>
                <tr>
                  <td style="padding: 4px 0; font-weight: bold; color: #333;">Phone:</td>
                  <td style="padding: 4px 0; color: #666;">${phone}</td>
                </tr>
                <tr>
                  <td style="padding: 4px 0; font-weight: bold; color: #333;">Gender:</td>
                  <td style="padding: 4px 0; color: #666;">${gender || 'Male'}</td>
                </tr>
              </table>
            </div>
            
            <!-- QR Code Section -->
            <div style="text-align: center; margin: 15px 0;">
              <h3 style="color: #6A5ACD; font-size: 16px;">Your Personal QR Code</h3>
              
              <!-- VERY SMALL QR Container for Mobile -->
              <div class="qr-box">
                <img src="${qrCodeImage}" alt="Your QR Code" class="qr-img" />
                <p style="color: #dc3545; font-weight: bold; margin: 8px 0 0 0; font-size: 11px;">
                  Scan this QR code for attendance
                </p>
              </div>
              
              <p style="color: #666; font-size: 12px; margin: 10px 5px;">
                <strong>How to use:</strong><br>
                • Save this QR code to your phone<br>
                • Show it to your teacher for attendance<br>
                • Your QR code works every day
              </p>
            </div>
            
            <!-- Important Note -->
            <div style="background: #e8f4fd; padding: 12px; border-radius: 6px; border-left: 3px solid #2196F3;">
              <p style="margin: 0; color: #1976D2; font-size: 12px;">
                <strong>Important:</strong> Your QR code is unique to you. Save this email or screenshot the QR code.
              </p>
            </div>
          </div>
          
          <!-- Footer -->
          <div style="background: #333; padding: 12px; text-align: center;">
            <p style="color: #ccc; margin: 0; font-size: 11px;">
              © ${new Date().getFullYear()} MK Attendance System. All rights reserved.
            </p>
          </div>
        </div>
      </body>
      </html>
    `;

    // Send email
    const mailOptions = {
      from: `"MK Attendance System" <${EMAIL_CONFIG.auth.user}>`,
      to: email,
      subject: emailSubject,
      html: emailHtml,
    };

    try {
      await transporter.sendMail(mailOptions);
      console.log(`✅ Registration email sent to ${email}`);
      
      // Log successful email to database
      try {
        await db.query(
          "INSERT INTO email_logs (type, recipient, sender, content, status) VALUES (?, ?, ?, ?, ?)",
          ['registration', email, EMAIL_CONFIG.auth.user, emailSubject, 'success']
        );
      } catch (logError) {
        console.error('Failed to log email:', logError);
      }
      
      return NextResponse.json({
        message: "Registration email sent successfully",
        email_sent: true
      });
    } catch (emailError: any) {
      console.error(`❌ Failed to send email to ${email}:`, emailError);
      
      // Log failed email to database
      try {
        await db.query(
          "INSERT INTO email_logs (type, recipient, sender, content, status, error_message) VALUES (?, ?, ?, ?, ?, ?)",
          ['registration', email, EMAIL_CONFIG.auth.user, emailSubject, 'failed', emailError.message]
        );
      } catch (logError) {
        console.error('Failed to log email error:', logError);
      }
      
      return NextResponse.json({
        message: "Failed to send registration email",
        error: emailError.message,
        email_sent: false
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