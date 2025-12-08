'use client';

import { useState, useEffect } from 'react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Trash2, Plus, Search, Pencil, Shield, Users, History } from 'lucide-react';
import { AlertCircle } from 'lucide-react';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { useToast } from '@/hooks/use-toast';
import { Badge } from '@/components/ui/badge';
import { Switch } from '@/components/ui/switch';
import { logAdminAction } from '@/lib/logger';

interface User {
  id: number;
  username: string;
  email: string;
  full_name: string;
  role: 'admin' | 'manager' | 'user';
  status: 'active' | 'inactive';
  can_manage_students?: boolean;
  can_add_student?: boolean;
  can_update_student?: boolean;
  can_upload_students?: boolean;
  can_delete_student?: boolean;
  can_mark_attendance?: boolean;
  can_view_reports?: boolean;
  can_export_data?: boolean;
  can_manage_users?: boolean;
  can_delete_user?: boolean;
  can_manage_passwords?: boolean;
  created_at?: string;
}

interface AdminLog {
  id: number;
  user_id: number;
  username: string;
  action: string;
  target_type?: string;
  target_id?: number;
  details?: string;
  ip_address?: string;
  created_at: string;
  full_name?: string;
  role?: string;
}

// Default form values
const DEFAULT_FORM_DATA = {
  username: '',
  email: '',
  full_name: '',
  password: '',
  role: 'user' as 'admin' | 'manager' | 'user',
  status: 'active' as 'active' | 'inactive',
  can_manage_students: true,
  can_add_student: true,
  can_update_student: true,
  can_upload_students: true,
  can_delete_student: false,
  can_mark_attendance: true,
  can_view_reports: false,
  can_export_data: false,
  can_manage_users: false,
  can_delete_user: false,
  can_manage_passwords: false
};

