// Simple test for Ethiopian date functionality
// Run this in browser console to test

// Test the day selection issue
const testEthiopianDate = {
  year: 2018,
  month: 7, // ታኅሳስ
  day: 1
};

console.log('Test Ethiopian Date:', testEthiopianDate);

// Test day comparison
const selectedDay = 1;
const currentDay = testEthiopianDate.day;

console.log('Selected day:', selectedDay, typeof selectedDay);
console.log('Current day:', currentDay, typeof currentDay);
console.log('Are they equal?', selectedDay === currentDay);
console.log('Are they equal (Number)?', Number(selectedDay) === Number(currentDay));

// Test with different values
for (let i = 1; i <= 5; i++) {
  const isSelected = Number(currentDay) === Number(i);
  console.log(`Day ${i}: selected = ${isSelected}`);
}