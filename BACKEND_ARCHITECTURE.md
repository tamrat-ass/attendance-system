# Backend Architecture

## API Route Structure

\`\`\`
app/
├── api/
│   └── auth/
│       ├── send-recovery-email/
│       │   └── route.ts              (POST)
│       ├── verify-code/
│       │   └── route.ts              (POST)
│       └── reset-password/
│           └── route.ts              (POST)
└── (other future routes)
\`\`\`

## API Endpoints Reference

### 1. POST /api/auth/send-recovery-email

**Purpose:** Generate and send recovery code to user email

**Request Body:**
\`\`\`json
{
  "email": "user@example.com"
}
\`\`\`

**Success Response (200):**
\`\`\`json
{
  "success": true,
  "message": "Recovery code sent to your email"
}
\`\`\`

**Error Responses:**
\`\`\`json
// 400: Invalid email format
{
  "error": "Invalid email format"
}

// 400: Email required
{
  "error": "Email is required"
}

// 500: Email configuration error
{
  "error": "Failed to send recovery email. Please check your email configuration."
}
\`\`\`

**Backend Process:**
1. Validate email format with regex
2. Generate 6-digit random code
3. Store code with 10-minute expiration
4. Send HTML email via Nodemailer
5. Log operation

**Code:**
\`\`\`typescript
export async function POST(request: NextRequest) {
  const { email } = await request.json();
  
  // Validation
  const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
  if (!emailRegex.test(email)) {
    return NextResponse.json({ error: 'Invalid email format' }, { status: 400 });
  }
  
  // Generate code
  const code = generateRecoveryCode(email);
  
  // Send email
  await sendRecoveryEmail(email, code);
  
  return NextResponse.json(
    { success: true, message: 'Recovery code sent to your email' },
    { status: 200 }
  );
}
\`\`\`

---

### 2. POST /api/auth/verify-code

**Purpose:** Verify the recovery code sent to email

**Request Body:**
\`\`\`json
{
  "email": "user@example.com",
  "code": "123456"
}
\`\`\`

**Success Response (200):**
\`\`\`json
{
  "success": true,
  "message": "Code verified successfully"
}
\`\`\`

**Error Responses:**
\`\`\`json
// 400: Invalid or expired code
{
  "error": "Invalid or expired verification code"
}

// 400: Email mismatch
{
  "error": "Email does not match the recovery request"
}

// 400: Missing fields
{
  "error": "Email and code are required"
}
\`\`\`

**Backend Process:**
1. Validate email and code provided
2. Retrieve code from memory storage
3. Check if code has expired (>10 minutes)
4. Verify email matches stored email
5. Remove code from storage (one-time use)
6. Return success

**Code:**
\`\`\`typescript
export async function POST(request: NextRequest) {
  const { email, code } = await request.json();
  
  // Validation
  if (!email || !code) {
    return NextResponse.json(
      { error: 'Email and code are required' },
      { status: 400 }
    );
  }
  
  // Verify code
  if (!verifyRecoveryCode(code, email)) {
    return NextResponse.json(
      { error: 'Invalid or expired verification code' },
      { status: 400 }
    );
  }
  
  return NextResponse.json(
    { success: true, message: 'Code verified successfully' },
    { status: 200 }
  );
}
\`\`\`

---

### 3. POST /api/auth/reset-password

**Purpose:** Reset user password after code verification

**Request Body:**
\`\`\`json
{
  "email": "user@example.com",
  "newPassword": "newPassword123"
}
\`\`\`

**Success Response (200):**
\`\`\`json
{
  "success": true,
  "message": "Password reset successfully"
}
\`\`\`

**Error Responses:**
\`\`\`json
// 400: Password too short
{
  "error": "Password must be at least 6 characters"
}

// 400: Invalid email
{
  "error": "Invalid email address"
}

// 500: Database error
{
  "error": "Failed to reset password"
}
\`\`\`

**Backend Process:**
1. Validate email format
2. Validate password length (min 6 chars)
3. Hash password (in production)
4. Update user credentials
5. Return success message

**Code:**
\`\`\`typescript
export async function POST(request: NextRequest) {
  const { email, newPassword } = await request.json();
  
  // Validation
  if (!email || !newPassword) {
    return NextResponse.json(
      { error: 'Email and password are required' },
      { status: 400 }
    );
  }
  
  if (newPassword.length < 6) {
    return NextResponse.json(
      { error: 'Password must be at least 6 characters' },
      { status: 400 }
    );
  }
  
  // In production: Hash password and update database
  // For demo: Simulate update
  
  return NextResponse.json(
    { success: true, message: 'Password reset successfully' },
    { status: 200 }
  );
}
\`\`\`

---

## Email Service

### File: `lib/email-service.tsx`

**Dependencies:**
\`\`\`typescript
import nodemailer from 'nodemailer';
\`\`\`

**Transporter Setup:**
\`\`\`typescript
const transporter = nodemailer.createTransport({
  service: 'gmail',
  auth: {
    user: process.env.EMAIL_USER,
    pass: process.env.EMAIL_PASSWORD,
  },
});
\`\`\`

**Functions:**

#### 1. sendRecoveryEmail()
\`\`\`typescript
export async function sendRecoveryEmail(email: string, code: string) {
  const mailOptions = {
    from: process.env.EMAIL_USER,
    to: email,
    subject: 'Attendance System - Password Recovery Code',
    html: `<div>...</div>` // HTML template
  };
  
  return await transporter.sendMail(mailOptions);
}
\`\`\`

**Email Template Structure:**
- Header: Blue gradient with logo
- Body: Recovery code in prominent box
- Footer: Copyright info
- Expiration notice: 10 minutes

#### 2. generateRecoveryCode()
\`\`\`typescript
export function generateRecoveryCode(email: string): string {
  const code = Math.random().toString().slice(2, 8);
  const expiresAt = Date.now() + 10 * 60 * 1000;
  
  recoveryCodes.set(code, { code, expires: expiresAt, email });
  
  return code;
}
\`\`\`

**Storage:** In-memory Map
\`\`\`typescript
const recoveryCodes: Map<string, {
  code: string;
  expires: number;
  email: string;
}> = new Map();
\`\`\`

#### 3. verifyRecoveryCode()
\`\`\`typescript
export function verifyRecoveryCode(code: string, email: string): boolean {
  const stored = recoveryCodes.get(code);
  
  if (!stored) return false;
  if (Date.now() > stored.expires) {
    recoveryCodes.delete(code);
    return false;
  }
  if (stored.email !== email) return false;
  
  recoveryCodes.delete(code);
  return true;
}
\`\`\`

---

## Environment Variables

**Required Variables:**
\`\`\`
EMAIL_USER=tamaratasu23@gmail.com
EMAIL_PASSWORD=app_password_from_gmail
\`\`\`

**How to Get Gmail App Password:**
1. Enable 2-Factor Authentication
2. Go to https://myaccount.google.com/apppasswords
3. Select "Mail" and "Windows Computer"
4. Generate 16-character password
5. Copy and use as EMAIL_PASSWORD

---

## Error Handling Pattern

\`\`\`typescript
try {
  // Operation
  await operation();
} catch (error) {
  console.error('[v0] Error occurred:', error);
  return NextResponse.json(
    { error: 'Operation failed' },
    { status: 500 }
  );
}
\`\`\`

---

## Logging Convention

All logs use `[v0]` prefix for debugging:
\`\`\`typescript
console.log('[v0] Operation started for:', email);
console.error('[v0] Error occurred:', error);
\`\`\`

---

## Security Considerations

### Current Implementation (Demo)
- In-memory code storage (lost on server restart)
- No password hashing (demo purposes)
- Basic validation

### Production Improvements
1. **Database Integration**
   - Store recovery codes with timestamps
   - Hash passwords with bcrypt
   - Add rate limiting

2. **Authentication**
   - Implement JWT tokens
   - Session management
   - CSRF protection

3. **Email Security**
   - Use environment variables (✓ already done)
   - Validate sender domain (SPF, DKIM)
   - Rate limit email sending

4. **Input Validation**
   - Sanitize all inputs
   - Prevent injection attacks
   - Validate data types

---

## Database Schema (Future)

### Users Table
\`\`\`sql
CREATE TABLE users (
  id UUID PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  role VARCHAR(50) DEFAULT 'user',
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
\`\`\`

### Recovery Codes Table
\`\`\`sql
CREATE TABLE recovery_codes (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users(id),
  code VARCHAR(6) NOT NULL,
  expires_at TIMESTAMP NOT NULL,
  used_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
\`\`\`

---

## Monitoring & Debugging

### Check Logs
\`\`\`bash
# In Vercel deployment
vercel logs <project-name>
\`\`\`

### Debug Email Issues
\`\`\`typescript
console.log('[v0] Transporter config:', {
  service: 'gmail',
  user: process.env.EMAIL_USER
});
console.log('[v0] Sending email to:', email);
console.log('[v0] Email result:', result.response);
\`\`\`

### Test Recovery Flow
1. Call send-recovery-email with test email
2. Check email received
3. Verify code format
4. Call verify-code with received code
5. Confirm success response
