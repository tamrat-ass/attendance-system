import { NextResponse } from 'next/server';
import { db } from '@/lib/db';

// Simple test endpoint to check user data
export async function GET() {
  try {
    const [rows]: any = await db.query(
      'SELECT id, username, role, status FROM users ORDER BY id'
    );

    return NextResponse.json({
      success: true,
      message: 'User data retrieved successfully',
      data: rows,
      timestamp: new Date().toISOString()
    });
  } catch (error: any) {
    return NextResponse.json(
      { success: false, message: error.message },
      { status: 500 }
    );
  }
}