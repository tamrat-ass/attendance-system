import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/db';

// GET - Fetch user logs (all users)
export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const limit = searchParams.get('limit') || '100';
    const userId = searchParams.get('userId');
    const action = searchParams.get('action');

    let query = `
      SELECT l.*, u.full_name, u.role 
      FROM user_logs l
      LEFT JOIN users u ON l.user_id = u.id
      WHERE 1=1
    `;
    const params: any[] = [];

    if (userId) {
      query += ' AND l.user_id = ?';
      params.push(userId);
    }

    if (action) {
      query += ' AND l.action = ?';
      params.push(action);
    }

    query += ' ORDER BY l.created_at DESC LIMIT ?';
    params.push(parseInt(limit));

    const [logs] = await db.query(query, params);

    return NextResponse.json({
      success: true,
      data: logs
    });
  } catch (error: any) {
    console.error('Get logs error:', error);
    return NextResponse.json(
      { success: false, message: error.message || 'Failed to fetch logs' },
      { status: 500 }
    );
  }
}

// POST - Create a log entry
export async function POST(request: NextRequest) {
  try {
    const { user_id, username, action, target_type, target_id, details } = await request.json();

    if (!user_id || !username || !action) {
      return NextResponse.json(
        { success: false, message: 'user_id, username, and action are required' },
        { status: 400 }
      );
    }

    // Get IP address
    const ip_address = request.headers.get('x-forwarded-for') || 
                       request.headers.get('x-real-ip') || 
                       'unknown';

    await db.query(
      `INSERT INTO user_logs (user_id, username, action, target_type, target_id, details, ip_address) 
       VALUES (?, ?, ?, ?, ?, ?, ?)`,
      [user_id, username, action, target_type || null, target_id || null, details || null, ip_address]
    );

    return NextResponse.json({
      success: true,
      message: 'Log created successfully'
    });
  } catch (error: any) {
    console.error('Create log error:', error);
    return NextResponse.json(
      { success: false, message: error.message || 'Failed to create log' },
      { status: 500 }
    );
  }
}
