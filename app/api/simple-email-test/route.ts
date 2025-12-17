import { NextResponse } from "next/server";
import nodemailer from "nodemailer";

export async function POST(req: Request) {
  try {
    const { email, name } = await req.json();
    
    console.log('🔥 SIMPLE EMAIL TEST STARTING - v2...');
    console.log('🔥 Target email:', email);
    console.log('🔥 Student name:', name);
    console.log('🔥 Using updated 16-char App Password');
    
    // Simple Gmail configuration
    const transporter = nodemailer.createTransport({
      service: 'gmail',
      auth: {
        user: 'tame.assu23@gmail.com',
        pass: process.env.SMTP_PASS,
      },
    });
    
    console.log('🔥 Transporter created');
    
    // Simple email
    const mailOptions = {
      from: 'tame.assu23@gmail.com',
      to: email,
      subject: 'MK Attendance - Registration Successful!',
      html: `
        <h1>Welcome ${name}!</h1>
        <p>You have been successfully registered in MK Attendance System.</p>
        <p>Your QR code is ready in the mobile app.</p>
        <p>Time: ${new Date().toLocaleString()}</p>
      `,
    };
    
    console.log('🔥 Sending email...');
    const result = await transporter.sendMail(mailOptions);
    console.log('🔥 Email sent successfully:', result.messageId);
    
    return NextResponse.json({
      success: true,
      message: 'Email sent successfully!',
      messageId: result.messageId
    });
    
  } catch (error: any) {
    console.error('🔥 EMAIL ERROR:', error);
    return NextResponse.json({
      success: false,
      error: error.message,
      details: error.toString()
    }, { status: 500 });
  }
}