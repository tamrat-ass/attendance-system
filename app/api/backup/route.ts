import { NextRequest, NextResponse } from 'next/server';
import { sql } from '@vercel/postgres';
import { google } from 'googleapis';

// Google Sheets configuration
const SCOPES = ['https://www.googleapis.com/auth/spreadsheets'];

// Initialize Google Sheets API
async function getGoogleSheetsClient() {
  try {
    // Parse the service account key from environment variable
    const serviceAccountKey = JSON.parse(process.env.GOOGLE_SERVICE_ACCOUNT_KEY || '{}');
    
    const auth = new google.auth.GoogleAuth({
      credentials: serviceAccountKey,
      scopes: SCOPES,
    });

    const authClient = await auth.getClient();
    const sheets = google.sheets({ version: 'v4', auth: authClient });
    
    return sheets;
  } catch (error) {
    console.error('Failed to initialize Google Sheets client:', error);
    throw new Error('Google Sheets authentication failed');
  }
}

// Backup students table (overwrite)
async function backupStudents(sheets: any, spreadsheetId: string) {
  try {
    console.log('🔄 Starting students backup...');
    
    // Get all students from database
    const result = await sql`
      SELECT id, full_name, phone, class, gender, email, created_at, updated_at 
      FROM students 
      ORDER BY id ASC
    `;

    const students = result.rows;
    console.log(`📊 Found ${students.length} students to backup`);

    // Prepare data for Google Sheets
    const headers = ['ID', 'Full Name', 'Phone', 'Class', 'Gender', 'Email', 'Created At', 'Updated At'];
    const rows = students.map(student => [
      student.id,
      student.full_name,
      student.phone,
      student.class,
      student.gender,
      student.email,
      student.created_at ? new Date(student.created_at).toISOString() : '',
      student.updated_at ? new Date(student.updated_at).toISOString() : ''
    ]);

    // Clear existing data and write new data
    const sheetName = 'Students';
    
    // Clear the sheet first
    await sheets.spreadsheets.values.clear({
      spreadsheetId,
      range: `${sheetName}!A:Z`,
    });

    // Write headers and data
    const values = [headers, ...rows];
    
    if (values.length > 1) { // Only write if we have data beyond headers
      await sheets.spreadsheets.values.update({
        spreadsheetId,
        range: `${sheetName}!A1`,
        valueInputOption: 'RAW',
        requestBody: {
          values: values,
        },
      });
    } else {
      // Write only headers if no data
      await sheets.spreadsheets.values.update({
        spreadsheetId,
        range: `${sheetName}!A1`,
        valueInputOption: 'RAW',
        requestBody: {
          values: [headers],
        },
      });
    }

    console.log(`✅ Students backup completed: ${students.length} records`);
    return { success: true, count: students.length };
    
  } catch (error) {
    console.error('❌ Students backup failed:', error);
    throw error;
  }
}

// Backup attendance table (append new records only)
async function backupAttendance(sheets: any, spreadsheetId: string) {
  try {
    console.log('🔄 Starting attendance backup...');
    
    const sheetName = 'Attendance';
    
    // Get the last backed up attendance ID from the sheet
    let lastBackedUpId = 0;
    try {
      const existingData = await sheets.spreadsheets.values.get({
        spreadsheetId,
        range: `${sheetName}!A:A`,
      });
      
      if (existingData.data.values && existingData.data.values.length > 1) {
        // Find the highest ID in the sheet (skip header row)
        const ids = existingData.data.values
          .slice(1) // Skip header
          .map(row => parseInt(row[0]))
          .filter(id => !isNaN(id));
        
        if (ids.length > 0) {
          lastBackedUpId = Math.max(...ids);
        }
      }
    } catch (error) {
      console.log('📝 No existing attendance data found, starting fresh backup');
    }

    console.log(`📊 Last backed up attendance ID: ${lastBackedUpId}`);

    // Get new attendance records from database
    const result = await sql`
      SELECT a.id, a.student_id, s.full_name as student_name, a.date, a.status, a.notes, a.created_at, a.updated_at
      FROM attendance a
      LEFT JOIN students s ON a.student_id = s.id
      WHERE a.id > ${lastBackedUpId}
      ORDER BY a.id ASC
    `;

    const newAttendance = result.rows;
    console.log(`📊 Found ${newAttendance.length} new attendance records to backup`);

    if (newAttendance.length === 0) {
      console.log('✅ No new attendance records to backup');
      return { success: true, count: 0, message: 'No new records' };
    }

    // Check if sheet has headers
    let needsHeaders = false;
    try {
      const headerCheck = await sheets.spreadsheets.values.get({
        spreadsheetId,
        range: `${sheetName}!A1:H1`,
      });
      
      if (!headerCheck.data.values || headerCheck.data.values.length === 0) {
        needsHeaders = true;
      }
    } catch (error) {
      needsHeaders = true;
    }

    // Prepare data for Google Sheets
    const headers = ['ID', 'Student ID', 'Student Name', 'Date', 'Status', 'Notes', 'Created At', 'Updated At'];
    const rows = newAttendance.map(record => [
      record.id,
      record.student_id,
      record.student_name || 'Unknown Student',
      record.date ? new Date(record.date).toISOString().split('T')[0] : '', // Date only
      record.status,
      record.notes || '',
      record.created_at ? new Date(record.created_at).toISOString() : '',
      record.updated_at ? new Date(record.updated_at).toISOString() : ''
    ]);

    // Write headers if needed
    if (needsHeaders) {
      await sheets.spreadsheets.values.update({
        spreadsheetId,
        range: `${sheetName}!A1`,
        valueInputOption: 'RAW',
        requestBody: {
          values: [headers],
        },
      });
    }

    // Append new data
    await sheets.spreadsheets.values.append({
      spreadsheetId,
      range: `${sheetName}!A:H`,
      valueInputOption: 'RAW',
      insertDataOption: 'INSERT_ROWS',
      requestBody: {
        values: rows,
      },
    });

    console.log(`✅ Attendance backup completed: ${newAttendance.length} new records`);
    return { success: true, count: newAttendance.length };
    
  } catch (error) {
    console.error('❌ Attendance backup failed:', error);
    throw error;
  }
}

