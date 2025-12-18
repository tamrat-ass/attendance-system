import { NextResponse } from 'next/server';
import { google } from 'googleapis';

export async function GET() {
  try {
    console.log('🔧 Testing Google Sheets authentication...');
    
    // Step 1: Check environment variable
    const serviceAccountKeyRaw = process.env.GOOGLE_SERVICE_ACCOUNT_KEY;
    if (!serviceAccountKeyRaw) {
      return NextResponse.json({
        success: false,
        error: 'GOOGLE_SERVICE_ACCOUNT_KEY environment variable is missing'
      }, { status: 500 });
    }

    // Step 2: Parse JSON
    let serviceAccountKey;
    try {
      serviceAccountKey = JSON.parse(serviceAccountKeyRaw);
      console.log('✅ JSON parsing successful');
    } catch (parseError: any) {
      return NextResponse.json({
        success: false,
        error: 'Invalid JSON in GOOGLE_SERVICE_ACCOUNT_KEY',
        details: parseError.message
      }, { status: 500 });
    }

    // Step 3: Check required fields in service account
    const requiredFields = ['type', 'project_id', 'private_key_id', 'private_key', 'client_email'];
    const missingFields = requiredFields.filter(field => !serviceAccountKey[field]);
    
    if (missingFields.length > 0) {
      return NextResponse.json({
        success: false,
        error: 'Missing required fields in service account JSON',
        missingFields: missingFields
      }, { status: 500 });
    }

    // Step 4: Initialize Google Auth
    let auth;
    try {
      auth = new google.auth.GoogleAuth({
        credentials: serviceAccountKey,
        scopes: ['https://www.googleapis.com/auth/spreadsheets'],
      });
      console.log('✅ Google Auth initialized');
    } catch (authError: any) {
      return NextResponse.json({
        success: false,
        error: 'Failed to initialize Google Auth',
        details: authError.message
      }, { status: 500 });
    }

    // Step 5: Get auth client
    let authClient;
    try {
      authClient = await auth.getClient();
      console.log('✅ Auth client obtained');
    } catch (clientError: any) {
      return NextResponse.json({
        success: false,
        error: 'Failed to get auth client',
        details: clientError.message
      }, { status: 500 });
    }

    // Step 6: Initialize Sheets API
    let sheets;
    try {
      sheets = google.sheets({ version: 'v4', auth: authClient });
      console.log('✅ Sheets API initialized');
    } catch (sheetsError: any) {
      return NextResponse.json({
        success: false,
        error: 'Failed to initialize Sheets API',
        details: sheetsError.message
      }, { status: 500 });
    }

    // Step 7: Test spreadsheet access
    const spreadsheetId = process.env.GOOGLE_SPREADSHEET_ID;
    if (!spreadsheetId) {
      return NextResponse.json({
        success: false,
        error: 'GOOGLE_SPREADSHEET_ID environment variable is missing'
      }, { status: 500 });
    }

    try {
      const spreadsheet = await sheets.spreadsheets.get({
        spreadsheetId: spreadsheetId,
      });
      
      console.log('✅ Spreadsheet access successful');
      
      return NextResponse.json({
        success: true,
        message: 'Google Sheets authentication successful',
        spreadsheet: {
          title: spreadsheet.data.properties?.title,
          sheets: spreadsheet.data.sheets?.map(sheet => sheet.properties?.title) || []
        },
        serviceAccount: {
          email: serviceAccountKey.client_email,
          projectId: serviceAccountKey.project_id
        }
      });
      
    } catch (accessError: any) {
      return NextResponse.json({
        success: false,
        error: 'Failed to access spreadsheet',
        details: accessError.message,
        spreadsheetId: spreadsheetId,
        hint: 'Make sure the spreadsheet is shared with the service account email'
      }, { status: 500 });
    }

  } catch (error: any) {
    console.error('❌ Test failed:', error);
    return NextResponse.json({
      success: false,
      error: 'Unexpected error during testing',
      details: error.message,
      stack: error.stack
    }, { status: 500 });
  }
}