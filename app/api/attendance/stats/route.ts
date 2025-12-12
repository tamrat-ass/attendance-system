import { NextResponse } from "next/server";
import { db } from "@/lib/db";

// GET - Get attendance statistics
export async function GET(req: Request) {
  try {
    const { searchParams } = new URL(req.url);
    const startDate = searchParams.get("start_date");
    const endDate = searchParams.get("end_date");
    const className = searchParams.get("class");

    console.log('📈 Get Attendance Stats:', { startDate, endDate, className });

    let sql = `
      SELECT 
        COUNT(*) as total_records,
        COUNT(CASE WHEN status = 'present' THEN 1 END) as present_count,
        COUNT(CASE WHEN status = 'absent' THEN 1 END) as absent_count,
        COUNT(CASE WHEN status = 'late' THEN 1 END) as late_count,
        COUNT(CASE WHEN status = 'permission' THEN 1 END) as permission_count,
        COUNT(DISTINCT student_id) as unique_students,
        COUNT(DISTINCT date) as unique_dates,
        MIN(date) as earliest_date,
        MAX(date) as latest_date
      FROM attendance a
      JOIN students s ON a.student_id = s.id
      WHERE 1=1
    `;
    const values: any[] = [];

    if (startDate && endDate) {
      sql += " AND a.date BETWEEN ? AND ?";
      values.push(startDate, endDate);
    } else if (startDate) {
      sql += " AND a.date >= ?";
      values.push(startDate);
    } else if (endDate) {
      sql += " AND a.date <= ?";
      values.push(endDate);
    }

    if (className) {
      sql += " AND s.class = ?";
      values.push(className);
    }

    console.log('🔍 Stats SQL:', sql);
    console.log('📊 Values:', values);

    const [statsRows]: any = await db.query(sql, values);
    const stats = statsRows[0];

    // Calculate percentages
    const totalRecords = parseInt(stats.total_records) || 0;
    const presentCount = parseInt(stats.present_count) || 0;
    const absentCount = parseInt(stats.absent_count) || 0;
    const lateCount = parseInt(stats.late_count) || 0;
    const permissionCount = parseInt(stats.permission_count) || 0;

    const attendanceRate = totalRecords > 0 ? 
      Math.round(((presentCount + lateCount) / totalRecords) * 100) : 0;
    const absenteeRate = totalRecords > 0 ? 
      Math.round((absentCount / totalRecords) * 100) : 0;

    // Get daily breakdown
    let dailySql = `
      SELECT 
        date,
        COUNT(*) as total,
        COUNT(CASE WHEN status = 'present' THEN 1 END) as present,
        COUNT(CASE WHEN status = 'absent' THEN 1 END) as absent,
        COUNT(CASE WHEN status = 'late' THEN 1 END) as late,
        COUNT(CASE WHEN status = 'permission' THEN 1 END) as permission
      FROM attendance a
      JOIN students s ON a.student_id = s.id
      WHERE 1=1
    `;
    const dailyValues: any[] = [];

    if (startDate && endDate) {
      dailySql += " AND a.date BETWEEN ? AND ?";
      dailyValues.push(startDate, endDate);
    } else if (startDate) {
      dailySql += " AND a.date >= ?";
      dailyValues.push(startDate);
    } else if (endDate) {
      dailySql += " AND a.date <= ?";
      dailyValues.push(endDate);
    }

    if (className) {
      dailySql += " AND s.class = ?";
      dailyValues.push(className);
    }

    dailySql += " GROUP BY date ORDER BY date DESC LIMIT 30";

    const [dailyRows]: any = await db.query(dailySql, dailyValues);

    console.log('✅ Attendance Stats Retrieved:', { 
      totalRecords, 
      attendanceRate, 
      dailyBreakdown: dailyRows.length 
    });

    return NextResponse.json({
      success: true,
      message: "Attendance statistics retrieved successfully",
      period: {
        start_date: startDate,
        end_date: endDate,
        class: className
      },
      summary: {
        total_records: totalRecords,
        unique_students: parseInt(stats.unique_students) || 0,
        unique_dates: parseInt(stats.unique_dates) || 0,
        earliest_date: stats.earliest_date,
        latest_date: stats.latest_date,
        attendance_rate: attendanceRate,
        absentee_rate: absenteeRate
      },
      breakdown: {
        present: presentCount,
        absent: absentCount,
        late: lateCount,
        permission: permissionCount
      },
      daily_breakdown: dailyRows
    });
  } catch (error: any) {
    console.error('❌ Get Attendance Stats Error:', error);
    return NextResponse.json(
      { 
        success: false,
        message: "Error retrieving attendance statistics", 
        error: error.message 
      },
      { status: 500 }
    );
  }
}