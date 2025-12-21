import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/db';
import bcrypt from 'bcryptjs';

export async function POST(request: NextRequest) {
  try {
    const { userId, currentPassword, newPassword } = await request.json();

    if (!userId || !currentPassword || !newPassword) {
      return NextResponse.json(
        { error: 'All fields are required' },
        { status: 400 }
      );
    }

    if (newPassword.length < 6) {
      return NextResponse.json(
        { error: 'New password must be at least 6 characters' },
        { status: 400 }
      );
    }

    // Get current user
    const [users]: any = await db.query(
      'SELECT id, username, password_hash FROM users WHERE id = ?',
      [userId]
    );

    if (users.length === 0) {
      return NextResponse.json(
        { error: 'User not found' },
        { status: 404 }
      );
    }

    const user = users[0];

    // Verify current password using bcrypt
    const passwordMatch = await bcrypt.compare(currentPassword, user.password_hash);
    if (!passwordMatch) {
      return NextResponse.json(
        { error: 'Current password is incorrect' },
        { status: 401 }
      );
    }

    // Hash the new password
    const hashedNewPassword = await bcrypt.hash(newPassword, 12);

    // Update password with hashed version
    await db.query(
      'UPDATE users SET password_hash = ? WHERE id = ?',
      [hashedNewPassword, userId]
    );

    // Log the password change
    try {
      await db.query(
        `INSERT INTO user_logs (user_id, username, action, details) 
         VALUES (?, ?, ?, ?)`,
        [user.id, user.username, 'PASSWORD_CHANGE', 'User changed their password']
      );
    } catch (logError) {
      console.error('Failed to log password change:', logError);
    }

    return NextResponse.json({
      success: true,
      message: 'Password changed successfully'
    });
  } catch (error: any) {
    console.error('Change password error:', error);
    return NextResponse.json(
      { error: 'Failed to change password' },
      { status: 500 }
    );
  }
}
