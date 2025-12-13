import { NextResponse } from "next/server";
import { db } from "@/lib/db";

// Handle CORS preflight requests
export async function OPTIONS(req: Request) {
  return new NextResponse(null, {
    status: 200,
    headers: {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With',
      'Access-Control-Max-Age': '86400',
    },
  });
}

// UNIFIED GET - Fetch attendance records
export async function GET(req: Request) {
  try {
    const { searchParams } = new URL(req.url);
    const date = searchParams.get("date");
    const studentId = searchParams.get("student_id");
    const classParam = searchParams.get("class");
    const startDate = searchParams.get("start_date");
    const endDate = searchParams.get("end_date");

    console.log('📥 GET Attendance Request:', { date, studentId, classParam, startDate, endDate });

    let sql = `
      SELECT 
        a.id,
        a.student_id,
        a.date,
        a.status,
        a.notes,
        a.created_at,
        a.updated_at,
        s.full_name as student_name,
        s.phone,
        s.class as class_name
      FROM attendance a 
      JOIN students s ON a.student_id = s.id
      WHERE 1=1
    `;
    const values: any[] = [];

    if (date) {
      sql += " AND a.date = ?";
      values.push(date);
    }

    if (studentId) {
      sql += " AND a.student_id = ?";
      values.push(studentId);
    }

    if (classParam) {
      sql += " AND s.class = ?";
      values.push(classParam);
    }

    if (startDate && endDate) {
      sql += " AND a.date BETWEEN ? AND ?";
      values.push(startDate, endDate);
    }

    sql += " ORDER BY a.date DESC, s.full_name ASC";

    console.log('🔍 SQL Query:', sql);
    console.log('📊 Values:', values);

    const [rows]: any = await db.query(sql, values);

    console.log('✅ Query Result:', { count: rows.length, sample: rows[0] });

    return NextResponse.json({
      success: true,
      message: "Attendance records fetched successfully",
      count: rows.length,
      data: rows,
    }, {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With',
      },
    });
  } catch (error: any) {
    console.error('❌ GET Attendance Error:', error);
    return NextResponse.json(
      { 
        success: false,
        message: "Error fetching attendance", 
        error: error.message 
      },
      { 
        status: 500,
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With',
        },
      }
    );
  }
}