// Create backup log entry
async function logBackupResult(result: any) {
  try {
    await sql`
      INSERT INTO backup_logs (
        backup_type, 
        status, 
        students_count, 
        attendance_count, 
        error_message, 
        created_at
      ) VALUES (
        'google_sheets',
        ${result.success ? 'success' : 'failed'},
        ${result.studentsCount || 0},
        ${result.attendanceCount || 0},
        ${result.error || null},
        NOW()
      )
    `;
  } catch (error) {
    console.error('Failed to log backup result:', error);
    // Don't throw - logging failure shouldn't break the backup
  }
}

// Main backup function
export async function POST(request: NextRequest) {
  const startTime = Date.now();
  
  try {
    console.log('🚀 Starting automatic backup process...');
    
    // Validate environment variables
    if (!process.env.GOOGLE_SPREADSHEET_ID) {
      throw new Error('GOOGLE_SPREADSHEET_ID environment variable is required');
    }
    
    if (!process.env.GOOGLE_SERVICE_ACCOUNT_KEY) {
      throw new Error('GOOGLE_SERVICE_ACCOUNT_KEY environment variable is required');
    }
    
    if (!process.env.DATABASE_URL) {
      throw new Error('DATABASE_URL environment variable is required');
    }

    // Initialize Google Sheets client
    const sheets = await getGoogleSheetsClient();
    const spreadsheetId = process.env.GOOGLE_SPREADSHEET_ID;

    // Perform backups
    const studentsResult = await backupStudents(sheets, spreadsheetId);
    const attendanceResult = await backupAttendance(sheets, spreadsheetId);

    const duration = Date.now() - startTime;
    const result = {
      success: true,
      studentsCount: studentsResult.count,
      attendanceCount: attendanceResult.count,
      duration: `${duration}ms`,
      timestamp: new Date().toISOString()
    };

    // Log the backup result
    await logBackupResult(result);

    console.log('✅ Backup completed successfully:', result);

    return NextResponse.json({
      success: true,
      message: 'Backup completed successfully',
      data: result
    });

  } catch (error: any) {
    const duration = Date.now() - startTime;
    const result = {
      success: false,
      error: error.message,
      duration: `${duration}ms`,
      timestamp: new Date().toISOString()
    };

    // Log the backup failure
    await logBackupResult(result);

    console.error('❌ Backup failed:', error);

    return NextResponse.json({
      success: false,
      message: 'Backup failed',
      error: error.message,
      data: result
    }, { status: 500 });
  }
}

// GET endpoint for manual backup trigger and status check
export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const action = searchParams.get('action');

    if (action === 'status') {
      // Return backup status
      const result = await sql`
        SELECT * FROM backup_logs 
        ORDER BY created_at DESC 
        LIMIT 10
      `;

      return NextResponse.json({
        success: true,
        recentBackups: result.rows
      });
    }

    // Manual backup trigger
    return POST(request);
    
  } catch (error: any) {
    return NextResponse.json({
      success: false,
      message: 'Failed to process request',
      error: error.message
    }, { status: 500 });
  }
}