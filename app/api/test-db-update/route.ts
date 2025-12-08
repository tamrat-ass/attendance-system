import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/db';

// Simple test to verify database updates work
export async function GET(request: NextRequest) {
  try {
    // Test 1: Check if user exists
    const [users]: any = await db.query('SELECT * FROM users WHERE id = 2');
    
    if (users.length === 0) {
      return NextResponse.json({
        success: false,
        message: 'User ID 2 not found'
      });
    }

    const before = users[0];

    // Test 2: Try to update
    const [updateResult]: any = await db.query(
      'UPDATE users SET can_manage_students = 0 WHERE id = 2'
    );

    // Test 3: Verify update
    const [afterUsers]: any = await db.query('SELECT * FROM users WHERE id = 2');
    const after = afterUsers[0];

    return NextResponse.json({
      success: true,
      message: 'Database update test completed',
      before: {
        id: before.id,
        username: before.username,
        can_manage_students: before.can_manage_students
      },
      after: {
        id: after.id,
        username: after.username,
        can_manage_students: after.can_manage_students
      },
      affectedRows: updateResult.affectedRows,
      changed: before.can_manage_students !== after.can_manage_students
    });
  } catch (error: any) {
    return NextResponse.json({
      success: false,
      error: error.message,
      code: error.code,
      sqlMessage: error.sqlMessage
    }, { status: 500 });
  }
}
