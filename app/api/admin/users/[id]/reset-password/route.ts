import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/db';

// POST - Reset user password (admin only)
export async function POST(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    const { newPassword } = await request.json();

    if (!newPassword) {
      return NextResponse.json(
        { success: false, message: 'New password is required' },
        { status: 400 }
      );
    }

    if (newPassword.length < 6) {
      return NextResponse.json(
        { success: false, message: 'Password must be at least 6 characters long' },
        { status: 400 }
      );
    }

    // Check if user exists
    const [user]: any = await db.query('SELECT id, username FROM users WHERE id = ?', [id]);

    if (user.length === 0) {
      return NextResponse.json(
        { success: false, message: 'User not found' },
        { status: 404 }
      );
    }

    // Update password - store as plain text for now (in production, this should be hashed!)
    await db.query('UPDATE users SET password_hash = ? WHERE id = ?', [newPassword, id]);

    return NextResponse.json({
      success: true,
      message: `Password reset successfully for user ${user[0].username}`,
      newPassword: newPassword
    });
  } catch (error: any) {
    console.error('Reset password error:', error);
    return NextResponse.json(
      { success: false, message: error.message || 'Failed to reset password' },
      { status: 500 }
    );
  }
}