// UNIFIED POST - Save attendance records (bulk)
export async function POST(req: Request) {
  try {
    // Check if attendance is locked (Admin Lock System)
    const userAgent = req.headers.get('user-agent') || '';
    const referer = req.headers.get('referer') || '';
    const isWebRequest = referer.includes('vercel.app') || referer.includes('localhost:3000') || 
                        (!userAgent.includes('Dart') && !userAgent.includes('Flutter'));
    
    if (isWebRequest) {
      // Check lock status for web requests
      try {
        const [lockRows]: any = await db.query('SELECT is_locked, locked_by FROM attendance_lock WHERE id = 1');
        if (lockRows.length > 0 && lockRows[0].is_locked) {
          console.log('🔒 Attendance marking blocked - system is locked by admin:', lockRows[0].locked_by);
          return NextResponse.json(
            { 
              success: false,
              message: `Attendance marking is currently locked by administrator: ${lockRows[0].locked_by}. Please contact the admin to unlock attendance marking.`,
              error: "ATTENDANCE_LOCKED",
              locked_by: lockRows[0].locked_by
            },
            { 
              status: 423, // 423 Locked
              headers: {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
                'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With',
              },
            }
          );
        }
      } catch (lockError) {
        // If lock table doesn't exist, continue (system is unlocked)
        console.log('Lock table not found, continuing with unlocked state');
      }
    }

    const body = await req.json();
    const { records } = body; // Array of { student_id, date, status, notes }

    console.log('💾 POST Attendance Request:', { recordCount: records?.length, records });
    
    // Log date formats for sync debugging
    if (records && records.length > 0) {
      const uniqueDates = [...new Set(records.map(r => r.date))];
      console.log('📅 Date formats received:', uniqueDates);
      console.log('📅 Expected format: YYYY-MM-DD (e.g., 2024-12-03)');
    }

    if (!records || !Array.isArray(records) || records.length === 0) {
      return NextResponse.json(
        { 
          success: false,
          message: "No attendance records provided" 
        },
        { 
          status: 400,
          headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With',
          },
        }
      );
    }

    // Validate and prepare records with enhanced duplicate checking
    const validRecords = [];
    const seenStudentDates = new Set();
    const duplicateErrors = [];
    
    for (const record of records) {
      if (!record.student_id || !record.date || !record.status) {
        console.log('⚠️ Invalid record:', record);
        continue;
      }
      
      // Check for duplicates within the same request
      const studentDateKey = `${record.student_id}-${record.date}`;
      if (seenStudentDates.has(studentDateKey)) {
        console.log('❌ Duplicate attendance in same request:', record);
        duplicateErrors.push(`Student ID ${record.student_id} on ${record.date}`);
        continue;
      }
      
      seenStudentDates.add(studentDateKey);
      validRecords.push({
        student_id: parseInt(record.student_id),
        date: record.date,
        status: record.status,
        notes: record.notes || null
      });
    }

    // Return error if duplicates found in request
    if (duplicateErrors.length > 0) {
      return NextResponse.json(
        { 
          success: false,
          message: `Duplicate attendance detected in request: ${duplicateErrors.join(', ')}. Only one attendance record per student per day is allowed.`,
          error: "DUPLICATE_ATTENDANCE_IN_REQUEST",
          duplicates: duplicateErrors
        },
        { 
          status: 400,
          headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With',
          },
        }
      );
    }

    if (validRecords.length === 0) {
      return NextResponse.json(
        { 
          success: false,
          message: "No valid attendance records after validation" 
        },
        { 
          status: 400,
          headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With',
          },
        }
      );
    }

    console.log('✅ Valid records to save:', validRecords);

    // Check for existing attendance records in database before inserting
    const existingCheckPromises = validRecords.map(async (record) => {
      const checkSql = `SELECT id, status FROM attendance WHERE student_id = ? AND date = ?`;
      const [existingRows]: any = await db.query(checkSql, [record.student_id, record.date]);
      return {
        student_id: record.student_id,
        date: record.date,
        exists: existingRows.length > 0,
        currentStatus: existingRows.length > 0 ? existingRows[0].status : null,
        newStatus: record.status
      };
    });

    const existingChecks = await Promise.all(existingCheckPromises);
    const existingRecords = existingChecks.filter(check => check.exists);
    const newRecords = validRecords.filter(record => 
      !existingChecks.find(check => 
        check.student_id === record.student_id && 
        check.date === record.date && 
        check.exists
      )
    );

    console.log('📊 Existing records found:', existingRecords.length);
    console.log('📊 New records to insert:', newRecords.length);

    let insertedCount = 0;
    let updatedCount = 0;

    // Insert new records
    if (newRecords.length > 0) {
      const insertValues: any[] = [];
      const insertPlaceholders: string[] = [];

      for (const record of newRecords) {
        insertPlaceholders.push("(?, ?, ?, ?)");
        insertValues.push(
          record.student_id,
          record.date,
          record.status,
          record.notes
        );
      }

      const insertSql = `
        INSERT INTO attendance (student_id, date, status, notes)
        VALUES ${insertPlaceholders.join(", ")}
      `;

      console.log('💾 Insert SQL:', insertSql);
      console.log('📊 Insert Values:', insertValues);

      try {
        await db.query(insertSql, insertValues);
        insertedCount = newRecords.length;
        console.log('✅ New attendance records inserted:', insertedCount);
      } catch (dbError: any) {
        console.error('❌ Database insert error:', dbError);
        
        // Handle unique constraint violation
        if (dbError.message && (
            dbError.message.includes('duplicate key') || 
            dbError.message.includes('UNIQUE constraint') ||
            dbError.message.includes('Duplicate entry') ||
            dbError.code === '23505' || 
            dbError.code === 'ER_DUP_ENTRY'
          )) {
          return NextResponse.json(
            { 
              success: false,
              message: "Duplicate attendance detected: One or more students already have attendance recorded for this date. Each student can only have one attendance record per day.",
              error: "DUPLICATE_ATTENDANCE_EXISTS",
              hint: "To modify existing attendance, use the update function instead of creating new records."
            },
            { 
              status: 409, // Conflict
              headers: {
                'Access-Control-Allow-Origin': '*',
                'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
                'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With',
              },
            }
          );
        }
        
        // Re-throw other database errors
        throw dbError;
      }
    }

    // Update existing records
    if (existingRecords.length > 0) {
      for (const existingRecord of existingRecords) {
        const updateRecord = validRecords.find(r => 
          r.student_id === existingRecord.student_id && 
          r.date === existingRecord.date
        );
        
        if (updateRecord) {
          const updateSql = `
            UPDATE attendance 
            SET status = ?, notes = ?, updated_at = CURRENT_TIMESTAMP
            WHERE student_id = ? AND date = ?
          `;
          
          await db.query(updateSql, [
            updateRecord.status,
            updateRecord.notes,
            updateRecord.student_id,
            updateRecord.date
          ]);
          
          updatedCount++;
          console.log(`✅ Updated attendance for student ${updateRecord.student_id} on ${updateRecord.date}: ${existingRecord.currentStatus} → ${updateRecord.status}`);
        }
      }
    }

    // Trigger sync notification for real-time updates
    try {
      await fetch(`${process.env.VERCEL_URL || 'http://localhost:3000'}/api/attendance/sync`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({
          action: 'attendance_saved',
          count: validRecords.length,
          date: validRecords[0]?.date
        })
      });
    } catch (syncError) {
      console.log('⚠️ Sync notification failed:', syncError);
      // Don't fail the main request if sync notification fails
    }

    return NextResponse.json({
      success: true,
      message: `Attendance saved successfully for ${validRecords.length} students`,
      count: validRecords.length,
      data: validRecords
    }, {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With',
      },
    });
  } catch (error: any) {
    console.error('❌ POST Attendance Error:', error);
    return NextResponse.json(
      { 
        success: false,
        message: "Error saving attendance", 
        error: error.message 
      },
      { 
        status: 500,
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With',
        },
      }
    );
  }
}

