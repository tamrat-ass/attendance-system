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
  name: string;  // Changed from class_name to name
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
    name: '',  // Changed from class_name to name
    description: ''
  });

  // Fetch classes from API
  const fetchClasses = async () => {
    setLoading(true);
    try {
      const response = await fetch('/api/classes', {
        cache: 'no-store',
        headers: {
          'Cache-Control': 'no-cache'
        }
      });
      const data = await response.json();
      
      if (response.ok) {
        console.log('Fetched classes:', data.data);
        setClasses(data.data || []);
        setError('');
      } else {
        setError(data.message || 'Failed to fetch classes');
      }
    } catch (err) {
      console.error('Fetch error:', err);
      setError('Failed to connect to server');
    } finally {
      setLoading(false);
    }
  };

  useEffect(() => {
    fetchClasses();
  }, []);

  // Add new class
  const handleAddClass = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setSuccess('');

    if (!formData.name.trim()) {  // Changed from class_name to name
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
        setFormData({ name: '', description: '' });  // Changed from class_name to name
        setShowForm(false);
        fetchClasses();
        toast({
          title: "Success",
          description: "Class added successfully!",
        });
      } else {
        setError(data.message || 'Failed to add class');
      }
    } catch (err) {
      setError('Failed to add class');
    } finally {
      setLoading(false);
    }
  };

  // Update existing class
  const handleUpdateClass = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setSuccess('');

    if (!formData.name.trim()) {  // Changed from class_name to name
      setError('Class name is required');
      return;
    }

    if (!editingClass) return;

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
        setFormData({ name: '', description: '' });  // Changed from class_name to name
        setShowForm(false);
        fetchClasses();
        toast({
          title: "Success",
          description: "Class updated successfully!",
        });
      } else {
        setError(data.message || 'Failed to update class');
      }
    } catch (err) {
      setError('Failed to update class');
    } finally {
      setLoading(false);
    }
  };

  // Delete class
  const handleDeleteClass = async (id: number, className: string) => {
    if (!confirm(`Are you sure you want to delete "${className}"?`)) {
      return;
    }

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
          description: "Class deleted successfully!",
        });
      } else {
        setError(data.message || 'Failed to delete class');
      }
    } catch (err) {
      setError('Failed to delete class');
    } finally {
      setLoading(false);
    }
  };

  // Start editing a class
  const startEdit = (classItem: Class) => {
    setEditingClass(classItem);
    setFormData({
      name: classItem.name,  // Changed from class_name to name
      description: classItem.description || ''
    });
    setShowForm(true);
    setError('');
    setSuccess('');
  };

  // Cancel editing
  const cancelEdit = () => {
    setEditingClass(null);
    setFormData({ name: '', description: '' });  // Changed from class_name to name
    setShowForm(false);
    setError('');
    setSuccess('');
  };

  // Start adding new class
  const startAdd = () => {
    setEditingClass(null);
    setFormData({ name: '', description: '' });  // Changed from class_name to name
    setShowForm(true);
    setError('');
    setSuccess('');
  };

  return (
    <div className="space-y-6">
      <div className="flex items-center justify-between">
        <div>
          <h2 className="text-2xl font-bold tracking-tight">Class Management</h2>
          <p className="text-muted-foreground">
            Manage your school classes and their details
          </p>
        </div>
        <Button onClick={startAdd} className="flex items-center gap-2">
          <Plus className="h-4 w-4" />
          Add Class
        </Button>
      </div>

      {/* Add/Edit Form */}
      {showForm && (
        <Card>
          <CardHeader>
            <CardTitle className="flex items-center gap-2">
              <BookOpen className="h-5 w-5" />
              {editingClass ? 'Edit Class' : 'Add New Class'}
            </CardTitle>
            <CardDescription>
              {editingClass ? 'Update the class information below' : 'Enter the details for the new class'}
            </CardDescription>
          </CardHeader>
          <CardContent>
            <form onSubmit={editingClass ? handleUpdateClass : handleAddClass} className="space-y-4">
              <div className="space-y-2">
                <Label htmlFor="name">Class Name *</Label>  {/* Changed from class_name to name */}
                <Input
                  id="name"  {/* Changed from class_name to name */}
                  type="text"
                  placeholder="Enter class name (e.g., Grade 10A, Mathematics 101)"
                  value={formData.name}  {/* Changed from class_name to name */}
                  onChange={(e) => setFormData({ ...formData, name: e.target.value })}  {/* Changed from class_name to name */}
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
                <Button type="submit" disabled={loading}>
                  {loading ? 'Saving...' : (editingClass ? 'Update Class' : 'Add Class')}
                </Button>
                <Button type="button" variant="outline" onClick={cancelEdit}>
                  Cancel
                </Button>
              </div>
            </form>
          </CardContent>
        </Card>
      )}

      {/* Error/Success Messages */}
      {error && (
        <Alert variant="destructive">
          <AlertCircle className="h-4 w-4" />
          <AlertDescription>{error}</AlertDescription>
        </Alert>
      )}

      {success && (
        <Alert>
          <AlertDescription className="text-green-600">{success}</AlertDescription>
        </Alert>
      )}

      {/* Classes Table */}
      <Card>
        <CardHeader>
          <CardTitle>Existing Classes</CardTitle>
          <CardDescription>
            {classes.length} class{classes.length !== 1 ? 'es' : ''} total
          </CardDescription>
        </CardHeader>
        <CardContent>
          {loading ? (
            <div className="text-center py-4">Loading classes...</div>
          ) : classes.length === 0 ? (
            <div className="text-center py-8 text-muted-foreground">
              <BookOpen className="h-12 w-12 mx-auto mb-4 opacity-50" />
              <p>No classes found</p>
              <p className="text-sm">Click "Add Class" to create your first class</p>
            </div>
          ) : (
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>ID</TableHead>
                  <TableHead>Class Name</TableHead>
                  <TableHead>Description</TableHead>
                  <TableHead>Created</TableHead>
                  <TableHead>Actions</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {classes.map((classItem) => (
                  <TableRow key={classItem.id}>
                    <TableCell className="font-mono text-sm">{classItem.id}</TableCell>
                    <TableCell className="font-medium">{classItem.name}</TableCell>  {/* Changed from class_name to name */}
                    <TableCell>{classItem.description || '-'}</TableCell>
                    <TableCell className="text-sm text-muted-foreground">
                      {new Date(classItem.created_at).toLocaleDateString()}
                    </TableCell>
                    <TableCell>
                      <div className="flex gap-2">
                        <Button
                          variant="outline"
                          size="sm"
                          onClick={() => startEdit(classItem)}
                          disabled={loading}
                        >
                          <Pencil className="h-4 w-4" />
                        </Button>
                        <Button
                          variant="destructive"
                          size="sm"
                          onClick={() => handleDeleteClass(classItem.id, classItem.name)}  {/* Changed from class_name to name */}
                          disabled={loading}
                        >
                          <Trash2 className="h-4 w-4" />
                        </Button>
                      </div>
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          )}
        </CardContent>
      </Card>
    </div>
  );
}