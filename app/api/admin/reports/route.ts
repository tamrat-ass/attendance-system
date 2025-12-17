import { NextRequest, NextResponse } from 'next/server';
import { sql } from '@vercel/postgres';

export async function GET(request: NextRequest) {
  try {
    const { searchParams } = new URL(request.url);
    const reportType = searchParams.get('type');
    const startDate = searchParams.get('start_date');
    const endDate = searchParams.get('end_date');
    const classFilter = searchParams.get('class');

    // Validate required parameters
    if (!reportType) {
      return NextResponse.json(
        { success: false, message: 'Report type is required' },
        { status: 400 }
      );
    }

    switch (reportType) {
      case 'summary':
        return await getSummaryReport(startDate, endDate, classFilter);
      case 'detailed':
        return await getDetailedReport(startDate, endDate, classFilter);
      case 'class-performance':
        return await getClassPerformanceReport(startDate, endDate);
      case 'student-analytics':
        return await getStudentAnalyticsReport(startDate, endDate, classFilter);
      case 'attendance-trends':
        return await getAttendanceTrendsReport(startDate, endDate);
      case 'user-activity':
        return await getUserActivityReport(startDate, endDate);
      default:
        return NextResponse.json(
          { success: false, message: 'Invalid report type' },
          { status: 400 }
        );
    }
  } catch (error: any) {
    console.error('Admin reports error:', error);
    return NextResponse.json(
      { success: false, message: 'Failed to generate report', error: error.message },
      { status: 500 }
    );
  }
}

// Summary Report - Overall statistics
async function getSummaryReport(startDate?: string | null, endDate?: string | null, classFilter?: string | null) {
  try {
    let dateFilter = '';
    let classFilterSql = '';
    const params: any[] = [];

    if (startDate && endDate) {
      dateFilter = 'AND a.date BETWEEN $1 AND $2';
      params.push(startDate, endDate);
    }

    if (classFilter) {
      classFilterSql = `AND s.class = $${params.length + 1}`;
      params.push(classFilter);
    }

    // Overall statistics
    const overallStats = await sql`
      SELECT 
        COUNT(DISTINCT s.id) as total_students,
        COUNT(DISTINCT s.class) as total_classes,
        COUNT(a.id) as total_attendance_records,
        COUNT(CASE WHEN a.status = 'present' THEN 1 END) as present_count,
        COUNT(CASE WHEN a.status = 'absent' THEN 1 END) as absent_count,
        COUNT(CASE WHEN a.status = 'late' THEN 1 END) as late_count,
        COUNT(CASE WHEN a.status = 'permission' THEN 1 END) as permission_count,
        ROUND(
          (COUNT(CASE WHEN a.status = 'present' THEN 1 END) * 100.0 / 
           NULLIF(COUNT(a.id), 0)), 2
        ) as overall_attendance_rate
      FROM students s
      LEFT JOIN attendance a ON s.id = a.student_id
      WHERE s.status = 'active'
      ${dateFilter ? `AND a.date BETWEEN '${startDate}' AND '${endDate}'` : ''}
      ${classFilter ? `AND s.class = '${classFilter}'` : ''}
    `;

    // Class breakdown
    const classBreakdown = await sql`
      SELECT 
        s.class,
        COUNT(DISTINCT s.id) as student_count,
        COUNT(a.id) as total_records,
        COUNT(CASE WHEN a.status = 'present' THEN 1 END) as present_count,
        COUNT(CASE WHEN a.status = 'absent' THEN 1 END) as absent_count,
        ROUND(
          (COUNT(CASE WHEN a.status = 'present' THEN 1 END) * 100.0 / 
           NULLIF(COUNT(a.id), 0)), 2
        ) as attendance_rate
      FROM students s
      LEFT JOIN attendance a ON s.id = a.student_id
      WHERE s.status = 'active'
      ${dateFilter ? `AND a.date BETWEEN '${startDate}' AND '${endDate}'` : ''}
      ${classFilter ? `AND s.class = '${classFilter}'` : ''}
      GROUP BY s.class
      ORDER BY s.class
    `;

    // Daily trends (last 30 days or date range)
    const trendsQuery = startDate && endDate ? 
      `AND a.date BETWEEN '${startDate}' AND '${endDate}'` :
      `AND a.date >= CURRENT_DATE - INTERVAL '30 days'`;

    const dailyTrends = await sql`
      SELECT 
        a.date,
        COUNT(CASE WHEN a.status = 'present' THEN 1 END) as present_count,
        COUNT(CASE WHEN a.status = 'absent' THEN 1 END) as absent_count,
        COUNT(CASE WHEN a.status = 'late' THEN 1 END) as late_count,
        COUNT(CASE WHEN a.status = 'permission' THEN 1 END) as permission_count,
        COUNT(a.id) as total_records
      FROM attendance a
      JOIN students s ON a.student_id = s.id
      WHERE s.status = 'active'
      ${trendsQuery}
      ${classFilter ? `AND s.class = '${classFilter}'` : ''}
      GROUP BY a.date
      ORDER BY a.date DESC
      LIMIT 30
    `;

    return NextResponse.json({
      success: true,
      data: {
        overall: overallStats.rows[0],
        classes: classBreakdown.rows,
        trends: dailyTrends.rows,
        dateRange: { startDate, endDate },
        classFilter
      }
    });
  } catch (error: any) {
    throw new Error(`Summary report error: ${error.message}`);
  }
}