export default function AdminPanel() {
  const [users, setUsers] = useState<User[]>([]);
  const [logs, setLogs] = useState<AdminLog[]>([]);
  const [loading, setLoading] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [editingUser, setEditingUser] = useState<User | null>(null);
  const [activeTab, setActiveTab] = useState('users');
  const [currentUser, setCurrentUser] = useState<any>(null);
  const { toast } = useToast();

  // Load current user from localStorage
  useEffect(() => {
    const userStr = localStorage.getItem('user');
    if (userStr) {
      try {
        setCurrentUser(JSON.parse(userStr));
      } catch (e) {
        console.error('Error parsing user data:', e);
      }
    }
  }, []);

  const [formData, setFormData] = useState(DEFAULT_FORM_DATA);

  // Fetch users from API
  const fetchUsers = async () => {
    setLoading(true);
    try {
      const response = await fetch('/api/admin/users');
      const data = await response.json();
      
      if (response.ok) {
        setUsers(data.data || []);
      } else {
        setError(data.message || 'Failed to fetch users');
      }
    } catch (err: any) {
      setError('Error connecting to server');
    } finally {
      setLoading(false);
    }
  };

  // Fetch logs from API
  const fetchLogs = async () => {
    try {
      const response = await fetch('/api/admin/logs?limit=100');
      const data = await response.json();
      
      if (response.ok) {
        setLogs(data.data || []);
      }
    } catch (err: any) {
      console.error('Error fetching logs:', err);
    }
  };

  useEffect(() => {
    fetchUsers();
    fetchLogs();
  }, []);

  // Handle adding a new user
  const handleAddUser = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setSuccess('');

    if (!formData.username || !formData.email || !formData.password) {
      setError('Username, email, and password are required');
      return;
    }

    setLoading(true);
    try {
      const response = await fetch('/api/admin/users', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(formData)
      });

      const data = await response.json();

      if (response.ok) {
        setSuccess('User added successfully!');
        
        // Log the action
        if (currentUser) {
          await logAdminAction(
            currentUser.id,
            currentUser.username,
            'CREATE_USER',
            'user',
            data.data?.id,
            `Created user: ${formData.username} (${formData.role})`
          );
        }
        
        setFormData(DEFAULT_FORM_DATA);
        fetchUsers();
        fetchLogs();
        toast({
          title: "Success",
          description: "User added successfully",
        });
      } else {
        setError(data.message || 'Failed to add user');
      }
    } catch (err: any) {
      setError('Error connecting to server');
    } finally {
      setLoading(false);
    }
  };

  // Handle updating a user
  const handleUpdateUser = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!editingUser) return;

    setLoading(true);
    try {
      const updateData = { ...formData };
      const passwordChanged = updateData.password && updateData.password.trim() !== '';
      
      if (!updateData.password) {
        delete (updateData as any).password;
      }

      console.log('Updating user with data:', updateData);

      const response = await fetch(`/api/admin/users/${editingUser.id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(updateData)
      });

      const data = await response.json();

      if (response.ok) {
        console.log('Update response:', data);
        
        // Build permission summary
        const permissionsList = [];
        if (formData.can_manage_students) permissionsList.push('Manage Students');
        if (formData.can_add_student) permissionsList.push('Add Student');
        if (formData.can_upload_students) permissionsList.push('Upload Students');
        if (formData.can_delete_student) permissionsList.push('Delete Student');
        if (formData.can_mark_attendance) permissionsList.push('Mark Attendance');
        if (formData.can_view_reports) permissionsList.push('View Reports');
        if (formData.can_export_data) permissionsList.push('Export Data');
        if (formData.can_manage_users) permissionsList.push('Manage Users');
        if (formData.can_delete_user) permissionsList.push('Delete User');
        if (formData.can_manage_passwords) permissionsList.push('Manage Passwords');
        
        const successMsg = `✓ User "${formData.username}" updated successfully!\n\nPermissions: ${permissionsList.join(', ') || 'None'}`;
        setSuccess(successMsg);
        
        // Log the action
        if (currentUser) {
          let logDetails = `Updated user: ${formData.username} (${formData.role}) - Permissions: ${permissionsList.join(', ')}`;
          
          // Log password reset separately if password was changed
          if (passwordChanged) {
            await logAdminAction(
              currentUser.id,
              currentUser.username,
              'RESET_PASSWORD',
              'user',
              editingUser.id,
              `Reset password for user: ${formData.username}`
            );
            logDetails += ' | Password Reset';
          }
          
          await logAdminAction(
            currentUser.id,
            currentUser.username,
            'UPDATE_USER',
            'user',
            editingUser.id,
            logDetails
          );
        }
        
        setEditingUser(null);
        setFormData(DEFAULT_FORM_DATA);
        
        // Refresh users and switch to manage users tab
        await fetchUsers();
        fetchLogs();
        setActiveTab('users');
        
        toast({
          title: "✓ Permissions Updated Successfully!",
          description: `${formData.username}'s permissions have been updated. Active permissions: ${permissionsList.join(', ') || 'None'}`,
        });
      } else {
        setError(data.message || 'Failed to update user');
      }
    } catch (err: any) {
      setError('Error connecting to server');
    } finally {
      setLoading(false);
    }
  };

  // Handle deleting a user
  const handleDeleteUser = async (id: number) => {
    if (!confirm('Are you sure you want to delete this user?')) return;

    setLoading(true);
    try {
      const response = await fetch(`/api/admin/users/${id}`, {
        method: 'DELETE'
      });

      const data = await response.json();

      if (response.ok) {
        setSuccess('User deleted successfully!');
        
        // Log the action
        if (currentUser) {
          const deletedUser = users.find(u => u.id === id);
          await logAdminAction(
            currentUser.id,
            currentUser.username,
            'DELETE_USER',
            'user',
            id,
            `Deleted user: ${deletedUser?.username || id}`
          );
        }
        
        fetchUsers();
        fetchLogs();
        toast({
          title: "Success",
          description: "User deleted successfully",
        });
      } else {
        setError(data.message || 'Failed to delete user');
      }
    } catch (err: any) {
      setError('Error connecting to server');
    } finally {
      setLoading(false);
    }
  };

  // Start editing a user
  const startEdit = (user: User) => {
    setEditingUser(user);
    setFormData({
      username: user.username,
      email: user.email,
      full_name: user.full_name,
      password: '',
      role: user.role,
      status: user.status,
      can_manage_students: user.can_manage_students ?? true,
      can_add_student: user.can_add_student ?? true,
      can_update_student: user.can_update_student ?? true,
      can_upload_students: user.can_upload_students ?? true,
      can_delete_student: user.can_delete_student ?? false,
      can_mark_attendance: user.can_mark_attendance ?? true,
      can_view_reports: user.can_view_reports ?? false,
      can_export_data: user.can_export_data ?? false,
      can_manage_users: user.can_manage_users ?? false,
      can_delete_user: user.can_delete_user ?? false,
      can_manage_passwords: user.can_manage_passwords ?? false
    });
    setActiveTab('add');
    setError('');
    setSuccess('');
  };

  // Cancel editing
  const cancelEdit = () => {
    setEditingUser(null);
    setFormData(DEFAULT_FORM_DATA);
    setError('');
    setSuccess('');
  };

  // Filter users based on search
  const filteredUsers = users.filter(user =>
    user.username.toLowerCase().includes(searchTerm.toLowerCase()) ||
    user.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
    user.full_name?.toLowerCase().includes(searchTerm.toLowerCase()) ||
    user.role.toLowerCase().includes(searchTerm.toLowerCase())
  );

  const getRoleBadge = (role: string) => {
    const colors = {
      admin: 'bg-red-100 text-red-800 dark:bg-red-900 dark:text-red-200',
      manager: 'bg-blue-100 text-blue-800 dark:bg-blue-900 dark:text-blue-200',
      user: 'bg-gray-100 text-gray-800 dark:bg-gray-800 dark:text-gray-200'
    };
    return <Badge className={colors[role as keyof typeof colors]}>{role.toUpperCase()}</Badge>;
  };

  const getStatusBadge = (status: string) => {
    return status === 'active' ? (
      <Badge className="bg-green-100 text-green-800 dark:bg-green-900 dark:text-green-200">Active</Badge>
    ) : (
      <Badge className="bg-gray-100 text-gray-800 dark:bg-gray-800 dark:text-gray-200">Inactive</Badge>
    );
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-2 mb-4">
        <Shield className="w-6 h-6 text-primary" />
        <h2 className="text-2xl font-bold">Admin Panel</h2>
      </div>

      <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
        <TabsList className="grid w-full grid-cols-4">
          <TabsTrigger value="add" className="flex items-center gap-2">
            {editingUser ? <Pencil className="w-4 h-4" /> : <Plus className="w-4 h-4" />}
            {editingUser ? 'Edit User' : 'Add User'}
          </TabsTrigger>
          <TabsTrigger value="users" className="flex items-center gap-2">
            <Users className="w-4 h-4" />
            Manage Users
          </TabsTrigger>
          <TabsTrigger value="logs" className="flex items-center gap-2">
            <History className="w-4 h-4" />
            Activity Logs
          </TabsTrigger>
        </TabsList>

        {/* Add/Edit User Tab */}
        <TabsContent value="add">
          <Card className="border-2">
            <CardHeader>
              <CardTitle>{editingUser ? 'Edit User' : 'Add New User'}</CardTitle>
              <CardDescription>
                {editingUser ? 'Update user information and permissions' : 'Create a new user account'}
              </CardDescription>
            </CardHeader>
            <CardContent>
              {error && (
                <Alert variant="destructive" className="mb-4">
                  <AlertCircle className="h-4 w-4" />
                  <AlertDescription>{error}</AlertDescription>
                </Alert>
              )}
              
              {success && (
                <Alert className="mb-4 border-green-200 bg-green-50">
                  <AlertCircle className="h-4 w-4 text-green-600" />
                  <AlertDescription className="text-green-800">{success}</AlertDescription>
                </Alert>
              )}

              <form onSubmit={editingUser ? handleUpdateUser : handleAddUser} className="space-y-4">
                <div className="grid grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="username">Username *</Label>
                    <Input
                      id="username"
                      placeholder="Enter username"
                      value={formData.username}
                      onChange={(e) => setFormData({ ...formData, username: e.target.value })}
                      required
                    />
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="email">Email *</Label>
                    <Input
                      id="email"
                      type="email"
                      placeholder="Enter email"
                      value={formData.email}
                      onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                      required
                    />
                  </div>
                </div>

                <div className="space-y-2">
                  <Label htmlFor="full_name">Full Name</Label>
                  <Input
                    id="full_name"
                    placeholder="Enter full name"
                    value={formData.full_name}
                    onChange={(e) => setFormData({ ...formData, full_name: e.target.value })}
                  />
                </div>

                {/* Password field - only show if user has can_manage_passwords permission or when creating new user */}
                {(!editingUser || currentUser?.can_manage_passwords) && (
                  <div className="space-y-2">
                    <Label htmlFor="password">
                      Password {editingUser && '(leave blank to keep current)'}
                      {editingUser && currentUser?.can_manage_passwords && (
                        <span className="text-xs text-muted-foreground ml-2">🔑 Password Reset</span>
                      )}
                    </Label>
                    <Input
                      id="password"
                      type="password"
                      placeholder={editingUser ? "Leave blank to keep current" : "Enter password"}
                      value={formData.password}
                      onChange={(e) => setFormData({ ...formData, password: e.target.value })}
                      required={!editingUser}
                    />
                    {editingUser && currentUser?.can_manage_passwords && (
                      <p className="text-xs text-muted-foreground">
                        Changing the password will be logged in the activity logs
                      </p>
                    )}
                  </div>
                )}
                
                {/* Show message if user doesn't have permission to change passwords */}
                {editingUser && !currentUser?.can_manage_passwords && (
                  <Alert>
                    <AlertCircle className="h-4 w-4" />
                    <AlertDescription>
                      You don't have permission to change user passwords. Contact an administrator.
                    </AlertDescription>
                  </Alert>
                )}

                <div className="grid grid-cols-2 gap-4">
                  <div className="space-y-2">
                    <Label htmlFor="role">Role *</Label>
                    <Select value={formData.role} onValueChange={(value: any) => setFormData({ ...formData, role: value })}>
                      <SelectTrigger>
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="user">User</SelectItem>
                        <SelectItem value="manager">Manager</SelectItem>
                        <SelectItem value="admin">Admin</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>

                  <div className="space-y-2">
                    <Label htmlFor="status">Status *</Label>
                    <Select value={formData.status} onValueChange={(value: any) => setFormData({ ...formData, status: value })}>
                      <SelectTrigger>
                        <SelectValue />
                      </SelectTrigger>
                      <SelectContent>
                        <SelectItem value="active">Active</SelectItem>
                        <SelectItem value="inactive">Inactive</SelectItem>
                      </SelectContent>
                    </Select>
                  </div>
                </div>

                {/* Permissions Section */}
                <div className="space-y-3 p-4 border rounded-lg bg-muted/50">
                  <Label className="text-base font-semibold">Permissions</Label>
                  <p className="text-sm text-muted-foreground">Control what this user can access</p>
                  
                  <div className="space-y-3 mt-3">
                    <div className="flex items-center justify-between">
                      <div className="space-y-0.5">
                        <Label htmlFor="can_manage_students" className="text-sm font-medium">
                          Manage Students (Legacy)
                        </Label>
                        <p className="text-xs text-muted-foreground">Full student management access</p>
                      </div>
                      <Switch
                        id="can_manage_students"
                        checked={formData.can_manage_students}
                        onCheckedChange={(checked) => setFormData({ ...formData, can_manage_students: checked })}
                      />
                    </div>

                    <div className="flex items-center justify-between">
                      <div className="space-y-0.5">
                        <Label htmlFor="can_add_student" className="text-sm font-medium">
                          Add Student
                        </Label>
                        <p className="text-xs text-muted-foreground">Add individual students</p>
                      </div>
                      <Switch
                        id="can_add_student"
                        checked={formData.can_add_student}
                        onCheckedChange={(checked) => setFormData({ ...formData, can_add_student: checked })}
                      />
                    </div>

                    <div className="flex items-center justify-between">
                      <div className="space-y-0.5">
                        <Label htmlFor="can_update_student" className="text-sm font-medium">
                          Update Student
                        </Label>
                        <p className="text-xs text-muted-foreground">Edit student information</p>
                      </div>
                      <Switch
                        id="can_update_student"
                        checked={formData.can_update_student}
                        onCheckedChange={(checked) => setFormData({ ...formData, can_update_student: checked })}
                      />
                    </div>

                    <div className="flex items-center justify-between">
                      <div className="space-y-0.5">
                        <Label htmlFor="can_upload_students" className="text-sm font-medium">
                          Upload Students (CSV)
                        </Label>
                        <p className="text-xs text-muted-foreground">Bulk upload students via CSV file</p>
                      </div>
                      <Switch
                        id="can_upload_students"
                        checked={formData.can_upload_students}
                        onCheckedChange={(checked) => setFormData({ ...formData, can_upload_students: checked })}
                      />
                    </div>

                    <div className="flex items-center justify-between">
                      <div className="space-y-0.5">
                        <Label htmlFor="can_delete_student" className="text-sm font-medium">
                          Delete Student
                        </Label>
                        <p className="text-xs text-muted-foreground">Remove students from system</p>
                      </div>
                      <Switch
                        id="can_delete_student"
                        checked={formData.can_delete_student}
                        onCheckedChange={(checked) => setFormData({ ...formData, can_delete_student: checked })}
                      />
                    </div>

                    <div className="flex items-center justify-between">
                      <div className="space-y-0.5">
                        <Label htmlFor="can_mark_attendance" className="text-sm font-medium">
                          Mark Attendance
                        </Label>
                        <p className="text-xs text-muted-foreground">Record student attendance</p>
                      </div>
                      <Switch
                        id="can_mark_attendance"
                        checked={formData.can_mark_attendance}
                        onCheckedChange={(checked) => setFormData({ ...formData, can_mark_attendance: checked })}
                      />
                    </div>

                    <div className="flex items-center justify-between">
                      <div className="space-y-0.5">
                        <Label htmlFor="can_view_reports" className="text-sm font-medium">
                          View Reports
                        </Label>
                        <p className="text-xs text-muted-foreground">Access attendance reports and analytics</p>
                      </div>
                      <Switch
                        id="can_view_reports"
                        checked={formData.can_view_reports}
                        onCheckedChange={(checked) => setFormData({ ...formData, can_view_reports: checked })}
                      />
                    </div>

                    <div className="flex items-center justify-between">
                      <div className="space-y-0.5">
                        <Label htmlFor="can_export_data" className="text-sm font-medium">
                          Export Data
                        </Label>
                        <p className="text-xs text-muted-foreground">Download reports and student data</p>
                      </div>
                      <Switch
                        id="can_export_data"
                        checked={formData.can_export_data}
                        onCheckedChange={(checked) => setFormData({ ...formData, can_export_data: checked })}
                      />
                    </div>

                    <div className="flex items-center justify-between">
                      <div className="space-y-0.5">
                        <Label htmlFor="can_manage_users" className="text-sm font-medium">
                          Manage Users
                        </Label>
                        <p className="text-xs text-muted-foreground">Access admin panel and edit users</p>
                      </div>
                      <Switch
                        id="can_manage_users"
                        checked={formData.can_manage_users}
                        onCheckedChange={(checked) => setFormData({ ...formData, can_manage_users: checked })}
                      />
                    </div>

                    <div className="flex items-center justify-between">
                      <div className="space-y-0.5">
                        <Label htmlFor="can_delete_user" className="text-sm font-medium">
                          Delete User
                        </Label>
                        <p className="text-xs text-muted-foreground">Remove users from system</p>
                      </div>
                      <Switch
                        id="can_delete_user"
                        checked={formData.can_delete_user}
                        onCheckedChange={(checked) => setFormData({ ...formData, can_delete_user: checked })}
                      />
                    </div>

                    <div className="flex items-center justify-between">
                      <div className="space-y-0.5">
                        <Label htmlFor="can_manage_passwords" className="text-sm font-medium">
                          Manage Passwords
                        </Label>
                        <p className="text-xs text-muted-foreground">Change user passwords</p>
                      </div>
                      <Switch
                        id="can_manage_passwords"
                        checked={formData.can_manage_passwords}
                        onCheckedChange={(checked) => setFormData({ ...formData, can_manage_passwords: checked })}
                      />
                    </div>
                  </div>
                </div>

                <div className="flex gap-2">
                  <Button type="submit" className="flex-1" disabled={loading}>
                    {loading ? 'Processing...' : editingUser ? '✓ Update User' : '+ Add User'}
                  </Button>
                  {editingUser && (
                    <Button type="button" variant="outline" onClick={cancelEdit} disabled={loading}>
                      Cancel
                    </Button>
                  )}
                </div>
              </form>
            </CardContent>
          </Card>
        </TabsContent>

        {/* Manage Users Tab */}
        <TabsContent value="users">
          <Card className="border-2">
            <CardHeader>
              <CardTitle>Manage Users</CardTitle>
              <CardDescription>
                View and manage all system users ({filteredUsers.length} users)
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="search">Search</Label>
                <Input
                  id="search"
                  placeholder="Search by username, email, name, or role..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                />
              </div>

              {loading && <p className="text-center text-muted-foreground">Loading...</p>}

              <div className="rounded-lg border overflow-x-auto">
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>ID</TableHead>
                      <TableHead>Username</TableHead>
                      <TableHead>Email</TableHead>
                      <TableHead>Full Name</TableHead>
                      <TableHead>Role</TableHead>
                      <TableHead>Status</TableHead>
                      <TableHead className="text-right">Actions</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {filteredUsers.length === 0 ? (
                      <TableRow>
                        <TableCell colSpan={7} className="text-center text-muted-foreground py-6">
                          {users.length === 0 ? 'No users found' : 'No matching users found'}
                        </TableCell>
                      </TableRow>
                    ) : (
                      filteredUsers.map((user) => (
                        <TableRow key={user.id}>
                          <TableCell className="font-mono text-sm">{user.id}</TableCell>
                          <TableCell className="font-medium">{user.username}</TableCell>
                          <TableCell>{user.email}</TableCell>
                          <TableCell>{user.full_name || '-'}</TableCell>
                          <TableCell>{getRoleBadge(user.role)}</TableCell>
                          <TableCell>{getStatusBadge(user.status)}</TableCell>
                          <TableCell className="text-right">
                            <div className="flex justify-end gap-2">
                              <Button
                                variant="outline"
                                size="sm"
                                onClick={() => startEdit(user)}
                                disabled={loading}
                              >
                                <Pencil className="w-4 h-4 mr-1" />
                                Edit
                              </Button>
                              <Button
                                variant="destructive"
                                size="sm"
                                onClick={() => handleDeleteUser(user.id)}
                                disabled={loading || !currentUser?.can_delete_user}
                              >
                                <Trash2 className="w-4 h-4" />
                              </Button>
                            </div>
                          </TableCell>
                        </TableRow>
                      ))
                    )}
                  </TableBody>
                </Table>
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        {/* Activity Logs Tab */}
        <TabsContent value="logs">
          <Card className="border-2">
            <CardHeader>
              <CardTitle>Activity Logs</CardTitle>
              <CardDescription>
                Track all user activities including logins, logouts, and admin actions ({logs.length} logs)
              </CardDescription>
            </CardHeader>
            <CardContent>
              <div className="rounded-lg border overflow-x-auto">
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Date & Time</TableHead>
                      <TableHead>Admin User</TableHead>
                      <TableHead>Action</TableHead>
                      <TableHead>Details</TableHead>
                      <TableHead>IP Address</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {logs.length === 0 ? (
                      <TableRow>
                        <TableCell colSpan={5} className="text-center text-muted-foreground py-6">
                          No activity logs found
                        </TableCell>
                      </TableRow>
                    ) : (
                      logs.map((log) => (
                        <TableRow key={log.id}>
                          <TableCell className="font-mono text-sm">
                            {new Date(log.created_at).toLocaleString()}
                          </TableCell>
                          <TableCell>
                            <div>
                              <div className="font-medium">{log.username}</div>
                              {log.full_name && (
                                <div className="text-xs text-muted-foreground">{log.full_name}</div>
                              )}
                            </div>
                          </TableCell>
                          <TableCell>
                            <Badge variant={
                              log.action === 'DELETE_USER' ? 'destructive' :
                              log.action === 'CREATE_USER' ? 'default' :
                              log.action === 'LOGIN' ? 'outline' :
                              log.action === 'LOGOUT' ? 'outline' :
                              'secondary'
                            }>
                              {log.action.replace(/_/g, ' ')}
                            </Badge>
                          </TableCell>
                          <TableCell className="max-w-md truncate">
                            {log.details || '-'}
                          </TableCell>
                          <TableCell className="font-mono text-xs text-muted-foreground">
                            {log.ip_address || '-'}
                          </TableCell>
                        </TableRow>
                      ))
                    )}
                  </TableBody>
                </Table>
              </div>
            </CardContent>
          </Card>
        </TabsContent>
      </Tabs>
    </div>
  );
}
