import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/db';

// GET admin dashboard statistics
export async function GET() {
  try {
    // Get total counts
    const [studentCount]: any = await db.query('SELECT COUNT(*) as count FROM students');
    const [userCount]: any = await db.query('SELECT COUNT(*) as count FROM users');
    const [attendanceCount]: any = await db.query('SELECT COUNT(*) as count FROM attendance');
    const [classCount]: any = await db.query('SELECT COUNT(DISTINCT class) as count FROM students WHERE class IS NOT NULL AND class != ""');

    // Get recent activity
    const [recentAttendance]: any = await db.query(`
      SELECT 
        s.full_name,
        s.class,
        a.date,
        a.status
      FROM attendance a
      JOIN students s ON a.student_id = s.id
      ORDER BY a.created_at DESC
      LIMIT 10
    `);

    // Get class statistics
    const [classStats]: any = await db.query(`
      SELECT 
        s.class,
        COUNT(DISTINCT s.id) as student_count,
        COUNT(a.id) as attendance_records
      FROM students s
      LEFT JOIN attendance a ON s.id = a.student_id
      WHERE s.class IS NOT NULL AND s.class != ""
      GROUP BY s.class
      ORDER BY student_count DESC
    `);

    // Get attendance statistics by status
    const [statusStats]: any = await db.query(`
      SELECT 
        status,
        COUNT(*) as count
      FROM attendance
      GROUP BY status
    `);

    return NextResponse.json({
      success: true,
      data: {
        totals: {
          students: studentCount[0].count,
          users: userCount[0].count,
          attendance_records: attendanceCount[0].count,
          classes: classCount[0].count
        },
        recent_activity: recentAttendance,
        class_statistics: classStats,
        status_statistics: statusStats
      }
    });
  } catch (error: any) {
    console.error('Get admin stats error:', error);
    return NextResponse.json(
      { success: false, message: error.message || 'Failed to fetch admin statistics' },
      { status: 500 }
    );
  }
}

// POST admin actions (export, sync, etc.)
export async function POST(request: NextRequest) {
  try {
    const { action } = await request.json();

    switch (action) {
      case 'export_all':
        // Get all data for export
        const [students]: any = await db.query('SELECT * FROM students ORDER BY id');
        const [attendance]: any = await db.query(`
          SELECT 
            a.*,
            s.full_name,
            s.class
          FROM attendance a
          JOIN students s ON a.student_id = s.id
          ORDER BY a.date DESC, s.full_name
        `);
        const [users]: any = await db.query('SELECT id, username, full_name, role, status FROM users ORDER BY id');

        return NextResponse.json({
          success: true,
          data: {
            students,
            attendance,
            users,
            exported_at: new Date().toISOString()
          }
        });

      case 'clear_cache':
        // Simulate cache clearing
        return NextResponse.json({
          success: true,
          message: 'Cache cleared successfully'
        });

      case 'sync_data':
        // Simulate data sync
        return NextResponse.json({
          success: true,
          message: 'Data synchronized successfully'
        });

      default:
        return NextResponse.json(
          { success: false, message: 'Unknown action' },
          { status: 400 }
        );
    }
  } catch (error: any) {
    console.error('Admin action error:', error);
    return NextResponse.json(
      { success: false, message: error.message || 'Failed to perform admin action' },
      { status: 500 }
    );
  }
}