import { NextResponse } from 'next/server';

export async function GET() {
  try {
    const spreadsheetId = process.env.GOOGLE_SPREADSHEET_ID;
    
    return NextResponse.json({
      success: true,
      currentSpreadsheetId: spreadsheetId,
      expectedId: '1ulV3u0YimrHMuSkxhzj95fPzoque9Lp7V8152kio9xz0',
      isCorrect: spreadsheetId === '1ulV3u0YimrHMuSkxhzj95fPzoque9Lp7V8152kio9xz0',
      timestamp: new Date().toISOString()
    });

  } catch (error: any) {
    return NextResponse.json({
      success: false,
      error: error.message
    }, { status: 500 });
  }
}