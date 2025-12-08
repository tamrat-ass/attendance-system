import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/db';

export async function POST(request: NextRequest) {
  try {
    const { user_id, username } = await request.json();

    if (user_id && username) {
      // Log the logout action
      const ip_address = request.headers.get('x-forwarded-for') || 
                         request.headers.get('x-real-ip') || 
                         'unknown';
      
      await db.query(
        `INSERT INTO user_logs (user_id, username, action, details, ip_address) 
         VALUES (?, ?, ?, ?, ?)`,
        [user_id, username, 'LOGOUT', 'User logged out', ip_address]
      );
    }

    return NextResponse.json({
      success: true,
      message: 'Logout successful'
    });
  } catch (error: any) {
    console.error('Logout error:', error);
    return NextResponse.json(
      { success: false, message: 'Logout failed' },
      { status: 500 }
    );
  }
}
