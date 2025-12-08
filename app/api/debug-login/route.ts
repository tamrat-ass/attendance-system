import { NextRequest, NextResponse } from 'next/server';
import { sql } from '@vercel/postgres';

export async function GET() {
  try {
    // Test basic connection
    const timeResult = await sql`SELECT NOW() as current_time`;
    
    // Check if users table exists and has data
    const usersResult = await sql`SELECT COUNT(*) as count FROM users`;
    
    // Try to find the manager user specifically
    const managerResult = await sql`
      SELECT username, password_hash, role, status 
      FROM users 
      WHERE username = 'manager'
    `;
    
    return NextResponse.json({
      success: true,
      database_time: timeResult.rows[0].current_time,
      total_users: usersResult.rows[0].count,
      manager_user: managerResult.rows[0] || 'Not found',
      message: 'Database connection working'
    });
    
  } catch (error: any) {
    return NextResponse.json({
      success: false,
      error: error.message,
      stack: error.stack
    }, { status: 500 });
  }
}

export async function POST(request: NextRequest) {
  try {
    const { username, password } = await request.json();
    
    // Debug the exact query
    const result = await sql`
      SELECT id, username, password_hash, role, status
      FROM users 
      WHERE username = ${username}
    `;
    
    return NextResponse.json({
      success: true,
      found_user: result.rows[0] || 'No user found',
      provided_password: password,
      query_result_count: result.rows.length
    });
    
  } catch (error: any) {
    return NextResponse.json({
      success: false,
      error: error.message,
      stack: error.stack
    }, { status: 500 });
  }
}
