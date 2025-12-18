import { NextRequest, NextResponse } from 'next/server';
import { google } from 'googleapis';

// Initialize Google Sheets API
async function getGoogleSheetsClient() {
  try {
    const serviceAccountKey = JSON.parse(process.env.GOOGLE_SERVICE_ACCOUNT_KEY || '{}');
    
    const auth = new google.auth.GoogleAuth({
      credentials: serviceAccountKey,
      scopes: ['https://www.googleapis.com/auth/spreadsheets'],
    });

    const authClient = await auth.getClient();
    const sheets = google.sheets({ version: 'v4', auth: authClient });
    
    return sheets;
  } catch (error) {
    console.error('Failed to initialize Google Sheets client:', error);
    throw new Error('Google Sheets authentication failed');
  }
}

// Setup Google Sheets with proper structure
export async function POST(request: NextRequest) {
  try {
    console.log('🔧 Setting up Google Sheets for backup...');
    
    if (!process.env.GOOGLE_SPREADSHEET_ID) {
      throw new Error('GOOGLE_SPREADSHEET_ID environment variable is required');
    }

    const sheets = await getGoogleSheetsClient();
    const spreadsheetId = process.env.GOOGLE_SPREADSHEET_ID;

    // Get existing sheets
    const spreadsheet = await sheets.spreadsheets.get({
      spreadsheetId,
    });

    const existingSheets = spreadsheet.data.sheets?.map(sheet => sheet.properties?.title) || [];
    console.log('📋 Existing sheets:', existingSheets);

    // Create Students sheet if it doesn't exist
    if (!existingSheets.includes('Students')) {
      await sheets.spreadsheets.batchUpdate({
        spreadsheetId,
        requestBody: {
          requests: [{
            addSheet: {
              properties: {
                title: 'Students',
                gridProperties: {
                  rowCount: 1000,
                  columnCount: 10
                }
              }
            }
          }]
        }
      });
      console.log('✅ Created Students sheet');
    }

    // Create Attendance sheet if it doesn't exist
    if (!existingSheets.includes('Attendance')) {
      await sheets.spreadsheets.batchUpdate({
        spreadsheetId,
        requestBody: {
          requests: [{
            addSheet: {
              properties: {
                title: 'Attendance',
                gridProperties: {
                  rowCount: 10000,
                  columnCount: 10
                }
              }
            }
          }]
        }
      });
      console.log('✅ Created Attendance sheet');
    }

    // Setup Students sheet headers
    const studentsHeaders = ['ID', 'Full Name', 'Phone', 'Class', 'Gender', 'Email', 'Created At', 'Updated At'];
    await sheets.spreadsheets.values.update({
      spreadsheetId,
      range: 'Students!A1:H1',
      valueInputOption: 'RAW',
      requestBody: {
        values: [studentsHeaders],
      },
    });

    // Setup Attendance sheet headers
    const attendanceHeaders = ['ID', 'Student ID', 'Student Name', 'Date', 'Status', 'Notes', 'Created At', 'Updated At'];
    await sheets.spreadsheets.values.update({
      spreadsheetId,
      range: 'Attendance!A1:H1',
      valueInputOption: 'RAW',
      requestBody: {
        values: [attendanceHeaders],
      },
    });

    // Format headers (make them bold)
    await sheets.spreadsheets.batchUpdate({
      spreadsheetId,
      requestBody: {
        requests: [
          {
            repeatCell: {
              range: {
                sheetId: spreadsheet.data.sheets?.find(s => s.properties?.title === 'Students')?.properties?.sheetId,
                startRowIndex: 0,
                endRowIndex: 1,
                startColumnIndex: 0,
                endColumnIndex: 8
              },
              cell: {
                userEnteredFormat: {
                  textFormat: {
                    bold: true
                  },
                  backgroundColor: {
                    red: 0.9,
                    green: 0.9,
                    blue: 0.9
                  }
                }
              },
              fields: 'userEnteredFormat(textFormat,backgroundColor)'
            }
          },
          {
            repeatCell: {
              range: {
                sheetId: spreadsheet.data.sheets?.find(s => s.properties?.title === 'Attendance')?.properties?.sheetId,
                startRowIndex: 0,
                endRowIndex: 1,
                startColumnIndex: 0,
                endColumnIndex: 8
              },
              cell: {
                userEnteredFormat: {
                  textFormat: {
                    bold: true
                  },
                  backgroundColor: {
                    red: 0.9,
                    green: 0.9,
                    blue: 0.9
                  }
                }
              },
              fields: 'userEnteredFormat(textFormat,backgroundColor)'
            }
          }
        ]
      }
    });

    console.log('✅ Google Sheets setup completed');

    return NextResponse.json({
      success: true,
      message: 'Google Sheets setup completed successfully',
      spreadsheetId,
      sheets: ['Students', 'Attendance']
    });

  } catch (error: any) {
    console.error('❌ Google Sheets setup failed:', error);
    
    return NextResponse.json({
      success: false,
      message: 'Google Sheets setup failed',
      error: error.message
    }, { status: 500 });
  }
}

// GET endpoint to check setup status
export async function GET(request: NextRequest) {
  try {
    if (!process.env.GOOGLE_SPREADSHEET_ID) {
      return NextResponse.json({
        success: false,
        message: 'GOOGLE_SPREADSHEET_ID not configured'
      }, { status: 400 });
    }

    const sheets = await getGoogleSheetsClient();
    const spreadsheetId = process.env.GOOGLE_SPREADSHEET_ID;

    const spreadsheet = await sheets.spreadsheets.get({
      spreadsheetId,
    });

    const existingSheets = spreadsheet.data.sheets?.map(sheet => ({
      title: sheet.properties?.title,
      sheetId: sheet.properties?.sheetId,
      rowCount: sheet.properties?.gridProperties?.rowCount,
      columnCount: sheet.properties?.gridProperties?.columnCount
    })) || [];

    return NextResponse.json({
      success: true,
      spreadsheetId,
      title: spreadsheet.data.properties?.title,
      sheets: existingSheets,
      isSetup: existingSheets.some(s => s.title === 'Students') && existingSheets.some(s => s.title === 'Attendance')
    });

  } catch (error: any) {
    return NextResponse.json({
      success: false,
      message: 'Failed to check setup status',
      error: error.message
    }, { status: 500 });
  }
}