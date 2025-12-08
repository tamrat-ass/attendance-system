'use client';

import { useState, useEffect } from 'react';
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from '@/components/ui/card';
import { Input } from '@/components/ui/input';
import { Label } from '@/components/ui/label';
import { Table, TableBody, TableCell, TableHead, TableHeader, TableRow } from '@/components/ui/table';
import { Textarea } from '@/components/ui/textarea';
import { Trash2, Plus, Pencil, BookOpen } from 'lucide-react';
import { AlertCircle } from 'lucide-react';
import { Alert, AlertDescription } from '@/components/ui/alert';
import { useToast } from '@/hooks/use-toast';

interface Class {
  id: number;
  class_name: string;
  description?: string;
  created_at: string;
}

export default function ClassManagement() {
  const [classes, setClasses] = useState<Class[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');
  const [editingClass, setEditingClass] = useState<Class | null>(null);
  const [showForm, setShowForm] = useState(false);
  const { toast } = useToast();

  const [formData, setFormData] = useState({
    class_name: '',
    description: ''
  });

  // Fetch classes from API
  const fetchClasses = async () => {
    setLoading(true);
    try {
      const response = await fetch('/api/classes', {
        cache: 'no-store', // Ensure we get fresh data
        headers: {
          'Cache-Control': 'no-cache'
        }
      });
      const data = await response.json();
      
      if (response.ok) {
        console.log('Fetched classes:', data.data);
        setClasses(data.data || []);
        setError(''); // Clear any previous errors
      } else {
        setError(data.message || 'Failed to fetch classes');
        console.error('Failed to fetch classes:', data);
      }
    } catch (err: any) {
      setError('Error connecting to server');
      console.error('Fetch classes error:', err);
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchClasses();
  }, []);

  // Handle adding a new class
  const handleAddClass = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setSuccess('');

    if (!formData.class_name.trim()) {
      setError('Class name is required');
      return;
    }

    setLoading(true);
    try {
      const response = await fetch('/api/classes', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(formData)
      });

      const data = await response.json();

      if (response.ok) {
        setSuccess('Class added successfully!');
        setFormData({ class_name: '', description: '' });
        setShowForm(false);
        fetchClasses();
        toast({
          title: "Success",
          description: "Class added successfully",
        });
      } else {
        setError(data.message || 'Failed to add class');
      }
    } catch (err: any) {
      setError('Error connecting to server');
    } finally {
      setLoading(false);
    }
  };

  // Handle updating a class
  const handleUpdateClass = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!editingClass) return;

    setError('');
    setSuccess('');

    if (!formData.class_name.trim()) {
      setError('Class name is required');
      return;
    }

    setLoading(true);
    try {
      const response = await fetch(`/api/classes/${editingClass.id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(formData)
      });

      const data = await response.json();

      if (response.ok) {
        setSuccess('Class updated successfully!');
        setEditingClass(null);
        setFormData({ class_name: '', description: '' });
        setShowForm(false);
        
        // Force a fresh fetch of classes to ensure UI is updated
        await fetchClasses();
        
        toast({
          title: "Success",
          description: "Class updated successfully",
        });
      } else {
        setError(data.message || 'Failed to update class');
        toast({
          title: "Error",
          description: data.message || 'Failed to update class',
          variant: "destructive"
        });
      }
    } catch (err: any) {
      setError('Error connecting to server');
    } finally {
      setLoading(false);
    }
  };

  // Handle deleting a class
  const handleDeleteClass = async (id: number, className: string) => {
    if (!confirm(`Are you sure you want to delete "${className}"? This action cannot be undone.`)) return;

    setLoading(true);
    try {
      const response = await fetch(`/api/classes/${id}`, {
        method: 'DELETE'
      });

      const data = await response.json();

      if (response.ok) {
        setSuccess('Class deleted successfully!');
        fetchClasses();
        toast({
          title: "Success",
          description: "Class deleted successfully",
        });
      } else {
        setError(data.message || 'Failed to delete class');
      }
    } catch (err: any) {
      setError('Error connecting to server');
    } finally {
      setLoading(false);
    }
  };

  // Start editing a class
  const startEdit = (classItem: Class) => {
    setEditingClass(classItem);
    setFormData({
      class_name: classItem.class_name,
      description: classItem.description || ''
    });
    setShowForm(true);
    setError('');
    setSuccess('');
  };

  // Cancel editing
  const cancelEdit = () => {
    setEditingClass(null);
    setFormData({ class_name: '', description: '' });
    setShowForm(false);
    setError('');
    setSuccess('');
  };

  // Start adding new class
  const startAdd = () => {
    setEditingClass(null);
    setFormData({ class_name: '', description: '' });
    setShowForm(true);
    setError('');
    setSuccess('');
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div className="flex items-center gap-2">
          <BookOpen className="w-6 h-6 text-primary" />
          <h2 className="text-2xl font-bold">Class Management</h2>
        </div>
        <Button onClick={startAdd} className="flex items-center gap-2">
          <Plus className="w-4 h-4" />
          Add New Class
        </Button>
      </div>

      {/* Add/Edit Form */}
      {showForm && (
        <Card className="border-2">
          <CardHeader>
            <CardTitle>{editingClass ? 'Edit Class' : 'Add New Class'}</CardTitle>
            <CardDescription>
              {editingClass ? 'Update class information' : 'Create a new class'}
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

            <form onSubmit={editingClass ? handleUpdateClass : handleAddClass} className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="class_name">Class Name *</Label>
                <Input
                  id="class_name"
                  placeholder="Enter class name (e.g., Grade 10A, Mathematics 101)"
                  value={formData.class_name}
                  onChange={(e) => setFormData({ ...formData, class_name: e.target.value })}
                  required
                />
              </div>

              <div className="space-y-2">
                <Label htmlFor="description">Description</Label>
                <Textarea
                  id="description"
                  placeholder="Enter class description (optional)"
                  value={formData.description}
                  onChange={(e) => setFormData({ ...formData, description: e.target.value })}
                  rows={3}
                />
              </div>

              <div className="flex gap-2">
                <Button type="submit" className="flex-1" disabled={loading}>
                  {loading ? 'Processing...' : editingClass ? '✓ Update Class' : '+ Add Class'}
                </Button>
                <Button type="button" variant="outline" onClick={cancelEdit} disabled={loading}>
                  Cancel
                </Button>
              </div>
            </form>
          </CardContent>
        </Card>
      )}

      {/* Classes List */}
      <Card className="border-2">
        <CardHeader>
          <CardTitle>All Classes</CardTitle>
          <CardDescription>
            Manage your classes ({classes.length} classes)
          </CardDescription>
        </CardHeader>
        <CardContent>
          {loading && <p className="text-center text-muted-foreground">Loading...</p>}

          <div className="rounded-lg border overflow-x-auto">
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>ID</TableHead>
                  <TableHead>Class Name</TableHead>
                  <TableHead>Description</TableHead>
                  <TableHead>Created Date</TableHead>
                  <TableHead className="text-right">Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {classes.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={5} className="text-center text-muted-foreground py-6">
                      No classes found. Click "Add New Class" to get started.
                    </TableCell>
                  </TableRow>
                ) : (
                  classes.map((classItem) => (
                    <TableRow key={classItem.id}>
                      <TableCell className="font-mono text-sm">{classItem.id}</TableCell>
                      <TableCell className="font-medium">{classItem.class_name}</TableCell>
                      <TableCell>{classItem.description || '-'}</TableCell>
                      <TableCell className="text-sm text-muted-foreground">
                        {new Date(classItem.created_at).toLocaleDateString()}
                      </TableCell>
                      <TableCell className="text-right">
                        <div className="flex justify-end gap-2">
                          <Button
                            variant="outline"
                            size="sm"
                            onClick={() => startEdit(classItem)}
                            disabled={loading}
                          >
                            <Pencil className="w-4 h-4 mr-1" />
                            Edit
                          </Button>
                          <Button
                            variant="destructive"
                            size="sm"
                            onClick={() => handleDeleteClass(classItem.id, classItem.class_name)}
                            disabled={loading}
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
    </div>
  );
}