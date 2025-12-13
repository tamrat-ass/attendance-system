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

// GET - Check attendance lock status
export async function GET(req: Request) {
  try {
    // Check if attendance_lock table exists, if not create it
    await db.query(`
      CREATE TABLE IF NOT EXISTS attendance_lock (
        id INT PRIMARY KEY DEFAULT 1,
        is_locked BOOLEAN DEFAULT FALSE,
        locked_by VARCHAR(255),
        locked_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
      )
    `);

    // Get current lock status
    const [rows]: any = await db.query('SELECT * FROM attendance_lock WHERE id = 1');
    
    let lockStatus;
    if (rows.length === 0) {
      // Initialize with unlocked status
      await db.query('INSERT INTO attendance_lock (id, is_locked) VALUES (1, FALSE)');
      lockStatus = { is_locked: false, locked_by: null, locked_at: null };
    } else {
      lockStatus = rows[0];
    }

    return NextResponse.json({
      success: true,
      data: lockStatus
    }, {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With',
      },
    });
  } catch (error: any) {
    console.error('❌ GET Lock Status Error:', error);
    return NextResponse.json(
      { 
        success: false,
        message: "Error checking lock status", 
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

// POST - Toggle attendance lock (Admin only)
export async function POST(req: Request) {
  try {
    const body = await req.json();
    const { action, admin_username } = body; // action: 'lock' or 'unlock'

    if (!admin_username) {
      return NextResponse.json(
        { 
          success: false,
          message: "Admin username is required" 
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

    // Verify admin permissions (check if user is admin)
    const [adminCheck]: any = await db.query(
      'SELECT role FROM users WHERE username = ?', 
      [admin_username]
    );

    if (adminCheck.length === 0 || adminCheck[0].role !== 'admin') {
      return NextResponse.json(
        { 
          success: false,
          message: "Access denied. Only administrators can control attendance lock.",
          error: "ADMIN_REQUIRED"
        },
        { 
          status: 403,
          headers: {
            'Access-Control-Allow-Origin': '*',
            'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
            'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With',
          },
        }
      );
    }

    const isLocked = action === 'lock';
    const lockedBy = isLocked ? admin_username : null;

    // Update lock status
    await db.query(`
      UPDATE attendance_lock 
      SET is_locked = ?, locked_by = ?, updated_at = CURRENT_TIMESTAMP 
      WHERE id = 1
    `, [isLocked, lockedBy]);

    console.log(`🔒 Attendance ${action}ed by admin: ${admin_username}`);

    return NextResponse.json({
      success: true,
      message: `Attendance marking has been ${action}ed successfully`,
      data: {
        is_locked: isLocked,
        locked_by: lockedBy,
        action: action
      }
    }, {
      headers: {
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'GET, POST, PUT, DELETE, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Requested-With',
      },
    });
  } catch (error: any) {
    console.error('❌ POST Lock Toggle Error:', error);
    return NextResponse.json(
      { 
        success: false,
        message: "Error updating lock status", 
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