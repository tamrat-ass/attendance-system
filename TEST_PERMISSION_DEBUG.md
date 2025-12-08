# Permission Debug Test

## Steps to Debug:

1. **Open Browser Console** (F12)

2. **Check localStorage**:
```javascript
console.log('User data:', JSON.parse(localStorage.getItem('user')));
```

3. **Check specific permissions**:
```javascript
const user = JSON.parse(localStorage.getItem('user'));
console.log('can_add_student:', user.can_add_student, typeof user.can_add_student);
console.log('can_upload_students:', user.can_upload_students, typeof user.can_upload_students);
console.log('can_delete_student:', user.can_delete_student, typeof user.can_delete_student);
```

## Expected Behavior:

- **Toggle ON** (checked in admin panel) → `can_add_student = true` → Button should be **ENABLED**
- **Toggle OFF** (unchecked in admin panel) → `can_add_student = false` → Button should be **DISABLED**

## Current Logic:

```typescript
disabled={loading || !currentUser?.can_add_student}
```

This means:
- If `can_add_student` is `true` → `!true` = `false` → button is NOT disabled (ENABLED) ✓
- If `can_add_student` is `false` → `!false` = `true` → button IS disabled (DISABLED) ✓

## If this is backwards, you need:

```typescript
disabled={loading || currentUser?.can_add_student}
```

This would mean:
- If `can_add_student` is `true` → button IS disabled
- If `can_add_student` is `false` → button is NOT disabled

**Please confirm which behavior you want!**
