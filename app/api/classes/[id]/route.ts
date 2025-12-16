import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/db';

// PUT - Update class
export async function PUT(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    const { name, description } = await request.json();

    if (!name || !name.trim()) {
      return NextResponse.json(
        { success: false, message: 'Class name is required' },
        { status: 400 }
      );
    }

    // Check if class exists
    const [existing]: any = await db.query('SELECT name FROM classes WHERE id = ?', [id]);

    if (existing.length === 0) {
      return NextResponse.json(
        { success: false, message: 'Class not found' },
        { status: 404 }
      );
    }

    const oldClassName = existing[0].name;

    // Check if new class name already exists (excluding current class)
    const [duplicate]: any = await db.query(
      'SELECT id FROM classes WHERE name = ? AND id != ?',
      [name.trim(), id]
    );

    if (duplicate.length > 0) {
      return NextResponse.json(
        { success: false, message: 'Class name already exists' },
        { status: 400 }
      );
    }

    // Update class
    const [updateResult] = await db.query(
      'UPDATE classes SET name = ?, description = ? WHERE id = ?',
      [name.trim(), description || null, id]
    );

    console.log('Class update result:', updateResult);

    // Update students table to reflect new class name
    const [studentUpdateResult] = await db.query(
      'UPDATE students SET class = ? WHERE class = ?',
      [name.trim(), oldClassName]
    );

    console.log('Student class update result:', studentUpdateResult);

    // Verify the update was successful
    const [verifyResult]: any = await db.query(
      'SELECT name, description FROM classes WHERE id = ?',
      [id]
    );

    const updatedClass = verifyResult[0];
    console.log('Verified updated class:', updatedClass);

    return NextResponse.json({
      success: true,
      message: 'Class updated successfully',
      data: {
        id: parseInt(id),
        name: updatedClass.name,
        description: updatedClass.description
      }
    });
  } catch (error: any) {
    console.error('Update class error:', error);
    return NextResponse.json(
      { success: false, message: error.message || 'Failed to update class' },
      { status: 500 }
    );
  }
}

// DELETE class
export async function DELETE(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;

    // Check if class exists
    const [classData]: any = await db.query('SELECT name FROM classes WHERE id = ?', [id]);

    if (classData.length === 0) {
      return NextResponse.json(
        { success: false, message: 'Class not found' },
        { status: 404 }
      );
    }

    const className = classData[0].name;

    // Check if there are students in this class
    const [students]: any = await db.query('SELECT COUNT(*) as count FROM students WHERE class = ?', [className]);
    const studentCount = students[0].count;

    if (studentCount > 0) {
      return NextResponse.json(
        { success: false, message: `Cannot delete class. ${studentCount} student${studentCount !== 1 ? 's' : ''} are enrolled in this class.` },
        { status: 400 }
      );
    }

    // Delete class
    await db.query('DELETE FROM classes WHERE id = ?', [id]);

    return NextResponse.json({
      success: true,
      message: 'Class deleted successfully'
    });
  } catch (error: any) {
    console.error('Delete class error:', error);
    return NextResponse.json(
      { success: false, message: error.message || 'Failed to delete class' },
      { status: 500 }
    );
  }
}