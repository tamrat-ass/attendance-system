import { NextRequest, NextResponse } from 'next/server';
import { db } from '@/lib/db';

// PUT - Update user
export async function PUT(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;
    const body = await request.json();
    const { 
      username, email, full_name, password, role, status,
      can_manage_students, can_add_student, can_update_student, can_upload_students, can_delete_student,
      can_mark_attendance, can_view_reports, can_export_data, 
      can_manage_users, can_delete_user, can_manage_passwords
    } = body;

    console.log('=== UPDATE USER REQUEST ===');
    console.log('User ID:', id, 'Type:', typeof id);
    console.log('Body:', body);
    console.log('Permissions:', { can_manage_students, can_add_student, can_upload_students, can_delete_student, can_mark_attendance, can_view_reports, can_export_data, can_manage_users, can_delete_user, can_manage_passwords });

    if (!username || !email) {
      return NextResponse.json(
        { success: false, message: 'Username and email are required' },
        { status: 400 }
      );
    }

    // Check if username or email already exists for other users
    const [existing]: any = await db.query(
      'SELECT id FROM users WHERE (username = ? OR email = ?) AND id != ?',
      [username, email, id]
    );

    if (existing.length > 0) {
      return NextResponse.json(
        { success: false, message: 'Username or email already exists' },
        { status: 400 }
      );
    }

    // Build update query
    let query = `UPDATE users SET username = ?, email = ?, full_name = ?, role = ?, status = ?,
                 can_manage_students = ?, can_add_student = ?, can_update_student = ?, can_upload_students = ?, can_delete_student = ?,
                 can_mark_attendance = ?, can_view_reports = ?, can_export_data = ?,
                 can_manage_users = ?, can_delete_user = ?, can_manage_passwords = ?`;
    
    // Convert boolean values properly (handle true/false/1/0)
    // No defaults - use the values sent from frontend
    const permissionParams = [
      can_manage_students ? 1 : 0,
      can_add_student ? 1 : 0,
      can_update_student ? 1 : 0,
      can_upload_students ? 1 : 0,
      can_delete_student ? 1 : 0,
      can_mark_attendance ? 1 : 0,
      can_view_reports ? 1 : 0,
      can_export_data ? 1 : 0,
      can_manage_users ? 1 : 0,
      can_delete_user ? 1 : 0,
      can_manage_passwords ? 1 : 0
    ];
    
    let queryParams: any[] = [
      username, 
      email, 
      full_name || null, 
      role, 
      status,
      ...permissionParams
    ];

    console.log('Query params:', queryParams);

    // Only update password if provided
    if (password) {
      query += ', password_hash = ?';
      queryParams.push(password);
    }

    query += ' WHERE id = ?';
    queryParams.push(id);

    console.log('Executing query:', query);
    console.log('With params:', queryParams);
    
    try {
      const [result]: any = await db.query(query, queryParams);
      console.log('Query executed successfully. Affected rows:', result.affectedRows);
      
      if (result.affectedRows === 0) {
        console.error('WARNING: No rows were updated!');
      }
    } catch (queryError: any) {
      console.error('Query execution failed:', queryError);
      throw queryError;
    }

    // Verify the update by fetching the user
    console.log('Verifying update - fetching user with ID:', id);
    const [updatedUsers]: any = await db.query(
      `SELECT id, username, can_manage_students, can_add_student, can_update_student, can_upload_students, can_delete_student,
       can_mark_attendance, can_view_reports, can_export_data, 
       can_manage_users, can_delete_user, can_manage_passwords 
       FROM users WHERE id = ?`,
      [id]
    );

    console.log('Verification query result:', updatedUsers);
    console.log('First user:', updatedUsers[0]);
    console.log('Result length:', updatedUsers.length);

    if (!updatedUsers || updatedUsers.length === 0 || !updatedUsers[0]) {
      console.error('ERROR: User not found after update. ID:', id);
      return NextResponse.json({
        success: false,
        message: 'User not found after update',
        debug: { id, resultLength: updatedUsers?.length }
      }, { status: 404 });
    }

    return NextResponse.json({
      success: true,
      message: 'User updated successfully',
      user: updatedUsers[0],
      affectedRows: updatedUsers.length
    });
  } catch (error: any) {
    console.error('Update user error:', error);
    return NextResponse.json(
      { success: false, message: error.message || 'Failed to update user' },
      { status: 500 }
    );
  }
}

// DELETE - Delete user
export async function DELETE(
  request: NextRequest,
  { params }: { params: Promise<{ id: string }> }
) {
  try {
    const { id } = await params;

    // Check if user exists
    const [user]: any = await db.query('SELECT id FROM users WHERE id = ?', [id]);

    if (user.length === 0) {
      return NextResponse.json(
        { success: false, message: 'User not found' },
        { status: 404 }
      );
    }

    // Delete user
    await db.query('DELETE FROM users WHERE id = ?', [id]);

    return NextResponse.json({
      success: true,
      message: 'User deleted successfully'
    });
  } catch (error: any) {
    console.error('Delete user error:', error);
    return NextResponse.json(
      { success: false, message: error.message || 'Failed to delete user' },
      { status: 500 }
    );
  }
}