// UNIFIED PUT - Update specific attendance record
export async function PUT(req: Request) {
  try {
    const body = await req.json();
    const { student_id, date, status, notes } = body;

    console.log('🔄 PUT Attendance Request:', { student_id, date, status, notes });

    if (!student_id || !date || !status) {
      return NextResponse.json(
        { 
          success: false,
          message: "Missing required fields: student_id, date, status" 
        },
        { 
          status: 400,
          headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With',
          },
        }
      );
    }

    const sql = `
      UPDATE attendance 
      SET status = ?, notes = ?, updated_at = CURRENT_TIMESTAMP
      WHERE student_id = ? AND date = ?
    `;

    const values = [status, notes || null, parseInt(student_id), date];

    console.log('🔄 Update SQL:', sql);
    console.log('📊 Update Values:', values);

    const result = await db.query(sql, values);

    console.log('✅ Attendance updated successfully');

    return NextResponse.json({
      success: true,
      message: "Attendance updated successfully",
      data: { student_id, date, status, notes }
    }, {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With',
      },
    });
  } catch (error: any) {
    console.error('❌ PUT Attendance Error:', error);
    return NextResponse.json(
      { 
        success: false,
        message: "Error updating attendance", 
        error: error.message 
      },
      { 
        status: 500,
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With',
        },
      }
    );
  }
}

// UNIFIED DELETE - Delete attendance record
export async function DELETE(req: Request) {
  try {
    const { searchParams } = new URL(req.url);
    const studentId = searchParams.get("student_id");
    const date = searchParams.get("date");

    console.log('🗑️ DELETE Attendance Request:', { studentId, date });

    if (!studentId || !date) {
      return NextResponse.json(
        { 
          success: false,
          message: "Missing required parameters: student_id, date" 
        },
        { 
          status: 400,
          headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With',
          },
        }
      );
    }

    const sql = `DELETE FROM attendance WHERE student_id = ? AND date = ?`;
    const values = [parseInt(studentId), date];

    console.log('🗑️ Delete SQL:', sql);
    console.log('📊 Delete Values:', values);

    await db.query(sql, values);

    console.log('✅ Attendance deleted successfully');

    return NextResponse.json({
      success: true,
      message: "Attendance deleted successfully",
      data: { student_id: studentId, date }
    }, {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With',
      },
    });
  } catch (error: any) {
    console.error('❌ DELETE Attendance Error:', error);
    return NextResponse.json(
      { 
        success: false,
        message: "Error deleting attendance", 
        error: error.message 
      },
      { 
        status: 500,
        headers: {
          'Access-Control-Allow-Origin': '*',
          'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
          'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With',
        },
      }
    );
  }
}