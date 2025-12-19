import { NextResponse } from 'next/server';
import { google } from 'googleapis';

export async function GET() {
  try {
    console.log('🔧 Testing Google Auth only (no spreadsheet access)...');
    
    // Parse service account key
    const serviceAccountKey = JSON.parse(process.env.GOOGLE_SERVICE_ACCOUNT_KEY || '{}');
    
    // Initialize Google Auth
    const auth = new google.auth.GoogleAuth({
      credentials: serviceAccountKey,
      scopes: ['https://www.googleapis.com/auth/spreadsheets'],
    });

    // Get auth client
    const authClient = await auth.getClient();
    
    // Initialize Sheets API (but don't call any methods)
    const sheets = google.sheets({ version: 'v4', auth: authClient });

    return NextResponse.json({
      success: true,
      message: 'Google authentication successful (no spreadsheet access tested)',
      serviceAccount: serviceAccountKey.client_email,
      timestamp: new Date().toISOString()
    });

  } catch (error: any) {
    console.error('❌ Auth test failed:', error);
    return NextResponse.json({
      success: false,
      error: error.message,
      errorCode: error.code,
      errorDetails: error.details,
      timestamp: new Date().toISOString()
    }, { status: 500 });
  }
}