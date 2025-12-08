// Test current Ethiopian date conversion
// December 7, 2025

const now = new Date('2025-12-07');
console.log('Gregorian date:', now.toDateString());

// Ethiopian New Year 2018 started on September 11, 2025
const ethNewYear2018 = new Date('2025-09-11');
console.log('Ethiopian New Year 2018:', ethNewYear2018.toDateString());

// Calculate days since Ethiopian New Year
const daysSinceNewYear = Math.floor((now.getTime() - ethNewYear2018.getTime()) / (1000 * 60 * 60 * 24));
console.log('Days since Ethiopian New Year:', daysSinceNewYear);

// Convert to Ethiopian month and day
const ethMonth = Math.floor(daysSinceNewYear / 30) + 1;
const ethDay = (daysSinceNewYear % 30) + 1;

console.log('Ethiopian month:', ethMonth);
console.log('Ethiopian day:', ethDay);

const months = [
  'መስከረም', 'ጥቅምት', 'ኅዳር', 'ታኅሳስ', 'ጥር', 'የካቲት',
  'መጋቢት', 'ሚያዝያ', 'ግንቦት', 'ሰኔ', 'ሐምሌ', 'ነሐሴ', 'ጳጉሜን'
];

console.log(`Today should be: ${ethDay} ${months[ethMonth - 1]} 2018`);

// Manual calculation:
// Sept 11 to Dec 7 = 87 days
// 87 days = 2 months (60 days) + 27 days
// So it should be month 3 (ኅዳር), day 28
console.log('Manual calculation: 28 ኅዳር 2018');