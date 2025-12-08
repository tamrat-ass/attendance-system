import nodemailer from 'nodemailer';

// Initialize nodemailer transporter
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASSWORD,
  },
});

// Store recovery codes in memory (in production, use database)
const recoveryCodes: Map<string, { code: string; expires: number; email: string }> = new Map();

export async function sendRecoveryEmail(email: string, code: string) {
  try {
    console.log('[v0] Sending recovery email to:', email);
    // Email content with inline styles
    const mailOptions = {
      from: process.env.EMAIL_USER || 'tamaratasu23@gmail.com',
      to: email,
      subject: 'Attendance System - Password Recovery Code',
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
          <div style="background: linear-gradient(135deg, #3b82f6 0%, #1e40af 100%); padding: 20px; border-radius: 8px 8px 0 0; text-align: center;">
            <h1 style="color: white; margin: 0; font-size: 28px;">Attendance System</h1>
          </div>
          <div style="background: #f9fafb; padding: 30px; border: 1px solid #e5e7eb; border-radius: 0 0 8px 8px;">
            <p style="color: #374151; font-size: 16px; margin: 0 0 20px 0;">
              We received a request to reset your password. Use the verification code below:
            </p>
            
            <div style="background: white; border: 2px dashed #3b82f6; padding: 20px; text-align: center; margin: 20px 0; border-radius: 8px;">
              <p style="color: #6b7280; font-size: 14px; margin: 0 0 10px 0;">Your Verification Code:</p>
              <p style="font-size: 36px; font-weight: bold; color: #3b82f6; letter-spacing: 2px; margin: 0;">${code}</p>
            </div>
            
            <p style="color: #374151; font-size: 14px; margin: 20px 0;">
              This code will expire in 10 minutes.
            </p>
            
            <p style="color: #374151; font-size: 14px; margin: 20px 0 0 0;">
              If you didn't request this, please ignore this email or contact your administrator.
            </p>
            
            <hr style="border: none; border-top: 1px solid #e5e7eb; margin: 30px 0;">
            <p style="color: #9ca3af; font-size: 12px; text-align: center; margin: 0;">
              Attendance System © 2025
            </p>
          </div>
        </div>
      `,
    };
// Send email
    const result = await transporter.sendMail(mailOptions);
    console.log('[v0] Email sent successfully:', result.response);
    return { success: true };
  } catch (error) {
    console.error('[v0] Email sending error:', error);
    throw error;
  }
}
// Generate a recovery code and store it with expiration  
export function generateRecoveryCode(email: string): string {
  const code = Math.random().toString().slice(2, 8);
  const expiresAt = Date.now() + 10 * 60 * 1000; // 10 minutes
  
  recoveryCodes.set(code, { code, expires: expiresAt, email });
  console.log('[v0] Generated recovery code for email:', email);
  
  return code;
}
// Verify the recovery code for the given email
export function verifyRecoveryCode(code: string, email: string): boolean {
  const stored = recoveryCodes.get(code);
  // Check if code exists and is valid
  if (!stored) {
    console.log('[v0] Recovery code not found:', code);
    return false;
  }
  
  if (Date.now() > stored.expires) {
    console.log('[v0] Recovery code expired');
    recoveryCodes.delete(code);
    return false;
  }
  
  if (stored.email !== email) {
    console.log('[v0] Recovery code email mismatch');
    return false;
  }
  
  console.log('[v0] Recovery code verified successfully');
  recoveryCodes.delete(code);
  return true;
}
