// Simple test file to verify Ethiopian date utility
import 'lib/utils/ethiopian_date.dart';

void main() {
  print('Testing Ethiopian Date Utility...');
  
  // Test 1: Get current Ethiopian date
  try {
    final currentEth = EthiopianDateUtils.getCurrentEthiopianDate();
    print('✅ Current Ethiopian date: ${currentEth['year']}-${currentEth['month']}-${currentEth['day']}');
  } catch (e) {
    print('❌ Error getting current Ethiopian date: $e');
  }
  
  // Test 2: Convert Ethiopian to Gregorian
  try {
    final testEthDate = {'year': 2017, 'month': 4, 'day': 5};
    final gregorianDate = EthiopianDateUtils.ethiopianToGregorian(testEthDate);
    print('✅ Ethiopian to Gregorian conversion: 2017-4-5 → $gregorianDate');
  } catch (e) {
    print('❌ Error in Ethiopian to Gregorian conversion: $e');
  }
  
  // Test 3: Convert Gregorian to Ethiopian
  try {
    final testGregDate = '2024-12-05';
    final ethiopianDate = EthiopianDateUtils.gregorianToEthiopianFromString(testGregDate);
    print('✅ Gregorian to Ethiopian conversion: $testGregDate → ${ethiopianDate['year']}-${ethiopianDate['month']}-${ethiopianDate['day']}');
  } catch (e) {
    print('❌ Error in Gregorian to Ethiopian conversion: $e');
  }
  
  // Test 4: Format Ethiopian date
  try {
    final testEthDate = {'year': 2017, 'month': 4, 'day': 5};
    final formatted = EthiopianDateUtils.formatEthiopianDate(testEthDate);
    print('✅ Ethiopian date formatting: $formatted');
  } catch (e) {
    print('❌ Error formatting Ethiopian date: $e');
  }
  
  // Test 5: Access public months list
  try {
    final firstMonth = EthiopianDateUtils.ethiopianMonths[0];
    print('✅ First Ethiopian month: $firstMonth');
    print('✅ Total months: ${EthiopianDateUtils.ethiopianMonths.length}');
  } catch (e) {
    print('❌ Error accessing Ethiopian months: $e');
  }
  
  print('\nTest complete! If you see ❌ errors above, those need to be fixed.');
}