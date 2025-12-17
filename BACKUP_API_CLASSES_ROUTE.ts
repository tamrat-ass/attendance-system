// BACKUP of app/api/classes/route.ts BEFORE changes
// This is the original working version
// Restore this if deployment causes issues

import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/db';

// GET all classes
export async function GET() {
  try {
    const [rows]: any = await db.query(
      'SELECT id, class_name, description, created_at FROM classes ORDER BY class_name ASC'
    );

    return NextResponse.json({
      success: true,
      data: rows
    });
  } catch (error: any) {
    console.error('Get classes error:', error);
    return NextResponse.json(
      { success: false, message: error.message || 'Failed to fetch classes' },
      { status: 500 }
    );
  }
}

// POST - Create new class
export async function POST(request: NextRequest) {
  try {
    const { class_name, description } = await request.json();

    if (!class_name || !class_name.trim()) {
      return NextResponse.json(
        { success: false, message: 'Class name is required' },
        { status: 400 }
      );
    }

    // Check if class already exists
    const [existing]: any = await db.query(
      'SELECT id FROM classes WHERE class_name = ?',
      [class_name.trim()]
    );

    if (existing.length > 0) {
      return NextResponse.json(
        { success: false, message: 'Class already exists' },
        { status: 400 }
      );
    }

    // Insert new class
    const [result] = await db.query(
      'INSERT INTO classes (class_name, description) VALUES (?, ?)',
      [class_name.trim(), description || null]
    );

    return NextResponse.json({
      success: true,
      message: 'Class created successfully',
      data: {
        id: (result as any).insertId,
        class_name: class_name.trim(),
        description: description || null
      }
    });
  } catch (error: any) {
    console.error('Create class error:', error);
    return NextResponse.json(
      { success: false, message: error.message || 'Failed to create class' },
      { status: 500 }
    );
  }
}