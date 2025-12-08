import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/db';

// Test endpoint to check permissions
export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const userId = searchParams.get('userId');

    if (!userId) {
      return NextResponse.json(
        { success: false, message: 'userId parameter required' },
        { status: 400 }
      );
    }

    const [users]: any = await db.query(
      `SELECT id, username, role, 
       can_manage_students, can_mark_attendance, can_view_reports,
       can_export_data, can_manage_users
       FROM users WHERE id = ?`,
      [userId]
    );

    if (users.length === 0) {
      return NextResponse.json(
        { success: false, message: 'User not found' },
        { status: 404 }
      );
    }

    return NextResponse.json({
      success: true,
      user: users[0]
    });
  } catch (error: any) {
    console.error('Test permissions error:', error);
    return NextResponse.json(
      { success: false, message: error.message },
      { status: 500 }
    );
  }
}

// Test endpoint to manually update permissions
export async function POST(request: NextRequest) {
  try {
    const { userId, permissions } = await request.json();

    if (!userId) {
      return NextResponse.json(
        { success: false, message: 'userId required' },
        { status: 400 }
      );
    }

    await db.query(
      `UPDATE users SET 
       can_manage_students = ?,
       can_mark_attendance = ?,
       can_view_reports = ?,
       can_export_data = ?,
       can_manage_users = ?
       WHERE id = ?`,
      [
        permissions.can_manage_students ? 1 : 0,
        permissions.can_mark_attendance ? 1 : 0,
        permissions.can_view_reports ? 1 : 0,
        permissions.can_export_data ? 1 : 0,
        permissions.can_manage_users ? 1 : 0,
        userId
      ]
    );

    // Fetch updated user
    const [users]: any = await db.query(
      `SELECT id, username, role, 
       can_manage_students, can_mark_attendance, can_view_reports,
       can_export_data, can_manage_users
       FROM users WHERE id = ?`,
      [userId]
    );

    return NextResponse.json({
      success: true,
      message: 'Permissions updated',
      user: users[0]
    });
  } catch (error: any) {
    console.error('Test update error:', error);
    return NextResponse.json(
      { success: false, message: error.message },
      { status: 500 }
    );
  }
}