// Detailed Report - Student-level data
async function getDetailedReport(startDate?: string | null, endDate?: string | null, classFilter?: string | null) {
  try {
    let dateFilter = '';
    let classFilterSql = '';

    if (startDate && endDate) {
      dateFilter = `AND a.date BETWEEN '${startDate}' AND '${endDate}'`;
    }

    if (classFilter) {
      classFilterSql = `AND s.class = '${classFilter}'`;
    }

    const detailedData = await sql`
      SELECT 
        s.id,
        s.full_name,
        s.phone,
        s.class,
        s.gender,
        COUNT(a.id) as total_days,
        COUNT(CASE WHEN a.status = 'present' THEN 1 END) as present_days,
        COUNT(CASE WHEN a.status = 'absent' THEN 1 END) as absent_days,
        COUNT(CASE WHEN a.status = 'late' THEN 1 END) as late_days,
        COUNT(CASE WHEN a.status = 'permission' THEN 1 END) as permission_days,
        ROUND(
          (COUNT(CASE WHEN a.status = 'present' THEN 1 END) * 100.0 / 
           NULLIF(COUNT(a.id), 0)), 2
        ) as attendance_rate,
        ROUND(
          ((COUNT(CASE WHEN a.status = 'present' THEN 1 END) + 
            COUNT(CASE WHEN a.status = 'permission' THEN 1 END)) * 100.0 / 
           NULLIF(COUNT(a.id), 0)), 2
        ) as effective_attendance_rate,
        MIN(a.date) as first_attendance_date,
        MAX(a.date) as last_attendance_date
      FROM students s
      LEFT JOIN attendance a ON s.id = a.student_id
      WHERE s.status = 'active'
      ${dateFilter}
      ${classFilterSql}
      GROUP BY s.id, s.full_name, s.phone, s.class, s.gender
      HAVING COUNT(a.id) > 0
      ORDER BY s.class, s.full_name
    `;

    return NextResponse.json({
      success: true,
      data: {
        students: detailedData.rows,
        dateRange: { startDate, endDate },
        classFilter,
        totalStudents: detailedData.rows.length
      }
    });
  } catch (error: any) {
    throw new Error(`Detailed report error: ${error.message}`);
  }
}

// Class Performance Report
async function getClassPerformanceReport(startDate?: string | null, endDate?: string | null) {
  try {
    let dateFilter = '';
    if (startDate && endDate) {
      dateFilter = `AND a.date BETWEEN '${startDate}' AND '${endDate}'`;
    }

    const classPerformance = await sql`
      SELECT 
        s.class,
        COUNT(DISTINCT s.id) as total_students,
        COUNT(a.id) as total_attendance_records,
        COUNT(CASE WHEN a.status = 'present' THEN 1 END) as present_count,
        COUNT(CASE WHEN a.status = 'absent' THEN 1 END) as absent_count,
        COUNT(CASE WHEN a.status = 'late' THEN 1 END) as late_count,
        COUNT(CASE WHEN a.status = 'permission' THEN 1 END) as permission_count,
        ROUND(AVG(CASE WHEN a.status = 'present' THEN 100.0 ELSE 0.0 END), 2) as avg_attendance_rate,
        COUNT(DISTINCT a.date) as days_with_attendance,
        -- Students with perfect attendance
        COUNT(DISTINCT CASE 
          WHEN student_stats.absent_count = 0 AND student_stats.late_count = 0 
          THEN s.id 
        END) as perfect_attendance_students,
        -- Students with poor attendance (< 70%)
        COUNT(DISTINCT CASE 
          WHEN student_stats.attendance_rate < 70 
          THEN s.id 
        END) as poor_attendance_students
      FROM students s
      LEFT JOIN attendance a ON s.id = a.student_id
      LEFT JOIN (
        SELECT 
          student_id,
          COUNT(CASE WHEN status = 'absent' THEN 1 END) as absent_count,
          COUNT(CASE WHEN status = 'late' THEN 1 END) as late_count,
          ROUND(
            (COUNT(CASE WHEN status = 'present' THEN 1 END) * 100.0 / 
             NULLIF(COUNT(*), 0)), 2
          ) as attendance_rate
        FROM attendance
        WHERE 1=1 ${dateFilter}
        GROUP BY student_id
      ) student_stats ON s.id = student_stats.student_id
      WHERE s.status = 'active'
      ${dateFilter}
      GROUP BY s.class
      ORDER BY avg_attendance_rate DESC
    `;

    return NextResponse.json({
      success: true,
      data: {
        classes: classPerformance.rows,
        dateRange: { startDate, endDate }
      }
    });
  } catch (error: any) {
    throw new Error(`Class performance report error: ${error.message}`);
  }
}

