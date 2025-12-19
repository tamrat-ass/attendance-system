import { NextResponse } from 'next/server';
import { google } from 'googleapis';

export async function GET() {
  try {
    console.log('🔧 Testing Google Sheets with proper newline handling...');
    
    // FIX #1: Properly handle newlines in service account JSON
    const credentials = JSON.parse(
      process.env.GOOGLE_SERVICE_ACCOUNT_KEY!.replace(/\\n/g, '\n')
    );
    
    console.log('✅ Service account JSON parsed with newline fix');
    
    // FIX #3: Use correct scope
    const auth = new google.auth.GoogleAuth({
      credentials,
      scopes: ['https://www.googleapis.com/auth/spreadsheets'],
    });
    
    const sheets = google.sheets({ version: 'v4', auth });
    
    // Test basic spreadsheet access
    const spreadsheetId = process.env.GOOGLE_SPREADSHEET_ID!;
    
    // First, get spreadsheet info
    const spreadsheet = await sheets.spreadsheets.get({
      spreadsheetId: spreadsheetId,
    });
    
    console.log('✅ Spreadsheet access successful');
    
    // Try to read a simple range
    let readResult = null;
    try {
      const res = await sheets.spreadsheets.values.get({
        spreadsheetId: spreadsheetId,
        range: 'A1:A1', // Simple range that should exist
      });
      readResult = res.data;
      console.log('✅ Range read successful');
    } catch (rangeError: any) {
      console.log('⚠️ Range read failed (might be empty sheet):', rangeError.message);
      readResult = { error: 'Range read failed', details: rangeError.message };
    }
    
    return NextResponse.json({
      success: true,
      message: 'Google Sheets access successful with newline fix',
      spreadsheet: {
        title: spreadsheet.data.properties?.title,
        sheets: spreadsheet.data.sheets?.map(sheet => sheet.properties?.title) || []
      },
      readTest: readResult,
      timestamp: new Date().toISOString()
    });
    
  } catch (err: any) {
    console.error('❌ Google Sheets test failed:', err);
    console.error('Error details:', err.response?.data || err.message);
    
    return NextResponse.json({
      success: false,
      error: err.message,
      details: err.response?.data || 'No additional details',
      errorCode: err.code,
      timestamp: new Date().toISOString()
    }, { status: 500 });
  }
}