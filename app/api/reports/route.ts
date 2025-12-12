import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/db';

// GET attendance reports
export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const startDate = searchParams.get('start_date');
    const endDate = searchParams.get('end_date');
    const className = searchParams.get('class');

    // Build dynamic SQL for attendance reports - get individual records
    let sql = `
      SELECT 
        a.id,
        a.date,
        a.status,
        a.student_id,
        s.full_name,
        s.class,
        a.created_at
      FROM attendance a
      JOIN students s ON a.student_id = s.id
    `;
    
    const conditions: string[] = [];
    const values: any[] = [];

    if (startDate) {
      conditions.push('a.date >= ?');
      values.push(startDate);
    }

    if (endDate) {
      conditions.push('a.date <= ?');
      values.push(endDate);
    }

    if (className) {
      conditions.push('s.class = ?');
      values.push(className);
    }

    if (conditions.length > 0) {
      sql += ' WHERE ' + conditions.join(' AND ');
    }

    sql += ' ORDER BY a.date DESC, s.full_name ASC';

    const [rows]: any = await db.query(sql, values);

    // Get summary statistics
    const summarySQL = `
      SELECT 
        s.class,
        a.status,
        COUNT(*) as count
      FROM attendance a
      JOIN students s ON a.student_id = s.id
      ${conditions.length > 0 ? 'WHERE ' + conditions.join(' AND ') : ''}
      GROUP BY s.class, a.status
    `;

    const [summaryRows]: any = await db.query(summarySQL, values);

    return NextResponse.json({
      success: true,
      data: {
        attendance: rows,
        summary: summaryRows
      }
    });
  } catch (error: any) {
    console.error('Get reports error:', error);
    return NextResponse.json(
      { success: false, message: error.message || 'Failed to fetch reports' },
      { status: 500 }
    );
  }
}

// GET attendance statistics
export async function POST(request: NextRequest) {
  try {
    const { start_date, end_date, class: className } = await request.json();

    // Get daily attendance statistics
    let sql = `
      SELECT 
        a.date,
        SUM(CASE WHEN a.status = 'present' THEN 1 ELSE 0 END) as present,
        SUM(CASE WHEN a.status = 'absent' THEN 1 ELSE 0 END) as absent,
        SUM(CASE WHEN a.status = 'late' THEN 1 ELSE 0 END) as late,
        SUM(CASE WHEN a.status = 'permission' THEN 1 ELSE 0 END) as permission,
        COUNT(*) as total
      FROM attendance a
      JOIN students s ON a.student_id = s.id
    `;

    const conditions: string[] = [];
    const values: any[] = [];

    if (start_date) {
      conditions.push('a.date >= ?');
      values.push(start_date);
    }

    if (end_date) {
      conditions.push('a.date <= ?');
      values.push(end_date);
    }

    if (className) {
      conditions.push('s.class = ?');
      values.push(className);
    }

    if (conditions.length > 0) {
      sql += ' WHERE ' + conditions.join(' AND ');
    }

    sql += ' GROUP BY a.date ORDER BY a.date ASC';

    const [rows]: any = await db.query(sql, values);

    return NextResponse.json({
      success: true,
      data: rows
    });
  } catch (error: any) {
    console.error('Get statistics error:', error);
    return NextResponse.json(
      { success: false, message: error.message || 'Failed to fetch statistics' },
      { status: 500 }
    );
  }
}