// Student Analytics Report
async function getStudentAnalyticsReport(startDate?: string | null, endDate?: string | null, classFilter?: string | null) {
  try {
    let dateFilter = '';
    let classFilterSql = '';

    if (startDate && endDate) {
      dateFilter = `AND a.date BETWEEN '${startDate}' AND '${endDate}'`;
    }

    if (classFilter) {
      classFilterSql = `AND s.class = '${classFilter}'`;
    }

    // Top performers
    const topPerformers = await sql`
      SELECT 
        s.id,
        s.full_name,
        s.class,
        COUNT(a.id) as total_days,
        COUNT(CASE WHEN a.status = 'present' THEN 1 END) as present_days,
        ROUND(
          (COUNT(CASE WHEN a.status = 'present' THEN 1 END) * 100.0 / 
           NULLIF(COUNT(a.id), 0)), 2
        ) as attendance_rate
      FROM students s
      JOIN attendance a ON s.id = a.student_id
      WHERE s.status = 'active'
      ${dateFilter}
      ${classFilterSql}
      GROUP BY s.id, s.full_name, s.class
      HAVING COUNT(a.id) >= 5 AND attendance_rate >= 90
      ORDER BY attendance_rate DESC, present_days DESC
      LIMIT 20
    `;

    // Students needing attention
    const needsAttention = await sql`
      SELECT 
        s.id,
        s.full_name,
        s.class,
        s.phone,
        COUNT(a.id) as total_days,
        COUNT(CASE WHEN a.status = 'absent' THEN 1 END) as absent_days,
        COUNT(CASE WHEN a.status = 'late' THEN 1 END) as late_days,
        ROUND(
          (COUNT(CASE WHEN a.status = 'present' THEN 1 END) * 100.0 / 
           NULLIF(COUNT(a.id), 0)), 2
        ) as attendance_rate,
        -- Recent absence streak
        (
          SELECT COUNT(*)
          FROM attendance a2
          WHERE a2.student_id = s.id 
          AND a2.status = 'absent'
          AND a2.date >= (
            SELECT MAX(date) - INTERVAL '7 days'
            FROM attendance a3
            WHERE a3.student_id = s.id
          )
        ) as recent_absences
      FROM students s
      JOIN attendance a ON s.id = a.student_id
      WHERE s.status = 'active'
      ${dateFilter}
      ${classFilterSql}
      GROUP BY s.id, s.full_name, s.class, s.phone
      HAVING attendance_rate < 70 OR recent_absences >= 3
      ORDER BY attendance_rate ASC, recent_absences DESC
      LIMIT 20
    `;

    // Gender-based analytics
    const genderAnalytics = await sql`
      SELECT 
        s.gender,
        COUNT(DISTINCT s.id) as student_count,
        COUNT(a.id) as total_records,
        ROUND(AVG(CASE WHEN a.status = 'present' THEN 100.0 ELSE 0.0 END), 2) as avg_attendance_rate,
        COUNT(CASE WHEN a.status = 'late' THEN 1 END) as total_late_instances
      FROM students s
      LEFT JOIN attendance a ON s.id = a.student_id
      WHERE s.status = 'active'
      ${dateFilter}
      ${classFilterSql}
      GROUP BY s.gender
      ORDER BY s.gender
    `;

    return NextResponse.json({
      success: true,
      data: {
        topPerformers: topPerformers.rows,
        needsAttention: needsAttention.rows,
        genderAnalytics: genderAnalytics.rows,
        dateRange: { startDate, endDate },
        classFilter
      }
    });
  } catch (error: any) {
    throw new Error(`Student analytics report error: ${error.message}`);
  }
}

