# Class Management Mobile Integration

## Overview
This document outlines the integration of existing Class Management functionality from the website into the mobile application, reusing existing APIs without any backend modifications.

## API Endpoints Used

### Base URL
```
https://mk-attendance.vercel.app/api
```

### 1. Get All Classes
**Endpoint:** `GET /classes`
**Purpose:** Retrieve all classes with full details
**Authentication:** Bearer token required

**Request:**
```http
GET /api/classes
Authorization: Bearer <token>
Content-Type: application/json
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "id": 1,
      "class_name": "ዋናው መአከል",
      "description": "Main center class",
      "created_at": "2024-01-15T10:30:00.000Z"
    },
    {
      "id": 2,
      "class_name": "አዲስ አበባ ማእከል",
      "description": null,
      "created_at": "2024-01-16T14:20:00.000Z"
    }
  ]
}
```

### 2. Create New Class
**Endpoint:** `POST /classes`
**Purpose:** Create a new class
**Authentication:** Bearer token required

**Request:**
```http
POST /api/classes
Authorization: Bearer <token>
Content-Type: application/json

{
  "class_name": "ምስራቅ ማስተባበሪያ",
  "description": "Eastern coordination center"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Class created successfully",
  "data": {
    "id": 3,
    "class_name": "ምስራቅ ማስተባበሪያ",
    "description": "Eastern coordination center"
  }
}
```

### 3. Update Existing Class
**Endpoint:** `PUT /classes/{id}`
**Purpose:** Update an existing class
**Authentication:** Bearer token required

**Request:**
```http
PUT /api/classes/3
Authorization: Bearer <token>
Content-Type: application/json

{
  "class_name": "ምስራቅ ማስተባበሪያ - ዘመናዊ",
  "description": "Modern Eastern coordination center"
}
```

**Response:**
```json
{
  "success": true,
  "message": "Class updated successfully",
  "data": {
    "id": 3,
    "class_name": "ምስራቅ ማስተባበሪያ - ዘመናዊ",
    "description": "Modern Eastern coordination center"
  }
}
```

### 4. Delete Class
**Endpoint:** `DELETE /classes/{id}`
**Purpose:** Delete a class (only if no students are enrolled)
**Authentication:** Bearer token required

**Request:**
```http
DELETE /api/classes/3
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "message": "Class deleted successfully"
}
```

**Error Response (if students exist):**
```json
{
  "success": false,
  "message": "Cannot delete class. 5 students are enrolled in this class."
}
```

## Mobile Implementation

### 1. API Service Layer
**File:** `lib/services/api_service.dart`

The following methods were added to the existing ApiService class:

```dart
// Get all classes with full details
Future<List<Map<String, dynamic>>> getClassesWithDetails()

// Create new class
Future<Map<String, dynamic>> createClass({
  required String className,
  String? description,
})

// Update existing class
Future<Map<String, dynamic>> updateClass({
  required int classId,
  required String className,
  String? description,
})

// Delete class
Future<Map<String, dynamic>> deleteClass(int classId)
```

### 2. Data Model
**File:** `lib/models/class_model.dart`

```dart
class ClassModel {
  final int? id;
  final String className;
  final String? description;
  final DateTime? createdAt;
  
  // Factory constructor from JSON
  factory ClassModel.fromJson(Map<String, dynamic> json)
  
  // Convert to JSON
  Map<String, dynamic> toJson()
}
```

### 3. State Management
**File:** `lib/providers/class_provider.dart`

```dart
class ClassProvider with ChangeNotifier {
  List<ClassModel> _classes = [];
  bool _isLoading = false;
  String? _errorMessage;
  
  // Load all classes
  Future<void> loadClasses()
  
  // Create new class
  Future<bool> createClass({required String className, String? description})
  
  // Update existing class
  Future<bool> updateClass({required int classId, required String className, String? description})
  
  // Delete class
  Future<bool> deleteClass(int classId)
}
```

### 4. User Interface
**File:** `lib/screens/class_management_screen.dart`

Features:
- List all classes with search functionality
- Create new class with name and optional description
- Edit existing class details
- Delete class (with validation for enrolled students)
- Permission-based access (only admins can manage classes)
- Pull-to-refresh functionality
- Loading states and error handling

## UI Flow Description

### 1. Class List Screen (Default)
- **Display:** Grid/List view of all classes
- **Search:** Real-time search by class name or description
- **Actions:** Pull-to-refresh, Add new class (if permitted)
- **Navigation:** Tap class to view details, long press for context menu

