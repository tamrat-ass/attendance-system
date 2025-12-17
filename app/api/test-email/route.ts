import { NextResponse } from "next/server";
import nodemailer from "nodemailer";

export async function GET() {
  try {
    console.log('Testing email configuration...');
    console.log('SMTP_USER:', process.env.SMTP_USER);
    console.log('SMTP_PASS:', process.env.SMTP_PASS ? 'Set' : 'Not set');
    console.log('SMTP_HOST:', process.env.SMTP_HOST);
    console.log('SMTP_PORT:', process.env.SMTP_PORT);

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

    // Verify connection
    await transporter.verify();
    console.log('✅ SMTP connection verified successfully');

    // Send test email
    await transporter.sendMail({
      from: `"MK Attendance Test" <${process.env.SMTP_USER}>`,
      to: process.env.SMTP_USER, // Send to yourself
      subject: "Test Email from MK Attendance System",
      html: `
        <h1>Email Test Successful!</h1>
        <p>Your email configuration is working correctly.</p>
        <p>Timestamp: ${new Date().toISOString()}</p>
      `,
    });

    return NextResponse.json({
      success: true,
      message: "Email sent successfully! Check your inbox.",
      config: {
        user: process.env.SMTP_USER,
        host: process.env.SMTP_HOST,
        port: process.env.SMTP_PORT,
      }
    });
  } catch (error: any) {
    console.error('❌ Email test failed:', error);
    return NextResponse.json({
      success: false,
      error: error.message,
      details: error.toString(),
      config: {
        user: process.env.SMTP_USER,
        host: process.env.SMTP_HOST,
        port: process.env.SMTP_PORT,
        passSet: !!process.env.SMTP_PASS,
      }
    }, { status: 500 });
  }
}
