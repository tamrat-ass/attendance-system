# Attendance Management System - Technical Documentation

## 📋 Table of Contents
1. [System Overview](#system-overview)
2. [Architecture](#architecture)
3. [Frontend Components](#frontend-components)
4. [Backend API Routes](#backend-api-routes)
5. [Data Structures](#data-structures)
6. [Email Service Configuration](#email-service-configuration)
7. [Installation & Setup](#installation--setup)
8. [Deployment Guide](#deployment-guide)

---

## System Overview

**Project Name:** Attendance Management System  
**Type:** Admin-controlled web application  
**Tech Stack:** Next.js 16, React 19, TypeScript, Tailwind CSS, Recharts, Nodemailer  
**Database:** In-memory (Client-side state management via React hooks)  
**Email Provider:** Gmail SMTP

### Key Features
- Admin login with password recovery
- Student management (single & bulk upload)
- Daily attendance marking with notes
- Advanced reporting with charts
- CSV/Excel export functionality
- Email-based password recovery

---

## Architecture

\`\`\`
attendance-system/
├── app/
│   ├── page.tsx                 # Main entry point
│   ├── layout.tsx               # Root layout
│   ├── globals.css              # Global styles
│   └── api/
│       └── auth/
│           ├── send-recovery-email/route.ts
│           ├── verify-code/route.ts
│           └── reset-password/route.ts
├── components/
│   ├── auth/
│   │   └── login-page.tsx       # Login & password recovery
│   ├── dashboard/
│   │   ├── dashboard.tsx        # Main dashboard container
│   │   ├── header.tsx           # Header with logout
│   │   ├── student-management.tsx
│   │   ├── attendance-marking.tsx
│   │   └── reports.tsx
│   └── ui/                      # shadcn/ui components
├── lib/
│   ├── email-service.tsx        # Email utilities
│   └── utils.ts                 # Helper functions
└── public/                      # Static assets
\`\`\`

### Data Flow

\`\`\`
User Login (credentials)
    ↓
LoginPage validates credentials
    ↓
Dashboard renders with 3 main tabs:
    ├── Mark Attendance (AttendanceMarking component)
    ├── Students (StudentManagement component)
    └── Reports (Reports component)
    ↓
All data stored in React state (parent: Dashboard)
\`\`\`

---

## Frontend Components

### 1. LoginPage Component
**File:** `components/auth/login-page.tsx`

**Responsibilities:**
- User authentication
- Password recovery flow (4 steps)
- Email verification via API

**Props:**
\`\`\`typescript
interface LoginPageProps {
  onLogin: () => void;  // Called when login succeeds
}
\`\`\`

**States:**
- `username` - Login username
- `password` - Login password
- `showForgotPassword` - Toggle recovery flow
- `recoveryStep` - 'email' | 'verify' | 'reset' | 'success'
- `recoveryEmail` - Email for recovery
- `verificationCode` - 6-digit code from email
- `newPassword` - New password input
- `confirmPassword` - Password confirmation

**Key Methods:**
- `handleSubmit()` - Validates login credentials (demo: admin/password123)
- `handleRecoveryEmail()` - Calls `/api/auth/send-recovery-email`
- `handleVerifyCode()` - Calls `/api/auth/verify-code`
- `handleResetPassword()` - Calls `/api/auth/reset-password`

---

### 2. Dashboard Component
**File:** `components/dashboard/dashboard.tsx`

**Responsibilities:**
- Main container for all dashboard features
- State management for students, classes, attendance
- Tab navigation

**Props:**
\`\`\`typescript
interface DashboardProps {
  onLogout: () => void;
}
\`\`\`

**State:**
\`\`\`typescript
const [students, setStudents] = useState<any[]>([]);
const [classes, setClasses] = useState<string[]>(['Class A', 'Class B', 'Class C']);
const [attendance, setAttendance] = useState<any[]>([]);
const [activeTab, setActiveTab] = useState('attendance');
\`\`\`

**Child Components:**
- `Header` - Top navigation
- `AttendanceMarking` - Mark attendance interface
- `StudentManagement` - Manage students
- `Reports` - View analytics

---

### 3. StudentManagement Component
**File:** `components/dashboard/student-management.tsx`

**Responsibilities:**
- Add individual students
- Bulk upload via CSV
- Search & filter students
- Manage classes

**Key Features:**

#### Single Student Addition
\`\`\`typescript
const handleAddStudent = (e: React.FormEvent) => {
  // Validates form, checks for duplicates
  // Generates unique student ID
  // Adds to state
}
\`\`\`

#### Bulk CSV Upload
\`\`\`typescript
const handleBulkUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
  // Parses CSV file
  // Validates all rows
  // Checks for duplicate phone numbers
  // Returns error summary
}
\`\`\`

#### CSV Template Download
\`\`\`typescript
const handleDownloadTemplate = () => {
  // Creates sample CSV with format:
  // first_name,middle_name,last_name,phone,class_name
}
\`\`\`

**Data Structure:**
\`\`\`typescript
interface Student {
  id: string;           // Generated: STU-{timestamp}
  firstName: string;    // Required
  middleName: string;   // Optional
  lastName: string;     // Required
  phone: string;        // Required, unique
  class: string;        // Required
}
\`\`\`

---

### 4. AttendanceMarking Component
**File:** `components/dashboard/attendance-marking.tsx`

**Responsibilities:**
- Select date and class
- Mark attendance for all students
- Add notes per student
- Export to CSV

**Key Methods:**
\`\`\`typescript
handleStatusChange(studentId, status)    // Updates attendance status
handleNotesChange(studentId, note)       // Updates student notes
handleSaveAttendance()                   // Saves all records
handleMarkAllAbsent()                    // Bulk mark absent
handleExportToExcel()                    // Exports to CSV
\`\`\`

**Data Structure:**
\`\`\`typescript
interface AttendanceRecord {
  studentId: string;
  status: 'present' | 'absent' | 'late' | 'permission';
  date: string;        // YYYY-MM-DD format
  notes?: string;      // Optional notes
}
\`\`\`

**Status Badges:**
- Present: Green (#22c55e)
- Absent: Red (#ef4444)
- Late: Yellow (#eab308)
- Permission: Blue (#3b82f6)

---

### 5. Reports Component
**File:** `components/dashboard/reports.tsx`

**Responsibilities:**
- Visualize attendance data
- Display statistics
- Generate reports
- Export filtered data

**Key Visualizations:**

1. **Summary Cards** (5 metrics)
   - Total Records
   - Present Count
   - Absent Count
   - Late Count
   - Permission Count

2. **Line Chart** - Attendance by Date
   - X-axis: Dates
   - Y-axis: Count
   - Lines: Present & Absent trends

3. **Pie Chart** - Overall Distribution
   - Shows ratio of all statuses

4. **Class Statistics** - Breakdown by class
   - Total records, present, absent, rate

5. **Student Summary** - Individual rates
   - Attendance percentage
   - Progress bar visualization

**Calculation Logic:**
\`\`\`typescript
const attendanceRate = (presentDays / totalDays) * 100
\`\`\`

---

## Backend API Routes

### 1. Send Recovery Email
**Endpoint:** `POST /api/auth/send-recovery-email`

**Request:**
\`\`\`json
{
  "email": "user@example.com"
}
\`\`\`

**Response (Success 200):**
\`\`\`json
{
  "success": true,
  "message": "Recovery code sent to your email"
}
\`\`\`

**Response (Error 400/500):**
\`\`\`json
{
  "error": "Error message describing the issue"
}
\`\`\`

**Process:**
1. Validate email format
2. Generate 6-digit code (10-min expiration)
3. Send HTML email via Nodemailer
4. Store code in memory map

---

### 2. Verify Recovery Code
**Endpoint:** `POST /api/auth/verify-code`

**Request:**
\`\`\`json
{
  "email": "user@example.com",
  "code": "123456"
}
\`\`\`

**Response (Success 200):**
\`\`\`json
{
  "success": true,
  "message": "Code verified successfully"
}
\`\`\`

**Response (Error 400):**
\`\`\`json
{
  "error": "Invalid or expired code"
}
\`\`\`

**Process:**
1. Check if code exists
2. Verify expiration (10 minutes)
3. Match email to stored code
4. Remove code from storage

---

### 3. Reset Password
**Endpoint:** `POST /api/auth/reset-password`

**Request:**
\`\`\`json
{
  "email": "user@example.com",
  "newPassword": "newPass123"
}
\`\`\`

**Response (Success 200):**
\`\`\`json
{
  "success": true,
  "message": "Password reset successfully"
}
\`\`\`

**Response (Error 400/500):**
\`\`\`json
{
  "error": "Error message"
}
\`\`\`

**Process:**
1. Validate password length (min 6 chars)
2. Update user credentials (simulated)
3. Return success message

---

## Email Service Configuration

**File:** `lib/email-service.tsx`

### Setup Requirements

1. **Environment Variables:**
   \`\`\`
   EMAIL_USER=tamaratasu23@gmail.com
   EMAIL_PASSWORD=your_app_password
   \`\`\`

2. **Gmail App Password Setup:**
   - Enable 2-Factor Authentication on Gmail
   - Generate App Password at: https://myaccount.google.com/apppasswords
   - Use the 16-character password as `EMAIL_PASSWORD`

### Email Template

The system sends HTML emails with:
- Branding header (blue gradient)
- Verification code prominently displayed
- 10-minute expiration notice
- Professional footer

### Nodemailer Transporter Configuration

\`\`\`typescript
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASSWORD,
  },
});
\`\`\`

### Recovery Code Management

\`\`\`typescript
// Storage: In-memory Map
const recoveryCodes: Map<string, {
  code: string;
  expires: number;      // Timestamp (10 min from creation)
  email: string;
}> = new Map();

// Functions:
generateRecoveryCode(email: string) → code: string
verifyRecoveryCode(code: string, email: string) → boolean
sendRecoveryEmail(email: string, code: string) → Promise
\`\`\`

---

## Data Structures

### Student
\`\`\`typescript
{
  id: string;           // "STU-123456"
  firstName: string;    // "John"
  middleName: string;   // "M" (optional)
  lastName: string;     // "Doe"
  phone: string;        // "9876543210" (unique)
  class: string;        // "Class A"
}
\`\`\`

### Attendance Record
\`\`\`typescript
{
  studentId: string;    // "STU-123456"
  status: 'present' | 'absent' | 'late' | 'permission';
  date: string;         // "2025-01-15"
  notes?: string;       // Optional notes
}
\`\`\`

### Dashboard State
\`\`\`typescript
{
  students: Student[];
  classes: string[];
  attendance: AttendanceRecord[];
  activeTab: 'attendance' | 'students' | 'reports';
}
\`\`\`

---

## Installation & Setup

### Prerequisites
- Node.js 18+
- npm or pnpm
- Gmail account with App Password

### Local Installation

1. **Clone/Download the project**
   \`\`\`bash
   cd attendance-system
   \`\`\`

2. **Install dependencies**
   \`\`\`bash
   npm install
   # or
   pnpm install
   \`\`\`

3. **Set environment variables**
   Create `.env.local`:
   \`\`\`
   EMAIL_USER=tamaratasu23@gmail.com
   EMAIL_PASSWORD=your_app_password
   NEXT_PUBLIC_DEV_SUPABASE_REDIRECT_URL=http://localhost:3000
   \`\`\`

4. **Run development server**
   \`\`\`bash
   npm run dev
   # or
   pnpm dev
   \`\`\`

5. **Access the application**
   Open http://localhost:3000 in your browser

### Demo Credentials
- **Username:** admin
- **Password:** password123

---

## Deployment Guide

### Vercel Deployment

1. **Push to GitHub**
   \`\`\`bash
   git push origin main
   \`\`\`

2. **Connect to Vercel**
   - Go to vercel.com
   - Click "New Project"
   - Select your repository
   - Click "Import"

3. **Set Environment Variables**
   - Go to Settings → Environment Variables
   - Add:
     \`\`\`
     EMAIL_USER=tamaratasu23@gmail.com
     EMAIL_PASSWORD=your_app_password
     \`\`\`

4. **Deploy**
   - Click "Deploy"
   - Wait for build to complete
   - Access your live URL

### Environment Variables (Production)
\`\`\`
EMAIL_USER=" "
EMAIL_PASSWORD=your_app_password
NEXT_PUBLIC_DEV_SUPABASE_REDIRECT_URL=https://your-domain.com
\`\`\`

---

## File-by-File Implementation Guide

### Core Files to Update Individually

#### 1. **app/page.tsx** - Entry Point
- Manages auth state
- Renders LoginPage or Dashboard

#### 2. **components/auth/login-page.tsx** - Authentication
- 4-step password recovery
- Calls backend APIs

#### 3. **lib/email-service.tsx** - Email Utilities
- Generates recovery codes
- Sends HTML emails
- Validates codes

#### 4. **app/api/auth/** - API Routes
- `send-recovery-email/route.ts` - Email sending
- `verify-code/route.ts` - Code validation
- `reset-password/route.ts` - Password reset

#### 5. **components/dashboard/** - Dashboard Features
- `dashboard.tsx` - Main container & state
- `header.tsx` - Top navigation
- `student-management.tsx` - CRUD operations
- `attendance-marking.tsx` - Daily marking
- `reports.tsx` - Analytics & exports

---

## Troubleshooting

### Email Not Sending
**Solution:**
1. Verify environment variables are set
2. Check Gmail App Password (not regular password)
3. Enable 2FA on Gmail account
4. Check error logs in console

### Students Not Appearing in Attendance
**Solution:**
1. Ensure students are added to a class
2. Select correct class in attendance tab
3. Verify student data was saved

### Reports Not Showing Data
**Solution:**
1. Mark attendance first
2. Check date range in filter
3. Ensure attendance records exist for selected dates

---

## Future Enhancements

1. **Database Integration**
   - Replace in-memory state with PostgreSQL/MongoDB
   - Add persistence layer

2. **Multi-User Support**
   - Teacher & admin roles
   - Individual teacher dashboards

3. **Mobile App**
   - React Native version
   - Offline attendance marking

4. **Advanced Features**
   - Biometric attendance
   - QR code scanning
   - SMS notifications
   - Parent notifications

5. **Analytics**
   - ML-based attendance predictions
   - Patterns detection
   - Comprehensive dashboards

---

## Support & Maintenance

For issues or questions:
1. Check the troubleshooting section
2. Review console logs for errors
3. Verify environment variables
4. Contact your administrator

---

**Last Updated:** November 2025  
**System Version:** 1.0.0
