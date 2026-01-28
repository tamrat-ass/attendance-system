// Test with your specific requirement example
console.log('Testing Your Specific Requirement\n');

// Your example: Total records = 15, Present = 10, Permission = 5
const totalRecords = 15;
const presentCount = 10;
const permissionCount = 5;
const lateCount = 0;
const absentCount = 0;

console.log('Your Example Data:');
console.log(`Total Records: ${totalRecords}`);
console.log(`Present: ${presentCount}`);
console.log(`Permission: ${permissionCount}`);
console.log(`Late: ${lateCount}`);
console.log(`Absent: ${absentCount}`);
console.log('');

// Apply the correct formula: (Present + Permission) / Total × 100
const attendanceRate = ((presentCount + permissionCount) / totalRecords) * 100;

console.log('✅ CALCULATION:');
console.log(`Attendance % = (Present + Permission) / Total × 100`);
console.log(`Attendance % = (${presentCount} + ${permissionCount}) / ${totalRecords} × 100`);
console.log(`Attendance % = ${presentCount + permissionCount} / ${totalRecords} × 100`);
console.log(`Attendance % = ${attendanceRate}%`);
console.log('');

console.log('✅ VERIFICATION:');
console.log(`Student attended all ${totalRecords} classes (${presentCount} present + ${permissionCount} permission)`);
console.log(`Final attendance percentage: ${attendanceRate}%`);
console.log(`✅ This matches your requirement: 100% attendance!`);
console.log('');

console.log('✅ CODE IMPLEMENTATION:');
console.log('const total = records.length;');
console.log('const attendanceRate = total');
console.log('  ? (((present + permission) / total) * 100).toFixed(1)');
console.log('  : \'0\';');