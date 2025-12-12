import { NextResponse } from 'next/server';
import { db } from '@/lib/db';

export async function GET() {
  try {
    // Check students
    const [students]: any = await db.query('SELECT COUNT(*) as count FROM students');
    
    // Check attendance
    const [attendance]: any = await db.query('SELECT COUNT(*) as count FROM attendance');
    
    // Get sample attendance records
    const [sampleAttendance]: any = await db.query(`
      SELECT a.*, s.full_name, s.class 
      FROM attendance a 
      JOIN students s ON a.student_id = s.id 
      ORDER BY a.date DESC 
      LIMIT 5
    `);
    
    // Get sample students
    const [sampleStudents]: any = await db.query('SELECT * FROM students LIMIT 5');

    return NextResponse.json({
      success: true,
      data: {
        students_count: students[0].count,
        attendance_count: attendance[0].count,
        sample_attendance: sampleAttendance,
        sample_students: sampleStudents
      }
    });
  } catch (error: any) {
    console.error('Test data error:', error);
    return NextResponse.json(
      { success: false, message: error.message },
      { status: 500 }
    );
  }
}