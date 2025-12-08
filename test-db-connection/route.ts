import { NextRequest, NextResponse } from 'next/server';
import { sql } from '@vercel/postgres';

export async function GET() {
  try {
    // Test basic connection
    const result = await sql`SELECT NOW() as current_time`;
    
    // Test if users table exists
    let usersExist = false;
    let userCount = 0;
    
    try {
      const usersResult = await sql`SELECT COUNT(*) as count FROM users`;
      usersExist = true;
      userCount = usersResult.rows[0].count;
    } catch (error) {
      console.log('Users table does not exist:', error);
    }

    return NextResponse.json({
      success: true,
      message: 'Database connection successful',
      data: {
        currentTime: result.rows[0].current_time,
        usersTableExists: usersExist,
        userCount: userCount
      }
    });
  } catch (error: any) {
    console.error('Database connection error:', error);
    return NextResponse.json({
      success: false,
      message: 'Database connection failed',
      error: error.message
    }, { status: 500 });
  }
}
