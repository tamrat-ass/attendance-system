import { NextResponse } from 'next/server';
import { sql } from '@vercel/postgres';

export async function GET() {
  try {
    // Test 1: Database connection
    console.log('Testing database connection...');
    const dbTest = await sql`SELECT 1 as test`;
    console.log('Database test result:', dbTest.rows);

    // Test 2: Environment variables
    const envTest = {
      GOOGLE_SPREADSHEET_ID: process.env.GOOGLE_SPREADSHEET_ID ? 'Set' : 'Missing',
      GOOGLE_SERVICE_ACCOUNT_KEY: process.env.GOOGLE_SERVICE_ACCOUNT_KEY ? 'Set' : 'Missing',
      BACKUP_API_KEY: process.env.BACKUP_API_KEY ? 'Set' : 'Missing',
    };

    // Test 3: JSON parsing
    let jsonTest = { valid: false, error: null };
    if (process.env.GOOGLE_SERVICE_ACCOUNT_KEY) {
      try {
        JSON.parse(process.env.GOOGLE_SERVICE_ACCOUNT_KEY);
        jsonTest.valid = true;
      } catch (error: any) {
        jsonTest.error = error.message;
      }
    }

    return NextResponse.json({
      success: true,
      tests: {
        database: 'Connected',
        environment: envTest,
        json: jsonTest
      },
      timestamp: new Date().toISOString()
    });

  } catch (error: any) {
    console.error('Backup test error:', error);
    return NextResponse.json({
      success: false,
      error: error.message,
      stack: error.stack,
      timestamp: new Date().toISOString()
    }, { status: 500 });
  }
}