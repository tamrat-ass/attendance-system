# Frontend Architecture

## Component Hierarchy

\`\`\`
App (app/page.tsx)
├── LoginPage (for authentication)
│   ├── Email Recovery Form
│   ├── Verification Code Form
│   ├── Password Reset Form
│   └── Success Screen
└── Dashboard (main application)
    ├── Header
    │   ├── Logo & Title
    │   ├── Current Date
    │   └── Logout Button
    ├── Tabs Navigation
    │   ├── Mark Attendance Tab
    │   │   ├── DatePicker
    │   │   ├── ClassSelector
    │   │   ├── StudentSearch
    │   │   ├── StudentTable
    │   │   │   ├── StudentID
    │   │   │   ├── Name
    │   │   │   ├── StatusDropdown
    │   │   │   └── NotesInput
    │   │   └── ActionButtons (Save, Export, Mark All Absent)
    │   ├── Students Tab
    │   │   ├── Add Single Student
    │   │   │   ├── FirstNameInput
    │   │   │   ├── MiddleNameInput
    │   │   │   ├── LastNameInput
    │   │   │   ├── PhoneInput
    │   │   │   └── ClassSelector
    │   │   ├── Bulk Upload
    │   │   │   ├── DownloadTemplateButton
    │   │   │   ├── FileUploader
    │   │   │   └── FormatGuide
    │   │   └── Manage Students
    │   │       ├── SearchInput
    │   │       ├── ClassFilter
    │   │       └── StudentTable
    │   │           ├── StudentID
    │   │           ├── Name
    │   │           ├── Phone
    │   │           ├── Class
    │   │           └── DeleteButton
    │   └── Reports Tab
    │       ├── DateRangeFilter
    │       ├── ExportButton
    │       ├── Summary Cards (5 metrics)
    │       ├── LineChart (Date Trends)
    │       ├── PieChart (Status Distribution)
    │       ├── ClassStatistics
    │       └── StudentSummary
    └── UI Components (shadcn/ui)
        ├── Button
        ├── Input
        ├── Card
        ├── Tabs
        ├── Select
        ├── Table
        ├── Badge
        └── Alert
\`\`\`

## State Management Pattern

### Dashboard State (Parent)
\`\`\`typescript
const [students, setStudents] = useState<Student[]>([]);
const [classes, setClasses] = useState<string[]>([]);
const [attendance, setAttendance] = useState<AttendanceRecord[]>([]);
\`\`\`

### Props Flow
\`\`\`
Dashboard (Parent State)
    ↓
Pass to → StudentManagement
Pass to → AttendanceMarking
Pass to → Reports
    ↓
Each component updates parent state via callbacks
\`\`\`

## Component Responsibilities

### LoginPage
- Handles authentication UI
- Manages 4-step recovery flow
- Calls API endpoints for recovery

### Header
- Displays current date
- Shows application title
- Logout button

### StudentManagement
- Add students individually
- Bulk upload via CSV
- Search and filter students
- Display student list
- Download CSV template

### AttendanceMarking
- Select date and class
- Mark attendance status
- Add notes per student
- Save records
- Export to CSV

### Reports
- Filter by date range
- Display 5 summary metrics
- Line chart for trends
- Pie chart for distribution
- Class-wise statistics
- Student individual rates

## Styling Approach

### Color Scheme
\`\`\`typescript
// Primary Actions
primary: '#3b82f6'     // Blue

// Status Colors
green-600: '#16a34a'   // Present
red-600: '#dc2626'     // Absent
yellow-600: '#ca8a04'  // Late
blue-600: '#2563eb'    // Permission

// Backgrounds
background: '#ffffff'
card: '#ffffff'
muted: '#f3f4f6'
\`\`\`

### Tailwind Classes
- Flexbox: `flex items-center justify-between`
- Grid: `grid grid-cols-1 md:grid-cols-2`
- Spacing: `p-4 m-2 gap-4`
- Typography: `text-xl font-bold`
- Borders: `border border-2 rounded-lg`

## Performance Considerations

1. **Memoization**
   - Reports component uses `useMemo` for calculations
   - Prevents unnecessary re-renders

2. **Search/Filter**
   - Done on client-side
   - Fast for typical dataset sizes

3. **CSV Export**
   - Converts to Blob
   - Downloads client-side (no server processing)

## Accessibility

- Semantic HTML: `<header>`, `<main>`, `<label for="id">`
- ARIA roles on custom components
- Keyboard navigation support
- Color + text for status indication

## File Organization

\`\`\`
components/
├── auth/
│   └── login-page.tsx          (500 lines)
├── dashboard/
│   ├── dashboard.tsx            (50 lines)
│   ├── header.tsx               (30 lines)
│   ├── student-management.tsx   (350 lines)
│   ├── attendance-marking.tsx   (250 lines)
│   └── reports.tsx              (350 lines)
└── ui/
    └── [shadcn components]
\`\`\`

## Import Structure

\`\`\`typescript
// Core React & Next.js
import { useState, useMemo } from 'react';
import type { ReactNode } from 'react';

// UI Components
import { Button } from '@/components/ui/button';
import { Card, CardContent, CardHeader } from '@/components/ui/card';

// Icons
import { Download, Search, Trash2 } from 'lucide-react';

// Utilities
import { cn } from '@/lib/utils';

// Types
import type { Student, AttendanceRecord } from '@/lib/types';
\`\`\`

## API Integration Points

### From Frontend Components
\`\`\`typescript
// LoginPage
fetch('/api/auth/send-recovery-email', { method: 'POST', body: JSON.stringify({ email }) })
fetch('/api/auth/verify-code', { method: 'POST', body: JSON.stringify({ email, code }) })
fetch('/api/auth/reset-password', { method: 'POST', body: JSON.stringify({ email, newPassword }) })

// AttendanceMarking
fetch('/api/attendance/export', { method: 'POST', body: JSON.stringify({ records }) })

// Reports
fetch('/api/reports/generate', { method: 'POST', body: JSON.stringify({ startDate, endDate }) })
\`\`\`

## Error Handling Pattern

\`\`\`typescript
try {
  const response = await fetch('/api/endpoint', { ... });
  
  if (!response.ok) {
    const data = await response.json();
    setError(data.error || 'An error occurred');
    return;
  }
  
  const result = await response.json();
  // Process success
} catch (error) {
  console.error('[v0] Error:', error);
  setError('Network error. Please try again.');
}
\`\`\`

## Loading States

\`\`\`typescript
// Button state during API call
<Button disabled={loading}>
  {loading ? 'Sending...' : 'Send Code'}
</Button>

// Input disabled during processing
<Input disabled={loading} />

// Loading indicators
{loading && <Spinner />}