// Attendance Trends Report
async function getAttendanceTrendsReport(startDate?: string | null, endDate?: string | null) {
  try {
    let dateFilter = '';
    if (startDate && endDate) {
      dateFilter = `AND date BETWEEN '${startDate}' AND '${endDate}'`;
    } else {
      // Default to last 60 days
      dateFilter = `AND date >= CURRENT_DATE - INTERVAL '60 days'`;
    }

    // Daily trends
    const dailyTrends = await sql`
      SELECT 
        date,
        COUNT(CASE WHEN status = 'present' THEN 1 END) as present_count,
        COUNT(CASE WHEN status = 'absent' THEN 1 END) as absent_count,
        COUNT(CASE WHEN status = 'late' THEN 1 END) as late_count,
        COUNT(CASE WHEN status = 'permission' THEN 1 END) as permission_count,
        COUNT(*) as total_records,
        ROUND(
          (COUNT(CASE WHEN status = 'present' THEN 1 END) * 100.0 / 
           NULLIF(COUNT(*), 0)), 2
        ) as daily_attendance_rate
      FROM attendance
      WHERE 1=1 ${dateFilter}
      GROUP BY date
      ORDER BY date
    `;

    // Weekly patterns (day of week analysis)
    const weeklyPatterns = await sql`
      SELECT 
        EXTRACT(DOW FROM date) as day_of_week,
        CASE EXTRACT(DOW FROM date)
          WHEN 0 THEN 'Sunday'
          WHEN 1 THEN 'Monday'
          WHEN 2 THEN 'Tuesday'
          WHEN 3 THEN 'Wednesday'
          WHEN 4 THEN 'Thursday'
          WHEN 5 THEN 'Friday'
          WHEN 6 THEN 'Saturday'
        END as day_name,
        COUNT(*) as total_records,
        ROUND(AVG(CASE WHEN status = 'present' THEN 100.0 ELSE 0.0 END), 2) as avg_attendance_rate,
        COUNT(CASE WHEN status = 'late' THEN 1 END) as late_instances
      FROM attendance
      WHERE 1=1 ${dateFilter}
      GROUP BY EXTRACT(DOW FROM date)
      ORDER BY day_of_week
    `;

    return NextResponse.json({
      success: true,
      data: {
        dailyTrends: dailyTrends.rows,
        weeklyPatterns: weeklyPatterns.rows,
        dateRange: { startDate, endDate }
      }
    });
  } catch (error: any) {
    throw new Error(`Attendance trends report error: ${error.message}`);
  }
}

// User Activity Report (Admin only)
async function getUserActivityReport(startDate?: string | null, endDate?: string | null) {
  try {
    let dateFilter = '';
    if (startDate && endDate) {
      dateFilter = `AND DATE(created_at) BETWEEN '${startDate}' AND '${endDate}'`;
    } else {
      // Default to last 30 days
      dateFilter = `AND created_at >= CURRENT_DATE - INTERVAL '30 days'`;
    }

    // User activity logs
    const userActivity = await sql`
      SELECT 
        ul.username,
        u.full_name,
        u.role,
        COUNT(*) as total_actions,
        COUNT(CASE WHEN ul.action = 'LOGIN' THEN 1 END) as login_count,
        COUNT(CASE WHEN ul.action LIKE '%ATTENDANCE%' THEN 1 END) as attendance_actions,
        COUNT(CASE WHEN ul.action LIKE '%STUDENT%' THEN 1 END) as student_actions,
        MAX(ul.created_at) as last_activity,
        MIN(ul.created_at) as first_activity
      FROM user_logs ul
      LEFT JOIN users u ON ul.username = u.username
      WHERE 1=1 ${dateFilter}
      GROUP BY ul.username, u.full_name, u.role
      ORDER BY total_actions DESC
    `;

    // Daily activity summary
    const dailyActivity = await sql`
      SELECT 
        DATE(created_at) as activity_date,
        COUNT(*) as total_actions,
        COUNT(DISTINCT username) as active_users,
        COUNT(CASE WHEN action = 'LOGIN' THEN 1 END) as login_count,
        COUNT(CASE WHEN action LIKE '%ATTENDANCE%' THEN 1 END) as attendance_actions
      FROM user_logs
      WHERE 1=1 ${dateFilter}
      GROUP BY DATE(created_at)
      ORDER BY activity_date DESC
    `;

    return NextResponse.json({
      success: true,
      data: {
        userActivity: userActivity.rows,
        dailyActivity: dailyActivity.rows,
        dateRange: { startDate, endDate }
      }
    });
  } catch (error: any) {
    throw new Error(`User activity report error: ${error.message}`);
  }
}