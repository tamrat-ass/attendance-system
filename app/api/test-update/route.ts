import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/db';

// Simple test to update user 2 (manager) permissions
export async function GET(request: NextRequest) {
  try {
    // First, check current values
    const [before]: any = await db.query(
      'SELECT * FROM users WHERE id = 2'
    );

    // Update with specific values
    await db.query(
      `UPDATE users SET 
       can_manage_students = 0,
       can_mark_attendance = 1,
       can_view_reports = 1,
       can_export_data = 0,
       can_manage_users = 0
       WHERE id = 2`
    );

    // Check after update
    const [after]: any = await db.query(
      'SELECT * FROM users WHERE id = 2'
    );

    return NextResponse.json({
      success: true,
      before: before[0],
      after: after[0],
      message: 'Test update completed'
    });
  } catch (error: any) {
    return NextResponse.json({
      success: false,
      error: error.message,
      stack: error.stack
    }, { status: 500 });
  }
}
