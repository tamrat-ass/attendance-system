import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/db';

// Fix the can_update_student permission
export async function POST(request: NextRequest) {
  try {
    // Check if column exists
    const [columns]: any = await db.query(
      `SELECT COLUMN_NAME 
       FROM INFORMATION_SCHEMA.COLUMNS 
       WHERE TABLE_NAME = 'users' 
       AND COLUMN_NAME = 'can_update_student'`
    );

    if (columns.length === 0) {
      // Add the column if it doesn't exist
      await db.query(
        `ALTER TABLE users 
         ADD COLUMN can_update_student BOOLEAN DEFAULT TRUE`
      );
      console.log('Added can_update_student column');
    }

    // Update all users to have the permission
    await db.query(
      `UPDATE users 
       SET can_update_student = TRUE 
       WHERE can_update_student IS NULL OR can_update_student = FALSE`
    );

    // Get updated user data
    const [users]: any = await db.query(
      `SELECT id, username, role, can_update_student 
       FROM users 
       ORDER BY id`
    );

    return NextResponse.json({
      success: true,
      message: 'can_update_student permission fixed for all users',
      users: users
    });
  } catch (error: any) {
    console.error('Fix permission error:', error);
    return NextResponse.json(
      { success: false, message: error.message },
      { status: 500 }
    );
  }
}