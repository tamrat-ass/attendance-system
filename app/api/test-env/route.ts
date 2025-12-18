import { NextResponse } from 'next/server';

export async function GET() {
  try {
    // Test environment variables without exposing sensitive data
    const envCheck = {
      DATABASE_URL: process.env.DATABASE_URL ? 'Set' : 'Missing',
      GOOGLE_SPREADSHEET_ID: process.env.GOOGLE_SPREADSHEET_ID ? 'Set' : 'Missing',
      GOOGLE_SERVICE_ACCOUNT_KEY: process.env.GOOGLE_SERVICE_ACCOUNT_KEY ? 'Set' : 'Missing',
      BACKUP_API_KEY: process.env.BACKUP_API_KEY ? 'Set' : 'Missing',
      
      // Check if JSON is valid
      jsonValid: false,
      jsonError: null
    };

    // Test JSON parsing
    if (process.env.GOOGLE_SERVICE_ACCOUNT_KEY) {
      try {
        JSON.parse(process.env.GOOGLE_SERVICE_ACCOUNT_KEY);
        envCheck.jsonValid = true;
      } catch (error: any) {
        envCheck.jsonError = error.message;
      }
    }

    return NextResponse.json({
      success: true,
      environment: envCheck,
      timestamp: new Date().toISOString()
    });

  } catch (error: any) {
    return NextResponse.json({
      success: false,
      error: error.message,
      timestamp: new Date().toISOString()
    }, { status: 500 });
  }
}