### 2. Create Class Flow
1. Tap "+" floating action button
2. Dialog opens with form fields:
   - Class Name (required)
   - Description (optional)
3. Validation: Class name cannot be empty or duplicate
4. Submit creates class via API
5. Success: Dialog closes, list refreshes, success message shown
6. Error: Error message displayed, form remains open

### 3. Edit Class Flow
1. Tap "Edit" from class context menu
2. Dialog opens pre-filled with current data
3. User modifies fields
4. Submit updates class via API
5. Success: Dialog closes, list refreshes with updated data
6. Error: Error message displayed, form remains open

### 4. Delete Class Flow
1. Tap "Delete" from class context menu
2. Confirmation dialog appears
3. User confirms deletion
4. API call to delete class
5. Success: Class removed from list, success message shown
6. Error: Error message displayed (e.g., "Cannot delete, students enrolled")

## Network Error Handling

### Connection Issues
- **Offline Detection:** Check network connectivity before API calls
- **Timeout Handling:** 10-second timeout for all requests
- **Retry Logic:** Manual retry button on error screens
- **User Feedback:** Clear error messages with suggested actions

### API Error Responses
- **400 Bad Request:** Validation errors (duplicate class name, empty fields)
- **401 Unauthorized:** Token expired, redirect to login
- **404 Not Found:** Class doesn't exist
- **500 Server Error:** Generic server error message

### Loading States
- **List Loading:** Circular progress indicator while fetching classes
- **Action Loading:** Button loading state during create/update/delete
- **Pull-to-Refresh:** Native refresh indicator

## Authentication Integration

### Token Management
- Uses existing `AuthService.getToken()` method
- Automatically includes Bearer token in all API requests
- Handles token expiration and redirects to login

### Permission Checks
```dart
bool _canManageClasses() {
  final authProvider = Provider.of<AuthProvider>(context, listen: false);
  final userRole = authProvider.user?.role?.toLowerCase();
  return userRole == 'admin';
}
```

## Integration with Existing Features

### Student Management
- Class updates automatically reflect in student records
- When class name is changed, all students in that class are updated
- Class deletion is prevented if students are enrolled

### Attendance System
- Classes are available in attendance screen class filter
- Existing attendance records remain intact when class names change

### Dashboard Integration
- "Manage Classes" quick action card added to dashboard
- Only visible to users with appropriate permissions
- Direct navigation to Class Management screen

## Technical Constraints Followed

✅ **No Backend Changes:** Uses existing API endpoints exactly as implemented
✅ **Existing Authentication:** Reuses current token-based authentication
✅ **Database Schema:** No changes to existing class table structure
✅ **API Standards:** Follows existing request/response formats
✅ **Error Handling:** Consistent with existing mobile app patterns
✅ **State Management:** Uses same Provider pattern as other features

## Files Created/Modified

### New Files
- `lib/models/class_model.dart` - Class data model
- `lib/providers/class_provider.dart` - State management
- `lib/screens/class_management_screen.dart` - UI implementation

### Modified Files
- `lib/services/api_service.dart` - Added class management methods
- `lib/main.dart` - Added ClassProvider to app providers
- `lib/screens/dashboard_screen.dart` - Added navigation to class management

## Testing Checklist

### API Integration
- [ ] Get classes list loads correctly
- [ ] Create class with valid data succeeds
- [ ] Create class with duplicate name fails appropriately
- [ ] Update class with valid data succeeds
- [ ] Delete empty class succeeds
- [ ] Delete class with students fails with proper message
- [ ] Network errors handled gracefully
- [ ] Authentication errors redirect to login

### UI/UX
- [ ] Class list displays correctly
- [ ] Search functionality works
- [ ] Pull-to-refresh updates data
- [ ] Create dialog validates input
- [ ] Edit dialog pre-fills data
- [ ] Delete confirmation prevents accidental deletion
- [ ] Loading states show during operations
- [ ] Success/error messages display appropriately
- [ ] Permission-based access control works

### Integration
- [ ] Dashboard navigation works
- [ ] Class changes reflect in student management
- [ ] Class changes reflect in attendance system
- [ ] App state persists across navigation
- [ ] Provider state updates correctly

This implementation provides a complete Class Management system for the mobile app that seamlessly integrates with the existing website backend without requiring any server-side changes.