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
import * as XLSX from 'xlsx';

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
  const [sendEmails, setSendEmails] = useState(true);
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

  // Load classes from classes API (not from existing students)
  const [availableClasses, setAvailableClasses] = useState<Array<{id: string, name: string, student_count: number}>>([]);
  
  const loadClassesFromAPI = async () => {
    try {
      const response = await fetch('/api/classes', {
        cache: 'no-store',
        headers: { 'Cache-Control': 'no-cache' }
      });
      
      if (response.ok) {
        const data = await response.json();
        const classesData = data.data || [];
        const classesWithCounts = classesData.map((cls: any) => ({
          id: cls.name,
          name: cls.name,
          student_count: students.filter(s => s.class === cls.name).length
        }));
        setAvailableClasses(classesWithCounts);
        console.log('Classes loaded from API:', classesWithCounts);
      } else {
        // Fallback: extract from existing students if API fails
        const uniqueClasses = Array.from(new Set(students.map(s => s.class))).filter(Boolean).sort();
        const fallbackClasses = uniqueClasses.map(className => ({
          id: className,
          name: className,
          student_count: students.filter(s => s.class === className).length
        }));
        setAvailableClasses(fallbackClasses);
        console.log('Fallback: Classes from students:', fallbackClasses);
      }
    } catch (err) {
      // Fallback: extract from existing students if API fails
      const uniqueClasses = Array.from(new Set(students.map(s => s.class))).filter(Boolean).sort();
      const fallbackClasses = uniqueClasses.map(className => ({
        id: className,
        name: className,
        student_count: students.filter(s => s.class === className).length
      }));
      setAvailableClasses(fallbackClasses);
      console.log('Error loading classes, using fallback:', fallbackClasses);
    }
  };

  // Load students and classes on component mount
  useEffect(() => {
    fetchStudents();
  }, []);

  // Load classes after students are loaded
  useEffect(() => {
    if (students.length > 0) {
      loadClassesFromAPI();
    }
  }, [students]);

  // Handle adding a new student
  const handleAddStudent = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setSuccess('');

    if (!formData.full_name || !formData.phone || !formData.class) {
      setError('Name, phone, and class are required');
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
      setError('Name, phone, and class are required');
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

  // Download all students as Excel file
  const downloadAllStudents = () => {
    if (filteredStudents.length === 0) {
      toast({
        title: "No data",
        description: "No students to download",
        variant: "destructive"
      });
      return;
    }

    // Create Excel-compatible CSV content with BOM for proper UTF-8 encoding (supports Amharic)
    const BOM = '\uFEFF';
    // Headers exactly as requested: full_name, phone, gender, class
    const headers = 'full_name,phone,gender,class';
    const rows = filteredStudents.map(student => 
      `"${student.full_name}","${student.phone || ''}","${student.gender || 'male'}","${student.class}"`
    ).join('\n');
    
    const csvContent = `${BOM}${headers}\n${rows}`;
    
    // Create CSV file that opens in Excel
    const blob = new Blob([csvContent], { 
      type: 'text/csv;charset=utf-8;' 
    });
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
      description: `Downloaded ${filteredStudents.length} students as CSV file (opens in Excel)`,
    });
  };

  // Download Excel template
  const downloadTemplate = () => {
    try {
      // Create sample data for Excel template
      const templateData = [
        ['full_name', 'phone', 'gender', 'class', 'email'],
        ['ታምራት አሜሪ', '0937383899', 'Male', 'አስተባበሪ', 'tamrat.ameri@gmail.com'],
        ['Sample Student', '0912345678', 'Female', 'Grade 1', 'sample.student@gmail.com'],
        ['John Doe', '0923456789', 'Male', 'Grade 2', 'john.doe@gmail.com'],
        ['Jane Smith', '0934567890', 'Female', 'Grade 3', 'jane.smith@gmail.com']
      ];

      // Create workbook and worksheet
      const workbook = XLSX.utils.book_new();
      const worksheet = XLSX.utils.aoa_to_sheet(templateData);
      
      // Set column widths for better readability
      worksheet['!cols'] = [
        { width: 20 }, // full_name
        { width: 15 }, // phone
        { width: 10 }, // gender
        { width: 15 }, // class
        { width: 25 }  // email
      ];
      
      // Style the header row
      const headerStyle = {
        font: { bold: true, color: { rgb: "FFFFFF" } },
        fill: { fgColor: { rgb: "366092" } },
        alignment: { horizontal: "center" }
      };
      
      // Apply header styling
      ['A1', 'B1', 'C1', 'D1', 'E1'].forEach(cell => {
        if (worksheet[cell]) {
          worksheet[cell].s = headerStyle;
        }
      });
      
      // Add worksheet to workbook
      XLSX.utils.book_append_sheet(workbook, worksheet, 'Students Template');
      
      // Generate Excel file
      const excelBuffer = XLSX.write(workbook, { bookType: 'xlsx', type: 'array' });
      const blob = new Blob([excelBuffer], { 
        type: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' 
      });
      
      // Download file
      const url = window.URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = `students_template_${new Date().toISOString().split('T')[0]}.xlsx`;
      document.body.appendChild(a);
      a.click();
      document.body.removeChild(a);
      window.URL.revokeObjectURL(url);
      
      toast({
        title: "Template Downloaded",
        description: "Excel template downloaded successfully with sample data",
      });
    } catch (error) {
      console.error('Template download error:', error);
      toast({
        title: "Download Failed",
        description: "Failed to create Excel template. Try again.",
        variant: "destructive"
      });
    }
  };

  // Handle bulk upload
  const handleBulkUpload = async (e: React.FormEvent) => {
    e.preventDefault();
    setBulkError('');
    setBulkSuccess('');

    // Comprehensive file validation
    if (!bulkFile) {
      setBulkError('❌ Please select a file to upload');
      return;
    }

    // Check file type
    const fileName = bulkFile.name.toLowerCase();
    const fileExtension = fileName.split('.').pop();
    
    if (!fileName.endsWith('.csv') && !fileName.endsWith('.xlsx') && !fileName.endsWith('.xls')) {
      setBulkError(`❌ Invalid file type: .${fileExtension}\n\n✅ Supported formats:\n• .xlsx (Excel file - recommended)\n• .xls (older Excel file)\n• .csv (comma-separated values)\n\n💡 Tip: Use Excel format for best compatibility with Amharic text`);
      return;
    }

    // Check file size (max 10MB for Excel, 5MB for CSV)
    const maxSize = (fileName.endsWith('.xlsx') || fileName.endsWith('.xls')) ? 10 * 1024 * 1024 : 5 * 1024 * 1024;
    if (bulkFile.size > maxSize) {
      setBulkError(`❌ File too large: ${(bulkFile.size / 1024 / 1024).toFixed(1)}MB\n\n✅ Maximum file size: ${maxSize / 1024 / 1024}MB for ${fileName.endsWith('.xlsx') || fileName.endsWith('.xls') ? 'Excel' : 'CSV'} files\n\n💡 Tip: Split large files into smaller batches (max 1000 students per file)`);
      return;
    }

    // Check if file is empty
    if (bulkFile.size < 50) {
      setBulkError('❌ File appears to be empty or corrupted\n\n💡 Make sure your file contains:\n• Header row (full_name, phone, gender, class)\n• At least one data row with student information');
      return;
    }

    console.log('📁 File validation passed:', {
      name: bulkFile.name,
      size: `${(bulkFile.size / 1024).toFixed(1)}KB`,
      type: bulkFile.type,
      extension: fileExtension
    });

    const isExcelFile = fileName.endsWith('.xlsx') || fileName.endsWith('.xls');
    const isCsvFile = fileName.endsWith('.csv');

    try {
      let studentsToAdd: any[] = [];

      if (isExcelFile) {
        // Handle Excel files (.xlsx, .xls)
        console.log('📊 Processing Excel file:', bulkFile.name);
        setLoading(true);
        
        const reader = new FileReader();
        reader.onload = async (event) => {
          try {
            const data = event.target?.result;
            if (!data) {
              setBulkError('❌ Failed to read Excel file\n\n💡 Try:\n• Re-saving the file\n• Using a different Excel file\n• Converting to CSV format');
              setLoading(false);
              return;
            }

            console.log('📊 Reading Excel workbook...');
            const workbook = XLSX.read(data, { 
              type: 'array',
              cellDates: true,
              cellNF: false,
              cellText: false
            });
            
            // Check if workbook has sheets
            if (!workbook.SheetNames || workbook.SheetNames.length === 0) {
              setBulkError('❌ Excel file has no worksheets\n\n💡 Make sure your Excel file has at least one worksheet with data');
              setLoading(false);
              return;
            }
            
            // Get first worksheet
            const sheetName = workbook.SheetNames[0];
            console.log('📊 Using worksheet:', sheetName);
            
            const worksheet = workbook.Sheets[sheetName];
            if (!worksheet) {
              setBulkError('❌ Cannot read worksheet data\n\n💡 Try:\n• Opening and re-saving the Excel file\n• Checking if the worksheet is protected\n• Using a different Excel file');
              setLoading(false);
              return;
            }
            
            // Convert to JSON with proper handling
            const jsonData = XLSX.utils.sheet_to_json(worksheet, { 
              header: 1,
              defval: '',
              blankrows: false
            });
            
            console.log('📊 Excel data parsed, rows:', jsonData.length);
            console.log('📊 First few rows:', jsonData.slice(0, 3));
            
            if (jsonData.length < 2) {
              setBulkError('❌ Excel file is empty or has no data rows\n\n💡 Make sure your Excel file has:\n• Header row (full_name, phone, gender, class)\n• At least one data row with student information\n\n📋 Current rows found: ' + jsonData.length);
              setLoading(false);
              return;
            }

            // Validate headers
            const headers = (jsonData[0] as string[]).map(h => h?.toString().trim().toLowerCase());
            console.log('📊 Excel headers found:', headers);
            
            // Check required columns (flexible matching)
            const requiredColumns = ['full_name', 'phone', 'gender', 'class', 'email'];
            const headerMap: {[key: string]: number} = {};
            
            // Map headers to column indices
            headers.forEach((header, index) => {
              const cleanHeader = header.replace(/[^a-z_]/g, '');
              if (requiredColumns.includes(cleanHeader)) {
                headerMap[cleanHeader] = index;
              }
            });
            
            const missingColumns = requiredColumns.filter(col => !(col in headerMap));
            
            if (missingColumns.length > 0) {
              setBulkError(`❌ Missing required columns: ${missingColumns.join(', ')}\n\n✅ Required columns (exact names):\n• full_name\n• phone\n• gender\n• class\n• email\n\n📋 Found headers: ${headers.join(', ')}\n\n💡 Make sure column names match exactly (case-sensitive)`);
              setLoading(false);
              return;
            }

            // Parse data rows with better validation
            const studentsToAdd: any[] = [];
            const errors: string[] = [];
            
            for (let i = 1; i < jsonData.length; i++) {
              const row = jsonData[i] as any[];
              if (!row || row.length === 0) continue; // Skip empty rows
              
              try {
                const studentData = {
                  full_name: (row[headerMap.full_name] || '').toString().trim(),
                  phone: (row[headerMap.phone] || '').toString().trim(),
                  gender: (row[headerMap.gender] || 'male').toString().trim(),
                  class: (row[headerMap.class] || '').toString().trim(),
                  email: (row[headerMap.email] || '').toString().trim()
                };
                
                // Validate required fields
                if (!studentData.full_name) {
                  errors.push(`Row ${i + 1}: Missing full name`);
                  continue;
                }
                if (!studentData.phone) {
                  errors.push(`Row ${i + 1}: Missing phone number`);
                  continue;
                }
                if (!studentData.class) {
                  errors.push(`Row ${i + 1}: Missing class`);
                  continue;
                }
                if (!studentData.email) {
                  errors.push(`Row ${i + 1}: Missing email address`);
                  continue;
                }
                
                // Validate email format - must be @gmail.com
                if (!/^[\w-\.]+@gmail\.com$/.test(studentData.email)) {
                  errors.push(`Row ${i + 1}: Invalid email "${studentData.email}" (must be @gmail.com)`);
                  continue;
                }
                
                // Clean phone number (remove spaces, dashes, etc.)
                studentData.phone = studentData.phone.replace(/[\s\-\(\)]/g, '');
                
                // Validate phone format
                if (!/^09\d{8}$/.test(studentData.phone)) {
                  errors.push(`Row ${i + 1}: Invalid phone "${studentData.phone}" (must be 09xxxxxxxx)`);
                  continue;
                }
                
                // Normalize gender
                const genderLower = studentData.gender.toLowerCase();
                if (genderLower.includes('m') || genderLower === 'male') {
                  studentData.gender = 'Male';
                } else if (genderLower.includes('f') || genderLower === 'female') {
                  studentData.gender = 'Female';
                } else {
                  studentData.gender = 'Male'; // Default
                }
                
                studentsToAdd.push(studentData);
                
              } catch (rowError) {
                errors.push(`Row ${i + 1}: Error processing data - ${rowError}`);
              }
            }
            
            // Check for validation errors
            if (errors.length > 0) {
              const errorMessage = `❌ Found ${errors.length} error(s) in Excel file:\n\n${errors.slice(0, 5).join('\n')}${errors.length > 5 ? `\n... and ${errors.length - 5} more errors` : ''}\n\n💡 Please fix these issues and try again`;
              setBulkError(errorMessage);
              setLoading(false);
              return;
            }
            
            if (studentsToAdd.length === 0) {
              setBulkError('❌ No valid student data found in Excel file\n\n💡 Make sure your Excel file has:\n• Proper column headers (full_name, phone, gender, class)\n• At least one row with complete student data');
              setLoading(false);
              return;
            }
            
            console.log(`📊 Successfully parsed ${studentsToAdd.length} students from Excel`);
            await processStudentUpload(studentsToAdd);
            
          } catch (error) {
            console.error('📊 Excel parsing error:', error);
            setBulkError(`❌ Failed to parse Excel file\n\nError: ${error instanceof Error ? error.message : 'Unknown error'}\n\n💡 Try:\n• Re-saving the Excel file\n• Converting to CSV format\n• Checking for corrupted data\n• Using a simpler Excel format`);
            setLoading(false);
          }
        };
        
        reader.onerror = () => {
          setBulkError('❌ Failed to read Excel file\n\n💡 Try:\n• Using a different file\n• Checking file permissions\n• Converting to CSV format');
          setLoading(false);
        };
        
        reader.readAsArrayBuffer(bulkFile);
        
      } else if (isCsvFile) {
        // Handle CSV files
        console.log('📄 Processing CSV file:', bulkFile.name);
        setLoading(true);
        
        const reader = new FileReader();
        reader.onload = async (event) => {
          try {
            const text = event.target?.result as string;
            if (!text || text.trim().length === 0) {
              setBulkError('❌ CSV file is empty\n\n💡 Make sure your CSV file contains data');
              setLoading(false);
              return;
            }
            
            console.log('📄 CSV file content preview:', text.substring(0, 200) + '...');
            
            // Enhanced CSV parser handling quoted fields and various delimiters
            const parseCSVLine = (line: string): string[] => {
              const result = [];
              let current = '';
              let inQuotes = false;
              let quoteChar = '';
              
              for (let i = 0; i < line.length; i++) {
                const char = line[i];
                const nextChar = line[i + 1];
                
                if ((char === '"' || char === "'") && !inQuotes) {
                  inQuotes = true;
                  quoteChar = char;
                } else if (char === quoteChar && inQuotes) {
                  if (nextChar === quoteChar) {
                    // Escaped quote
                    current += char;
                    i++; // Skip next quote
                  } else {
                    inQuotes = false;
                    quoteChar = '';
                  }
                } else if (char === ',' && !inQuotes) {
                  result.push(current.trim());
                  current = '';
                } else {
                  current += char;
                }
              }
              result.push(current.trim());
              return result;
            };

            // Split lines and filter empty ones
            const lines = text.split(/\r?\n/).filter(line => line.trim());
            
            if (lines.length < 2) {
              setBulkError(`❌ CSV file has insufficient data\n\n📋 Found ${lines.length} line(s)\n\n💡 Make sure your CSV file has:\n• Header row (full_name, phone, gender, class)\n• At least one data row with student information`);
              setLoading(false);
              return;
            }

            // Parse and validate headers
            const headers = parseCSVLine(lines[0]).map(h => h.replace(/['"]/g, '').trim().toLowerCase());
            console.log('📄 CSV headers found:', headers);
            
            // Check required columns with flexible matching
            const requiredColumns = ['full_name', 'phone', 'gender', 'class', 'email'];
            const headerMap: {[key: string]: number} = {};
            
            // Map headers to column indices (allow some flexibility)
            headers.forEach((header, index) => {
              const cleanHeader = header.replace(/[^a-z_]/g, '');
              if (requiredColumns.includes(cleanHeader)) {
                headerMap[cleanHeader] = index;
              }
              // Alternative mappings
              if (header.includes('name')) headerMap['full_name'] = index;
              if (header.includes('phone') || header.includes('mobile')) headerMap['phone'] = index;
              if (header.includes('gender') || header.includes('sex')) headerMap['gender'] = index;
              if (header.includes('class') || header.includes('grade')) headerMap['class'] = index;
              if (header.includes('email') || header.includes('mail')) headerMap['email'] = index;
            });
            
            const missingColumns = requiredColumns.filter(col => !(col in headerMap));
            
            if (missingColumns.length > 0) {
              setBulkError(`❌ Missing required columns: ${missingColumns.join(', ')}\n\n✅ Required columns (exact names):\n• full_name\n• phone\n• gender\n• class\n• email\n\n📋 Found headers: ${headers.join(', ')}\n\n💡 Make sure column names match exactly`);
              setLoading(false);
              return;
            }

            // Parse data rows with comprehensive validation
            const studentsToAdd: any[] = [];
            const errors: string[] = [];
            
            for (let i = 1; i < lines.length; i++) {
              const line = lines[i].trim();
              if (!line) continue; // Skip empty lines
              
              try {
                const values = parseCSVLine(line).map(v => v.replace(/['"]/g, '').trim());
                console.log(`📄 Row ${i} parsed:`, values);
                
                if (values.length < Math.max(...Object.values(headerMap)) + 1) {
                  errors.push(`Row ${i + 1}: Insufficient columns (expected ${Math.max(...Object.values(headerMap)) + 1}, got ${values.length})`);
                  continue;
                }
                
                const studentData = {
                  full_name: (values[headerMap.full_name] || '').trim(),
                  phone: (values[headerMap.phone] || '').trim(),
                  gender: (values[headerMap.gender] || 'male').trim(),
                  class: (values[headerMap.class] || '').trim(),
                  email: (values[headerMap.email] || '').trim()
                };
                
                // Validate required fields
                if (!studentData.full_name) {
                  errors.push(`Row ${i + 1}: Missing full name`);
                  continue;
                }
                if (!studentData.phone) {
                  errors.push(`Row ${i + 1}: Missing phone number`);
                  continue;
                }
                if (!studentData.class) {
                  errors.push(`Row ${i + 1}: Missing class`);
                  continue;
                }
                if (!studentData.email) {
                  errors.push(`Row ${i + 1}: Missing email address`);
                  continue;
                }
                
                // Validate email format - must be @gmail.com
                if (!/^[\w-\.]+@gmail\.com$/.test(studentData.email)) {
                  errors.push(`Row ${i + 1}: Invalid email "${studentData.email}" (must be @gmail.com)`);
                  continue;
                }
                
                // Clean and validate phone number
                studentData.phone = studentData.phone.replace(/[\s\-\(\)]/g, '');
                if (!/^09\d{8}$/.test(studentData.phone)) {
                  errors.push(`Row ${i + 1}: Invalid phone "${studentData.phone}" (must be 09xxxxxxxx)`);
                  continue;
                }
                
                // Normalize gender
                const genderLower = studentData.gender.toLowerCase();
                if (genderLower.includes('m') || genderLower === 'male') {
                  studentData.gender = 'Male';
                } else if (genderLower.includes('f') || genderLower === 'female') {
                  studentData.gender = 'Female';
                } else {
                  studentData.gender = 'Male'; // Default
                }
                
                studentsToAdd.push(studentData);
                
              } catch (rowError) {
                errors.push(`Row ${i + 1}: Error processing data - ${rowError}`);
              }
            }
            
            // Check for validation errors
            if (errors.length > 0) {
              const errorMessage = `❌ Found ${errors.length} error(s) in CSV file:\n\n${errors.slice(0, 5).join('\n')}${errors.length > 5 ? `\n... and ${errors.length - 5} more errors` : ''}\n\n💡 Please fix these issues and try again`;
              setBulkError(errorMessage);
              setLoading(false);
              return;
            }
            
            if (studentsToAdd.length === 0) {
              setBulkError('❌ No valid student data found in CSV file\n\n💡 Make sure your CSV file has:\n• Proper column headers (full_name, phone, gender, class, email)\n• At least one row with complete student data');
              setLoading(false);
              return;
            }
            
            console.log(`📄 Successfully parsed ${studentsToAdd.length} students from CSV`);
            await processStudentUpload(studentsToAdd);
            
          } catch (error) {
            console.error('📄 CSV parsing error:', error);
            setBulkError(`❌ Failed to parse CSV file\n\nError: ${error instanceof Error ? error.message : 'Unknown error'}\n\n💡 Try:\n• Check file encoding (should be UTF-8)\n• Verify CSV format (comma-separated)\n• Remove special characters\n• Use Excel format instead`);
            setLoading(false);
          }
        };
        
        reader.onerror = () => {
          setBulkError('❌ Failed to read CSV file\n\n💡 Try:\n• Using a different file\n• Checking file permissions\n• Converting to Excel format');
          setLoading(false);
        };
        
        reader.readAsText(bulkFile, 'UTF-8');
      }
    } catch (error) {
      console.error('📁 File processing error:', error);
      setBulkError(`❌ Failed to process file\n\nError: ${error}\n\n💡 Try:\n• Use a different file\n• Check file permissions\n• Ensure file is not corrupted`);
    }

    // Common function to process student upload with enhanced error handling
    const processStudentUpload = async (studentsToAdd: any[]) => {
      try {
        if (studentsToAdd.length === 0) {
          setBulkError('❌ No valid student data found\n\n💡 Make sure your file contains valid student information');
          setLoading(false);
          return;
        }

        console.log(`🚀 Uploading ${studentsToAdd.length} students to server...`);
        
        // Show progress for large uploads
        if (studentsToAdd.length > 100) {
          setBulkSuccess(`📤 Processing ${studentsToAdd.length} students... Please wait.`);
        }

        // Choose API endpoint based on email option
        const apiEndpoint = sendEmails ? '/api/students/bulk-with-email' : '/api/students/bulk';
        
        const response = await fetch(apiEndpoint, {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({ students: studentsToAdd })
        });

        const data = await response.json();
        console.log('📥 Server response:', data);

        if (response.ok) {
          const summary = data.summary || { inserted: studentsToAdd.length, skipped: 0, total: studentsToAdd.length };
          
          let successMessage = `✅ Upload completed successfully!\n\n`;
          successMessage += `📊 Summary:\n`;
          successMessage += `• Total processed: ${summary.total}\n`;
          successMessage += `• Successfully added: ${summary.inserted}\n`;
          
          if (summary.skipped > 0) {
            successMessage += `• Duplicates skipped: ${summary.skipped}\n`;
          }
          
          // Add email results if using email API
          if (sendEmails && summary.emailsSent !== undefined) {
            successMessage += `\n📧 Email Results:\n`;
            successMessage += `• Emails sent: ${summary.emailsSent}\n`;
            if (summary.emailsFailed > 0) {
              successMessage += `• Emails failed: ${summary.emailsFailed}\n`;
            }
          }
          
          if (summary.skipped > 0) {
            successMessage += `\n💡 Duplicates are students with the same name and phone number`;
          }
          
          setBulkSuccess(successMessage);
          setBulkFile(null);
          
          // Clear file input
          const fileInput = document.getElementById('csvFile') as HTMLInputElement;
          if (fileInput) fileInput.value = '';
          
          // Refresh student list
          await fetchStudents();
          
          toast({
            title: "Upload Complete",
            description: `Added ${summary.inserted} students${summary.skipped > 0 ? `, skipped ${summary.skipped} duplicates` : ''}`,
          });
          
          // Switch to manage tab to see results
          if (summary.inserted > 0) {
            setTimeout(() => setActiveTab('manage'), 1500);
          }
          
        } else {
          // Handle server errors with detailed messages
          let errorMessage = '❌ Upload failed\n\n';
          
          if (response.status === 400) {
            errorMessage += `📋 Validation Error:\n${data.message || 'Invalid data format'}\n\n💡 Please check your file format and data`;
          } else if (response.status === 413) {
            errorMessage += `📦 File too large\n\n💡 Try uploading fewer students at once (max 1000 per batch)`;
          } else if (response.status === 500) {
            errorMessage += `🔧 Server Error:\n${data.message || 'Internal server error'}\n\n💡 Please try again or contact support`;
          } else {
            errorMessage += `🌐 Network Error (${response.status}):\n${data.message || 'Unknown error'}\n\n💡 Check your internet connection and try again`;
          }
          
          setBulkError(errorMessage);
        }
      } catch (err: any) {
        console.error('📤 Upload error:', err);
        
        let errorMessage = '❌ Upload failed\n\n';
        
        if (err.name === 'TypeError' && err.message.includes('fetch')) {
          errorMessage += `🌐 Network Error:\nCannot connect to server\n\n💡 Check your internet connection and try again`;
        } else if (err.name === 'SyntaxError') {
          errorMessage += `📋 Data Error:\nInvalid response from server\n\n💡 Try again or contact support`;
        } else {
          errorMessage += `🔧 Unexpected Error:\n${err.message || 'Unknown error occurred'}\n\n💡 Please try again`;
        }
        
        setBulkError(errorMessage);
      } finally {
        setLoading(false);
      }
    };
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
    if (availableClasses.some(c => c.name.toLowerCase() === newClassName.trim().toLowerCase())) {
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
    setEditClassName(classItem.name);
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

    const oldClassName = editingClass.name;
    const newClassName = editClassName.trim();

    // Check if new class name already exists
    if (availableClasses.some(c => c.name.toLowerCase() === newClassName.toLowerCase() && c.name !== oldClassName)) {
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

  // Use classes from API
  const classesData = availableClasses;

  // Smart Search Helper Functions
  const getSmartSearchPlaceholder = (input: string) => {
    if (!input) return "Type 09... for phone, numbers for ID, or text for name";
    
    const trimmed = input.trim();
    if (/^09/.test(trimmed) && trimmed.length < 10) {
      return "Continue typing phone number (09xxxxxxxx)";
    } else if (/^09\d{8}$/.test(trimmed)) {
      return "Phone number search active";
    } else if (/^\d+$/.test(trimmed)) {
      return "Student ID search active";
    } else {
      return "Name/class search active";
    }
  };

  const getSearchTypeHint = (input: string) => {
    if (!input) return "";
    
    const trimmed = input.trim();
    if (/^09\d{8}$/.test(trimmed)) {
      return "🔍 Searching by phone number (exact match)";
    } else if (/^\d+$/.test(trimmed)) {
      return "🔍 Searching by student ID (exact match)";
    } else {
      return "🔍 Searching by name or class (partial match)";
    }
  };

  // Smart Filter students based on search and class filter, then sort by ID
  const filteredStudents = students
    .filter(student => {
      // Smart Search Logic
      let matchesSearch = true;
      if (searchTerm.trim()) {
        const trimmedSearch = searchTerm.trim();
        
        if (/^09\d{8}$/.test(trimmedSearch)) {
          // Phone number search (09xxxxxxxx - exact match)
          matchesSearch = student.phone === trimmedSearch;
        } else if (/^\d+$/.test(trimmedSearch)) {
          // Student ID search (digits only, not starting with 09)
          matchesSearch = student.id.toString() === trimmedSearch;
        } else {
          // Name search (contains letters or mixed characters)
          matchesSearch = student.full_name.toLowerCase().includes(trimmedSearch.toLowerCase()) ||
                         student.class.toLowerCase().includes(trimmedSearch.toLowerCase());
        }
      }
      
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
                          {availableClasses.map((classItem) => (
                            <SelectItem key={classItem.name} value={classItem.name}>
                              {classItem.name}
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
                    availableClasses.length > 0 ? (
                      <Select
                        value={formData.class}
                        onValueChange={(value) => setFormData({ ...formData, class: value })}
                        required
                      >
                        <SelectTrigger id="class">
                          <SelectValue placeholder="Select a class" />
                        </SelectTrigger>
                        <SelectContent>
                          {availableClasses.map((classItem) => (
                            <SelectItem key={classItem.name} value={classItem.name}>
                              {classItem.name} ({classItem.student_count} students)
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
                    disabled={loading || (!editingStudent && !currentUser?.can_add_student) || (editingStudent && !currentUser?.can_update_student && !currentUser?.can_add_student) || false}
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
                        ✏️ Editing: {editingClass.name}
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
                      <div key={classItem.name} className="flex items-center justify-between p-4 border rounded-lg bg-muted/30">
                        <div>
                          <h4 className="font-medium">{classItem.name}</h4>
                          <p className="text-sm text-muted-foreground">
                            {classItem.student_count} student{classItem.student_count !== 1 ? 's' : ''}
                          </p>
                        </div>
                        <div className="flex gap-2">
                          <Button
                            variant="outline"
                            size="sm"
                            onClick={() => {
                              setSelectedClass(classItem.name);
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
                            onClick={() => handleDeleteClass(classItem.name)}
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
                Upload multiple students at once using a CSV/Excel file with automatic email notifications and QR code generation
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
                    <h3 className="font-medium">📊 Download Excel Template</h3>
                    <p className="text-sm text-muted-foreground">
                      Get a sample Excel file with the correct format and sample data
                    </p>
                    <p className="text-xs text-muted-foreground mt-1">
                      ✅ Includes: full_name, phone, gender, class, email columns with sample data
                    </p>
                  </div>
                  <Button onClick={downloadTemplate} variant="outline">
                    <Download className="w-4 h-4 mr-2" />
                    Download Excel Template
                  </Button>
                </div>

                <form onSubmit={handleBulkUpload} className="space-y-4">
                  <div className="space-y-2">
                    <Label htmlFor="csvFile">Upload Excel or CSV File *</Label>
                    <Input
                      id="csvFile"
                      type="file"
                      accept=".xlsx,.xls,.csv"
                      onChange={(e) => {
                        setBulkFile(e.target.files?.[0] || null);
                        setBulkError('');
                        setBulkSuccess('');
                      }}
                      required
                    />
                    {bulkFile && (
                      <div className="p-3 bg-muted/50 rounded-lg">
                        <p className="text-sm font-medium">Selected file:</p>
                        <p className="text-sm text-muted-foreground">
                          📄 {bulkFile.name} ({(bulkFile.size / 1024).toFixed(1)} KB)
                        </p>
                        <p className="text-xs text-muted-foreground mt-1">
                          {bulkFile.name.toLowerCase().endsWith('.xlsx') || bulkFile.name.toLowerCase().endsWith('.xls') 
                            ? '📊 Excel format - supports Amharic text' 
                            : '📄 CSV format - ensure UTF-8 encoding for Amharic text'}
                        </p>
                      </div>
                    )}
                    <p className="text-xs text-muted-foreground">
                      💡 Supported formats: .xlsx (Excel), .xls (Excel), .csv (UTF-8)
                    </p>
                  </div>

                  <div className="space-y-2">
                    <div className="flex items-center space-x-2">
                      <input
                        type="checkbox"
                        id="sendEmails"
                        checked={sendEmails}
                        onChange={(e) => setSendEmails(e.target.checked)}
                        className="rounded border-gray-300"
                      />
                      <Label htmlFor="sendEmails" className="text-sm font-medium">
                        📧 Send registration emails with QR codes
                      </Label>
                    </div>
                    <p className="text-xs text-muted-foreground">
                      {sendEmails 
                        ? "✅ Each student will receive an email with their QR code and registration details" 
                        : "⚠️ Students will be added without email notifications (email column still required)"}
                    </p>
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
                  Download CSV File
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
                      placeholder={getSmartSearchPlaceholder(searchTerm)}
                      value={searchTerm}
                      onChange={(e) => setSearchTerm(e.target.value)}
                      className="pl-10"
                    />
                    {searchTerm && (
                      <p className="text-xs text-muted-foreground mt-1">
                        {getSearchTypeHint(searchTerm)}
                      </p>
                    )}
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
                      {availableClasses.map((classItem) => (
                        <SelectItem key={classItem.name} value={classItem.name}>
                          {classItem.name} ({classItem.student_count})
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
                                onClick={() => {
                                  console.log('Edit button clicked for student:', student);
                                  console.log('Current user permissions:', currentUser);
                                  startEdit(student);
                                }}
                                disabled={loading || (!currentUser?.can_update_student && !currentUser?.can_add_student)}
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
