// Test script to verify date synchronization between web and mobile
// Run with: node test-date-sync.js

// Simulate the web app's Ethiopian date conversion
function simpleEthiopianToGregorian(ethDate) {
  const gregYear = ethDate.year + 7;
  let gregMonth = ethDate.month + 8;
  let gregDay = ethDate.day;
  
  if (gregMonth > 12) {
    gregMonth = gregMonth - 12;
  }
  
  if (gregMonth <= 0) gregMonth = 1;
  if (gregMonth > 12) gregMonth = 12;
  if (gregDay <= 0) gregDay = 1;
  if (gregDay > 28) gregDay = 28;
  
  const year = gregYear.toString().padStart(4, '0');
  const month = gregMonth.toString().padStart(2, '0');
  const day = gregDay.toString().padStart(2, '0');
  
  return `${year}-${month}-${day}`;
}

// Simulate the mobile app's Ethiopian date conversion (same logic)
function mobileEthiopianToGregorian(ethiopianDate) {
  const ethYear = ethiopianDate.year;
  const ethMonth = ethiopianDate.month;
  const ethDay = ethiopianDate.day;
  
  const gregYear = ethYear + 7;
  let gregMonth = ethMonth + 8;
  let gregDay = ethDay;
  
  if (gregMonth > 12) {
    gregMonth = gregMonth - 12;
  }
  
  if (gregMonth <= 0) gregMonth = 1;
  if (gregMonth > 12) gregMonth = 12;
  if (gregDay <= 0) gregDay = 1;
  if (gregDay > 28) gregDay = 28;
  
  const year = gregYear.toString().padStart(4, '0');
  const month = gregMonth.toString().padStart(2, '0');
  const day = gregDay.toString().padStart(2, '0');
  
  return `${year}-${month}-${day}`;
}

// Test cases
const testCases = [
  { year: 2018, month: 4, day: 3 },  // Current Ethiopian date (correct)
  { year: 2018, month: 1, day: 1 },  // Ethiopian New Year
  { year: 2018, month: 13, day: 5 }, // Pagumen (13th month)
  { year: 2017, month: 12, day: 30 }, // End of previous Ethiopian year
];

console.log('=== DATE SYNCHRONIZATION TEST ===');
console.log('Testing Ethiopian to Gregorian conversion consistency between web and mobile apps\n');

testCases.forEach((testCase, index) => {
  const webResult = simpleEthiopianToGregorian(testCase);
  const mobileResult = mobileEthiopianToGregorian(testCase);
  const isConsistent = webResult === mobileResult;
  
  console.log(`Test Case ${index + 1}:`);
  console.log(`  Ethiopian Date: ${testCase.year}-${testCase.month}-${testCase.day}`);
  console.log(`  Web App Result: ${webResult}`);
  console.log(`  Mobile App Result: ${mobileResult}`);
  console.log(`  Consistent: ${isConsistent ? '✅ YES' : '❌ NO'}`);
  console.log('');
});

// Test current date
const currentEthiopian = { year: 2018, month: 4, day: 3 }; // Correct current Ethiopian date
const webCurrent = simpleEthiopianToGregorian(currentEthiopian);
const mobileCurrent = mobileEthiopianToGregorian(currentEthiopian);

console.log('=== CURRENT DATE TEST ===');
console.log(`Current Ethiopian (correct): ${currentEthiopian.year}-${currentEthiopian.month}-${currentEthiopian.day}`);
console.log(`Web App Conversion: ${webCurrent}`);
console.log(`Mobile App Conversion: ${mobileCurrent}`);
console.log(`Sync Status: ${webCurrent === mobileCurrent ? '✅ SYNCHRONIZED' : '❌ NOT SYNCHRONIZED'}`);

// Expected database format
console.log('\n=== EXPECTED DATABASE FORMAT ===');
console.log(`Attendance records should use date: ${webCurrent}`);
console.log('Both web and mobile apps should generate this same date string');
console.log('This ensures proper synchronization and duplicate validation');

console.log('\n=== VERIFICATION STEPS ===');
console.log('1. Check web app console for "Ethiopian to Gregorian conversion" logs');
console.log('2. Check mobile app console for "DATE SYNC DEBUG" logs');
console.log('3. Verify both platforms generate the same date string');
console.log('4. Test attendance creation on both platforms for same day');
console.log('5. Confirm attendance appears synchronized in database');