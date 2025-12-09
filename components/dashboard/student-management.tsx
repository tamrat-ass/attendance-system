'use client';

import { useState, useEffect } from 'react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { Tabs, TabsContent, TabsList, TabsTrigger } from '@/components/ui/tabs';
import { Select, SelectContent, SelectItem, SelectTrigger, SelectValue } from '@/components/ui/select';
import { Trash2, Plus, Search, Pencil, Upload, Download, Filter } from 'lucide-react';
import { AlertCircle } from 'lucide-react';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { useToast } from '@/hooks/use-toast';

interface Student {
  id: number;
  full_name: string;
  phone: string;
  class: string;
  gender?: string;
  created_at?: string;
  updated_at?: string;
}

export default function StudentManagement() {
  const [students, setStudents] = useState<Student[]>([]);
  const [loading, setLoading] = useState(false);
  const [searchTerm, setSearchTerm] = useState('');
  const [selectedClass, setSelectedClass] = useState<string>('all');
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [editingStudent, setEditingStudent] = useState<Student | null>(null);
  const [activeTab, setActiveTab] = useState('add');
  const [bulkFile, setBulkFile] = useState<File | null>(null);
  const [bulkError, setBulkError] = useState('');
  const [bulkSuccess, setBulkSuccess] = useState('');
  const [currentUser, setCurrentUser] = useState<any>(null);
  const [newClassName, setNewClassName] = useState('');
  const [classError, setClassError] = useState('');
  const [classSuccess, setClassSuccess] = useState('');
  const [classes, setClasses] = useState<any[]>([]);
  const [editingClass, setEditingClass] = useState<any>(null);
  const [editClassName, setEditClassName] = useState('');
  const { toast } = useToast();

  // Load current user permissions
  useEffect(() => {
    const loadUser = () => {
      const userStr = localStorage.getItem('user');
      if (userStr) {
        try {
          const user = JSON.parse(userStr);
          console.log('Current user permissions:', user);
          console.log('can_add_student:', user.can_add_student);
          console.log('can_upload_students:', user.can_upload_students);
          console.log('can_delete_student:', user.can_delete_student);
          setCurrentUser(user);
        } catch (e) {
          console.error('Error parsing user data:', e);
        }
      }
    };
    
    loadUser();
    
    // Listen for permission updates
    window.addEventListener('storage', loadUser);
    window.addEventListener('permissionsUpdated', loadUser);
    
    return () => {
      window.removeEventListener('storage', loadUser);
      window.removeEventListener('permissionsUpdated', loadUser);
    };
  }, []);

  const [formData, setFormData] = useState({
    full_name: '',
    phone: '',
    class: '',
    gender: ''
  });

  // Fetch students from API
  const fetchStudents = async () => {
    setLoading(true);
    try {
      const response = await fetch('/api/students');
      const data = await response.json();
      
      if (response.ok) {
        setStudents(data.data || []);
      } else {
        setError(data.message || 'Failed to fetch students');
      }
    } catch (err: any) {
      setError('Error connecting to server');
    } finally {
      setLoading(false);
    }
  };

  // Get classes from students (no separate table needed)
  const getClassesFromStudents = () => {
    const uniqueClasses = Array.from(new Set(students.map(s => s.class))).filter(Boolean).sort();
    return uniqueClasses.map(className => ({
      id: className, // Use class name as ID
      class_name: className,
      student_count: students.filter(s => s.class === className).length
    }));
  };

  // Load students on component mount
  useEffect(() => {
    fetchStudents();
  }, []);

  // Handle adding a new student
  const handleAddStudent = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setSuccess('');

    if (!formData.full_name || !formData.phone || !formData.class || !formData.gender) {
      setError('All fields are required');
      return;
    }

    // Validate phone number format
    if (formData.phone.length !== 10 || !/^09\d{8}$/.test(formData.phone)) {
      setError('Phone number must be exactly 10 digits and start with 09');
      return;
    }

    setLoading(true);
    try {
      const response = await fetch('/api/students', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(formData)
      });

      const data = await response.json();

      if (response.ok) {
        setSuccess('Student added successfully!');
        setFormData({ full_name: '', phone: '', class: '', gender: '' });
        fetchStudents(); // Refresh list
        toast({
          title: "Success",
          description: "Student added successfully",
        });
      } else {
        setError(data.message || 'Failed to add student');
      }
    } catch (err: any) {
      setError('Error connecting to server');
    } finally {
      setLoading(false);
    }
  };

  // Handle updating a student
  const handleUpdateStudent = async (e: React.FormEvent) => {
    e.preventDefault();
    console.log('Update function called');
    console.log('Editing student:', editingStudent);
    console.log('Form data:', formData);
    
    if (!editingStudent) {
      console.error('No student being edited!');
      return;
    }

    // Validate required fields
    if (!formData.full_name || !formData.phone || !formData.class) {
      setError('All fields are required');
      setLoading(false);
      return;
    }

    // Validate phone number format
    if (formData.phone.length !== 10 || !/^09\d{8}$/.test(formData.phone)) {
      setError('Phone number must be exactly 10 digits and start with 09');
      setLoading(false);
      return;
    }

    setLoading(true);
    setError('');
    setSuccess('');
    
    try {
      console.log(`Sending PUT request to /api/students/${editingStudent.id}`);
      const response = await fetch(`/api/students/${editingStudent.id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(formData)
      });

      const data = await response.json();
      console.log('Update response:', data);

      if (response.ok) {
        setSuccess('Student updated successfully!');
        setEditingStudent(null);
        setFormData({ full_name: '', phone: '', class: '', gender: '' });
        await fetchStudents();
        setActiveTab('manage'); // Switch back to manage tab
        toast({
          title: "Success",
          description: "Student updated successfully",
        });
      } else {
        console.error('Update failed:', data);
        setError(data.message || 'Failed to update student');
      }
    } catch (err: any) {
      console.error('Update error:', err);
      setError('Error connecting to server');
    } finally {
      setLoading(false);
    }
  };

  // Handle deleting a student
  const handleDeleteStudent = async (id: number) => {
    if (!confirm('Are you sure you want to delete this student?')) return;

    setLoading(true);
    try {
      const response = await fetch(`/api/students/${id}`, {
        method: 'DELETE'
      });

      const data = await response.json();

      if (response.ok) {
        setSuccess('Student deleted successfully!');
        fetchStudents();
        toast({
          title: "Success",
          description: "Student deleted successfully",
        });
      } else {
        setError(data.message || 'Failed to delete student');
      }
    } catch (err: any) {
      setError('Error connecting to server');
    } finally {
      setLoading(false);
    }
  };

  // Start editing a student
  const startEdit = (student: Student) => {
    console.log('Starting edit for student:', student);
    setEditingStudent(student);
    setFormData({
      full_name: student.full_name,
      phone: student.phone,
      class: student.class,
      gender: student.gender || ''
    });
    setActiveTab('add'); // Switch to add/edit tab
    setError('');
    setSuccess('');
  };

  // Cancel editing
  const cancelEdit = () => {
    setEditingStudent(null);
    setFormData({ full_name: '', phone: '', class: '', gender: '' });
    setError('');
    setSuccess('');
  };

  // Download all students as CSV
  const downloadAllStudents = () => {
    if (filteredStudents.length === 0) {
      toast({
        title: "No data",
        description: "No students to download",
        variant: "destructive"
      });
      return;
    }

    // Create CSV content
    const headers = 'ID,Full Name,Phone,Class';
    const rows = filteredStudents.map(student => 
      `${student.id},"${student.full_name}","${student.phone?.replace(/[^0-9]/g, '') || student.phone}","${student.class}"`
    ).join('\n');
    
    const csvContent = `${headers}\n${rows}`;
    const blob = new Blob([csvContent], { type: 'text/csv;charset=utf-8;' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = `students_list_${new Date().toISOString().split('T')[0]}.csv`;
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    window.URL.revokeObjectURL(url);
    
    toast({
      title: "Success",
      description: `Downloaded ${filteredStudents.length} students`,
    });
  };

  // Download CSV template
  const downloadTemplate = () => {
    const csvContent = 'full_name,phone,gender,class\nJohn Doe,0912345678,Male,Grade 1\nJane Smith,0923456789,Female,Grade 2';
    const blob = new Blob([csvContent], { type: 'text/csv' });
    const url = window.URL.createObjectURL(blob);
    const a = document.createElement('a');
    a.href = url;
    a.download = 'students_template.csv';
    document.body.appendChild(a);
    a.click();
    document.body.removeChild(a);
    window.URL.revokeObjectURL(url);
    toast({
      title: "Template Downloaded",
      description: "CSV template downloaded successfully",
    });
  };

  // Handle bulk upload
  const handleBulkUpload = async (e: React.FormEvent) => {
    e.preventDefault();
    setBulkError('');
    setBulkSuccess('');

    if (!bulkFile) {
      setBulkError('Please select a CSV file');
      return;
    }

    const reader = new FileReader();
    reader.onload = async (event) => {
      try {
        const text = event.target?.result as string;
        const lines = text.split('\n').filter(line => line.trim());
        
        if (lines.length < 2) {
          setBulkError('CSV file is empty or invalid');
          return;
        }

        const headers = lines[0].split(',').map(h => h.trim());
        if (!headers.includes('full_name') || !headers.includes('phone') || !headers.includes('gender') || !headers.includes('class')) {
          setBulkError('CSV must have columns: full_name, phone, gender, class');
          return;
        }

        const studentsToAdd = [];
        for (let i = 1; i < lines.length; i++) {
          const values = lines[i].split(',').map(v => v.trim());
          if (values.length >= 4) {
            studentsToAdd.push({
              full_name: values[0],
              phone: values[1],
              gender: values[2],
              class: values[3]
            });
          }
        }

        if (studentsToAdd.length === 0) {
          setBulkError('No valid student data found in CSV');
          return;
        }

        setLoading(true);
        const response = await fetch('/api/students/bulk', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ students: studentsToAdd })
        });

        const data = await response.json();

        if (response.ok) {
          const summary = data.summary || { inserted: studentsToAdd.length, skipped: 0 };
          let successMessage = `Successfully added ${summary.inserted} student${summary.inserted !== 1 ? 's' : ''}!`;
          
          if (summary.skipped > 0) {
            successMessage += ` (${summary.skipped} duplicate${summary.skipped !== 1 ? 's' : ''} skipped)`;
          }
          
          setBulkSuccess(successMessage);
          setBulkFile(null);
          fetchStudents();
          
          toast({
            title: "Upload Complete",
            description: data.message || successMessage,
          });
        } else {
          setBulkError(data.message || 'Failed to upload students');
        }
      } catch (err: any) {
        setBulkError('Error processing CSV file');
      } finally {
        setLoading(false);
      }
    };

    reader.readAsText(bulkFile);
  };

  // Handle adding a new class (simple approach)
  const handleAddClass = async (e: React.FormEvent) => {
    e.preventDefault();
    setClassError('');
    setClassSuccess('');

    if (!newClassName.trim()) {
      setClassError('Class name is required');
      return;
    }

    // Check if class already exists
    const existingClasses = getClassesFromStudents();
    if (existingClasses.some(c => c.class_name.toLowerCase() === newClassName.trim().toLowerCase())) {
      setClassError('Class already exists');
      return;
    }

    setClassSuccess(`Class "${newClassName}" is ready! You can now add students to this class.`);
    setNewClassName('');
    toast({
      title: "Success",
      description: `Class "${newClassName}" is ready for students`,
    });
  };

  // Start editing a class
  const startEditClass = (classItem: any) => {
    setEditingClass(classItem);
    setEditClassName(classItem.class_name);
    setClassError('');
    setClassSuccess('');
  };

  // Cancel editing class
  const cancelEditClass = () => {
    setEditingClass(null);
    setEditClassName('');
    setClassError('');
    setClassSuccess('');
  };

  // Handle updating a class (rename all students in that class)
  const handleUpdateClass = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!editingClass) return;

    setClassError('');
    setClassSuccess('');

    if (!editClassName.trim()) {
      setClassError('Class name is required');
      return;
    }

    const oldClassName = editingClass.class_name;
    const newClassName = editClassName.trim();

    // Check if new class name already exists
    const existingClasses = getClassesFromStudents();
    if (existingClasses.some(c => c.class_name.toLowerCase() === newClassName.toLowerCase() && c.class_name !== oldClassName)) {
      setClassError('Class name already exists');
      return;
    }

    setLoading(true);
    try {
      // Update all students with the old class name to the new class name
      const studentsToUpdate = students.filter(s => s.class === oldClassName);
      
      const updatePromises = studentsToUpdate.map(student => 
        fetch(`/api/students/${student.id}`, {
          method: 'PUT',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            ...student,
            class: newClassName
          })
        })
      );

      await Promise.all(updatePromises);

      setClassSuccess(`Class renamed from "${oldClassName}" to "${newClassName}" successfully! ${studentsToUpdate.length} student${studentsToUpdate.length !== 1 ? 's' : ''} updated.`);
      setEditingClass(null);
      setEditClassName('');
      fetchStudents(); // Refresh students to show updated class names
      toast({
        title: "Success",
        description: `Class renamed successfully`,
      });
    } catch (err: any) {
      setClassError('Error updating class name');
    } finally {
      setLoading(false);
    }
  };

  // Delete a class (delete all students in that class)
  const handleDeleteClass = async (className: string) => {
    const studentsInClass = students.filter(s => s.class === className);
    
    const confirmMessage = `Are you sure you want to delete class "${className}"? This will delete ${studentsInClass.length} student${studentsInClass.length !== 1 ? 's' : ''} in this class.`;
    
    if (!confirm(confirmMessage)) return;

    setLoading(true);
    try {
      // Delete all students in the class
      const deletePromises = studentsInClass.map(student => 
        fetch(`/api/students/${student.id}`, { method: 'DELETE' })
      );

      await Promise.all(deletePromises);
      
      setClassSuccess(`Class "${className}" and ${studentsInClass.length} student${studentsInClass.length !== 1 ? 's' : ''} deleted successfully`);
      fetchStudents();
      toast({
        title: "Success",
        description: `Class "${className}" deleted successfully`,
      });
    } catch (err: any) {
      setClassError('Error deleting class');
    } finally {
      setLoading(false);
    }
  };

  // Get unique classes from students (simple approach)
  const uniqueClasses = Array.from(new Set(students.map(s => s.class))).filter(Boolean).sort();
  const classesData = getClassesFromStudents();

  // Filter students based on search and class filter, then sort by ID
  const filteredStudents = students
    .filter(student => {
      const matchesSearch = 
        student.id.toString().includes(searchTerm) ||
        student.full_name.toLowerCase().includes(searchTerm.toLowerCase()) ||
        student.phone.includes(searchTerm);
      
      const matchesClass = selectedClass === 'all' || student.class === selectedClass;
      
      return matchesSearch && matchesClass;
    })
    .sort((a, b) => a.id - b.id); // Sort by ID in ascending order

  return (
    <div className="space-y-6">
      <Tabs value={activeTab} onValueChange={setActiveTab} className="w-full">
        <TabsList className="grid w-full grid-cols-4">
          <TabsTrigger value="add" className="flex items-center gap-2">
            {editingStudent ? <Pencil className="w-4 h-4" /> : <Plus className="w-4 h-4" />}
            {editingStudent ? 'Edit Student' : 'Add Student'}
          </TabsTrigger>
          <TabsTrigger value="classes" className="flex items-center gap-2">
            <Plus className="w-4 h-4" />
            Add Class
          </TabsTrigger>
          <TabsTrigger value="bulk" className="flex items-center gap-2">
            <Upload className="w-4 h-4" />
            Bulk Upload
          </TabsTrigger>
          <TabsTrigger value="manage" className="flex items-center gap-2">
            <Search className="w-4 h-4" />
            Manage Students
          </TabsTrigger>
        </TabsList>

        {/* Add/Edit Student Tab */}
        <TabsContent value="add">
          <Card className="border-2">
            <CardHeader>
              <CardTitle>{editingStudent ? 'Edit Student' : 'Add New Student'}</CardTitle>
              <CardDescription>
                {editingStudent ? 'Update student information' : 'Add a new student to the database'}
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

              <form onSubmit={editingStudent ? handleUpdateStudent : handleAddStudent} className="space-y-4">
                <div className="space-y-2">
                  <Label htmlFor="full_name">Full Name *</Label>
                  <Input
                    id="full_name"
                    placeholder="Enter full name"
                    value={formData.full_name}
                    onChange={(e) => setFormData({ ...formData, full_name: e.target.value })}
                    required
                  />
                </div>

                <div className="space-y-2">
                  <Label htmlFor="phone">Phone Number * (must start with 09)</Label>
                  <Input
                    id="phone"
                    type="tel"
                    placeholder="Enter phone number starting with 09"
                    value={formData.phone}
                    onChange={(e) => {
                      // Only allow digits and limit to 10 characters
                      const value = e.target.value.replace(/\D/g, '').slice(0, 10);
                      setFormData({ ...formData, phone: value });
                    }}
                    minLength={10}
                    maxLength={10}
                    pattern="09[0-9]{8}"
                    required
                  />
                  {formData.phone && formData.phone.length !== 10 && (
                    <p className="text-sm text-red-600">Phone number must be exactly 10 digits</p>
                  )}
                  {formData.phone && formData.phone.length === 10 && !formData.phone.startsWith('09') && (
                    <p className="text-sm text-red-600">Phone number must start with 09</p>
                  )}
                </div>

                <div className="space-y-2">
                  <Label htmlFor="gender">Gender *</Label>
                  <Select
                    value={formData.gender}
                    onValueChange={(value) => setFormData({ ...formData, gender: value })}
                    required
                  >
                    <SelectTrigger id="gender">
                      <SelectValue placeholder="Select gender" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="Male">Male</SelectItem>
                      <SelectItem value="Female">Female</SelectItem>
                    </SelectContent>
                  </Select>
                </div>

                <div className="space-y-2">
                  <Label htmlFor="class">Class *</Label>
                  {editingStudent ? (
                    // When editing: allow selecting existing class OR typing new one
                    <div className="space-y-2">
                      <Select
                        value={formData.class === '' ? '__custom__' : formData.class}
                        onValueChange={(value) => {
                          if (value === '__custom__') {
                            setFormData({ ...formData, class: '' });
                          } else {
                            setFormData({ ...formData, class: value });
                          }
                        }}
                      >
                        <SelectTrigger id="class">
                          <SelectValue placeholder="Select class or create new" />
                        </SelectTrigger>
                        <SelectContent>
                          {uniqueClasses.map((className) => (
                            <SelectItem key={className} value={className}>
                              {className}
                            </SelectItem>
                          ))}
                          <SelectItem value="__custom__">✏️ Type New Class Name</SelectItem>
                        </SelectContent>
                      </Select>
                      {formData.class === '' && (
                        <Input
                          placeholder="Enter new class name (e.g., CLASS A)"
                          value={formData.class}
                          onChange={(e) => setFormData({ ...formData, class: e.target.value })}
                          autoFocus
                          required
                        />
                      )}
                    </div>
                  ) : (
                    // When adding new: only dropdown (prevents duplicates)
                    uniqueClasses.length > 0 ? (
                      <Select
                        value={formData.class}
                        onValueChange={(value) => setFormData({ ...formData, class: value })}
                        required
                      >
                        <SelectTrigger id="class">
                          <SelectValue placeholder="Select a class" />
                        </SelectTrigger>
                        <SelectContent>
                          {uniqueClasses.map((className) => (
                            <SelectItem key={className} value={className}>
                              {className} ({students.filter(s => s.class === className).length} students)
                            </SelectItem>
                          ))}
                        </SelectContent>
                      </Select>
                    ) : (
                      <div className="space-y-2">
                        <Input
                          id="class"
                          placeholder="Enter first class (e.g., CLASS A)"
                          value={formData.class}
                          onChange={(e) => setFormData({ ...formData, class: e.target.value })}
                          required
                        />
                        <p className="text-xs text-muted-foreground">
                          💡 Creating the first class. Future students will use dropdown to select this class.
                        </p>
                      </div>
                    )
                  )}
                </div>

                <div className="flex gap-2">
                  <Button 
                    type="submit" 
                    className="flex-1" 
                    disabled={loading || (!editingStudent && !currentUser?.can_add_student) || (editingStudent && !currentUser?.can_update_student) || false}
                  >
                    {loading ? 'Processing...' : editingStudent ? '✓ Update Student' : '+ Add Student'}
                  </Button>
                  {editingStudent && (
                    <Button type="button" variant="outline" onClick={cancelEdit} disabled={loading || false}>
                      Cancel
                    </Button>
                  )}
                </div>
                {!editingStudent && !currentUser?.can_add_student && (
                  <Alert variant="destructive">
                    <AlertCircle className="h-4 w-4" />
                    <AlertDescription>
                      You don't have permission to add students.
                    </AlertDescription>
                  </Alert>
                )}
                {editingStudent && !currentUser?.can_update_student && (
                  <Alert variant="destructive">
                    <AlertCircle className="h-4 w-4" />
                    <AlertDescription>
                      You don't have permission to update students.
                    </AlertDescription>
                  </Alert>
                )}
              </form>
            </CardContent>
          </Card>
        </TabsContent>

        {/* Add Class Tab */}
        <TabsContent value="classes">
          <Card className="border-2">
            <CardHeader>
              <CardTitle>Class Management</CardTitle>
              <CardDescription>
                Create new classes and manage existing ones
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-6">
              {/* Add New Class Section */}
              <div className="space-y-4">
                <h3 className="text-lg font-semibold">Add New Class</h3>
                
                {classError && (
                  <Alert variant="destructive">
                    <AlertCircle className="h-4 w-4" />
                    <AlertDescription>{classError}</AlertDescription>
                  </Alert>
                )}
                
                {classSuccess && (
                  <Alert className="border-green-200 bg-green-50">
                    <AlertCircle className="h-4 w-4 text-green-600" />
                    <AlertDescription className="text-green-800">{classSuccess}</AlertDescription>
                  </Alert>
                )}

                {editingClass ? (
                  // Edit Class Form
                  <form onSubmit={handleUpdateClass} className="space-y-4">
                    <div className="space-y-2">
                      <Label htmlFor="editClassName">Edit Class Name *</Label>
                      <Input
                        id="editClassName"
                        placeholder="Enter new class name"
                        value={editClassName}
                        onChange={(e) => setEditClassName(e.target.value)}
                        required
                      />
                      <p className="text-xs text-muted-foreground">
                        ✏️ Editing: {editingClass.class_name}
                      </p>
                    </div>

                    <div className="flex gap-2">
                      <Button 
                        type="submit" 
                        className="flex-1" 
                        disabled={loading || !currentUser?.can_add_student}
                      >
                        {loading ? 'Updating...' : '✓ Update Class'}
                      </Button>
                      <Button 
                        type="button" 
                        variant="outline" 
                        onClick={cancelEditClass}
                        disabled={loading}
                      >
                        Cancel
                      </Button>
                    </div>
                  </form>
                ) : (
                  // Add New Class Form
                  <form onSubmit={handleAddClass} className="space-y-4">
                    <div className="space-y-2">
                      <Label htmlFor="className">Class Name *</Label>
                      <Input
                        id="className"
                        placeholder="Enter class name (e.g., Grade 10A, Class A, etc.)"
                        value={newClassName}
                        onChange={(e) => setNewClassName(e.target.value)}
                        required
                      />
                      <p className="text-xs text-muted-foreground">
                        💡 Choose a clear, unique name for your class
                      </p>
                    </div>

                    <Button 
                      type="submit" 
                      className="w-full" 
                      disabled={loading || !currentUser?.can_add_student}
                    >
                      {loading ? 'Creating...' : '+ Create Class'}
                    </Button>
                    
                    {!currentUser?.can_add_student && (
                      <Alert variant="destructive">
                        <AlertCircle className="h-4 w-4" />
                        <AlertDescription>
                          You don't have permission to create classes.
                        </AlertDescription>
                      </Alert>
                    )}
                  </form>
                )}
              </div>

              {/* Existing Classes Section */}
              <div className="space-y-4">
                <h3 className="text-lg font-semibold">Existing Classes ({classesData.length})</h3>
                
                {classesData.length === 0 ? (
                  <div className="text-center py-8 text-muted-foreground">
                    <div className="text-4xl mb-2">📚</div>
                    <p>No classes found</p>
                    <p className="text-sm">Add students to create classes automatically</p>
                  </div>
                ) : (
                  <div className="grid gap-4">
                    {classesData.map((classItem) => (
                      <div key={classItem.class_name} className="flex items-center justify-between p-4 border rounded-lg bg-muted/30">
                        <div>
                          <h4 className="font-medium">{classItem.class_name}</h4>
                          <p className="text-sm text-muted-foreground">
                            {classItem.student_count} student{classItem.student_count !== 1 ? 's' : ''}
                          </p>
                        </div>
                        <div className="flex gap-2">
                          <Button
                            variant="outline"
                            size="sm"
                            onClick={() => {
                              setSelectedClass(classItem.class_name);
                              setActiveTab('manage');
                            }}
                          >
                            View Students
                          </Button>
                          <Button
                            variant="outline"
                            size="sm"
                            onClick={() => startEditClass(classItem)}
                            disabled={loading || !currentUser?.can_add_student}
                          >
                            <Pencil className="w-4 h-4" />
                          </Button>
                          <Button
                            variant="destructive"
                            size="sm"
                            onClick={() => handleDeleteClass(classItem.class_name)}
                            disabled={loading || !currentUser?.can_delete_student}
                          >
                            <Trash2 className="w-4 h-4" />
                          </Button>
                        </div>
                      </div>
                    ))}
                  </div>
                )}
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        {/* Bulk Upload Tab */}
        <TabsContent value="bulk">
          <Card className="border-2">
            <CardHeader>
              <CardTitle>Bulk Upload Students</CardTitle>
              <CardDescription>
                Upload multiple students at once using a CSV file
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              {bulkError && (
                <Alert variant="destructive">
                  <AlertCircle className="h-4 w-4" />
                  <AlertDescription>{bulkError}</AlertDescription>
                </Alert>
              )}
              
              {bulkSuccess && (
                <Alert className="border-green-200 bg-green-50">
                  <AlertCircle className="h-4 w-4 text-green-600" />
                  <AlertDescription className="text-green-800">{bulkSuccess}</AlertDescription>
                </Alert>
              )}

              <div className="space-y-4">
                <div className="flex items-center justify-between p-4 border rounded-lg bg-muted/50">
                  <div>
                    <h3 className="font-medium">Download CSV Template</h3>
                    <p className="text-sm text-muted-foreground">
                      Get a sample CSV file with the correct format
                    </p>
                  </div>
                  <Button onClick={downloadTemplate} variant="outline">
                    <Download className="w-4 h-4 mr-2" />
                    Download Template
                  </Button>
                </div>

                <div className="space-y-2">
                  <Label>CSV File Format</Label>
                  <div className="p-4 border rounded-lg bg-muted/30">
                    <p className="text-sm font-mono">full_name,phone,class</p>
                  </div>
                </div>

                <form onSubmit={handleBulkUpload} className="space-y-4">
                  <div className="space-y-2">
                    <Label htmlFor="csvFile">Upload CSV File *</Label>
                    <Input
                      id="csvFile"
                      type="file"
                      accept=".csv"
                      onChange={(e) => setBulkFile(e.target.files?.[0] || null)}
                      required
                    />
                    {bulkFile && (
                      <p className="text-sm text-muted-foreground">
                        Selected: {bulkFile.name}
                      </p>
                    )}
                  </div>

                  <Button 
                    type="submit" 
                    className="w-full" 
                    disabled={loading || !currentUser?.can_upload_students}
                  >
                    {loading ? 'Uploading...' : '📤 Upload Students'}
                  </Button>
                  {!currentUser?.can_upload_students && (
                    <Alert variant="destructive">
                      <AlertCircle className="h-4 w-4" />
                      <AlertDescription>
                        You don't have permission to upload students via CSV.
                      </AlertDescription>
                    </Alert>
                  )}
                </form>
              </div>
            </CardContent>
          </Card>
        </TabsContent>

        {/* Manage Students Tab */}
        <TabsContent value="manage">
          <Card className="border-2">
            <CardHeader>
              <div className="flex items-center justify-between">
                <div>
                  <CardTitle>Manage Students</CardTitle>
                  <CardDescription>
                    View and manage all students ({filteredStudents.length} students)
                  </CardDescription>
                </div>
                <Button 
                  onClick={downloadAllStudents} 
                  variant="outline"
                  disabled={filteredStudents.length === 0}
                  className="flex items-center gap-2"
                >
                  <Download className="w-4 h-4" />
                  Download All Students
                </Button>
              </div>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid grid-cols-1 md:grid-cols-2 gap-4">
                <div className="space-y-2">
                  <Label htmlFor="search">Search</Label>
                  <div className="relative">
                    <Search className="absolute left-3 top-1/2 transform -translate-y-1/2 w-4 h-4 text-muted-foreground" />
                    <Input
                      id="search"
                      placeholder="Search by ID, name, or phone..."
                      value={searchTerm}
                      onChange={(e) => setSearchTerm(e.target.value)}
                      className="pl-10"
                    />
                  </div>
                </div>

                <div className="space-y-2">
                  <Label htmlFor="classFilter">Filter by Class</Label>
                  <Select value={selectedClass} onValueChange={setSelectedClass}>
                    <SelectTrigger id="classFilter">
                      <Filter className="w-4 h-4 mr-2" />
                      <SelectValue placeholder="All Classes" />
                    </SelectTrigger>
                    <SelectContent>
                      <SelectItem value="all">All Classes ({students.length})</SelectItem>
                      {uniqueClasses.map((className) => (
                        <SelectItem key={className} value={className}>
                          {className} ({students.filter(s => s.class === className).length})
                        </SelectItem>
                      ))}
                    </SelectContent>
                  </Select>
                </div>
              </div>

              {(searchTerm || selectedClass !== 'all') && (
                <div className="flex items-center justify-between p-3 bg-muted/50 rounded-lg">
                  <p className="text-sm text-muted-foreground">
                    Showing {filteredStudents.length} of {students.length} students
                  </p>
                  <Button
                    variant="ghost"
                    size="sm"
                    onClick={() => {
                      setSearchTerm('');
                      setSelectedClass('all');
                    }}
                  >
                    Clear Filters
                  </Button>
                </div>
              )}

              {loading && <p className="text-center text-muted-foreground">Loading...</p>}

              <div className="rounded-lg border overflow-x-auto">
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>ID</TableHead>
                      <TableHead>Full Name</TableHead>
                      <TableHead>Phone</TableHead>
                      <TableHead>Class</TableHead>
                      <TableHead className="text-right">Actions</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {filteredStudents.length === 0 ? (
                      <TableRow>
                        <TableCell colSpan={5} className="text-center text-muted-foreground py-6">
                          {students.length === 0 ? 'No students found. Add your first student!' : 'No matching students found'}
                        </TableCell>
                      </TableRow>
                    ) : (
                      filteredStudents.map((student) => (
                        <TableRow key={student.id}>
                          <TableCell className="font-mono text-sm">{student.id}</TableCell>
                          <TableCell className="font-medium">{student.full_name}</TableCell>
                          <TableCell>{student.phone?.replace(/[^0-9]/g, '') || student.phone}</TableCell>
                          <TableCell>{student.class}</TableCell>
                          <TableCell className="text-right">
                            <div className="flex justify-end gap-2">
                              <Button
                                variant="outline"
                                size="sm"
                                onClick={() => startEdit(student)}
                                disabled={loading || !currentUser?.can_update_student}
                              >
                                <Pencil className="w-4 h-4 mr-1" />
                                Edit
                              </Button>
                              <Button
                                variant="destructive"
                                size="sm"
                                onClick={() => handleDeleteStudent(student.id)}
                                disabled={loading || !currentUser?.can_delete_student}
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
      </Tabs>
    </div>
  );
}
