import { NextResponse } from "next/server";

export async function GET() {
  try {
    return NextResponse.json({
      smtp_user: process.env.SMTP_USER || 'Not set',
      smtp_host: process.env.SMTP_HOST || 'Not set',
      smtp_port: process.env.SMTP_PORT || 'Not set',
      smtp_pass_length: process.env.SMTP_PASS ? process.env.SMTP_PASS.length : 0,
      smtp_pass_first_char: process.env.SMTP_PASS ? process.env.SMTP_PASS.charAt(0) : 'N/A',
      smtp_pass_last_char: process.env.SMTP_PASS ? process.env.SMTP_PASS.charAt(process.env.SMTP_PASS.length - 1) : 'N/A',
    });
  } catch (error: any) {
    return NextResponse.json({
      error: error.message
    }, { status: 500 });
  }
}