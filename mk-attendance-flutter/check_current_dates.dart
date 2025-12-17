// Check what each utility shows for today
import 'lib/utils/ethiopian_date.dart';
import 'lib/utils/correct_ethiopian_date.dart';

void main() {
  print('=== CHECKING CURRENT DATE UTILITIES ===');
  
  final now = DateTime.now();
  print('Current Gregorian date: ${now.toString().split(' ')[0]}');
  
  // Test EthiopianDateUtils (original)
  final originalDate = EthiopianDateUtils.getCurrentEthiopianDate();
  final originalFormatted = EthiopianDateUtils.formatEthiopianDate(originalDate);
  
  // Test CorrectEthiopianDateUtils (modified)
  final correctedDate = CorrectEthiopianDateUtils.getCurrentEthiopianDate();
  final correctedFormatted = CorrectEthiopianDateUtils.formatEthiopianDate(correctedDate);
  
  print('\n📊 EthiopianDateUtils (original):');
  print('   Ethiopian: ${originalDate['year']}-${originalDate['month']}-${originalDate['day']}');
  print('   Formatted: $originalFormatted');
  
  print('\n📅 CorrectEthiopianDateUtils (modified):');
  print('   Ethiopian: ${correctedDate['year']}-${correctedDate['month']}-${correctedDate['day']}');
  print('   Formatted: $correctedFormatted');
  
  print('\n🎯 CORRECT DATE SHOULD BE: 5 ታኅሳስ 2018');
  
  if (originalFormatted.contains('5 ታኅሳስ 2018')) {
    print('   ✅ EthiopianDateUtils shows CORRECT date');
  } else {
    print('   ❌ EthiopianDateUtils shows WRONG date');
  }
  
  if (correctedFormatted.contains('5 ታኅሳስ 2018')) {
    print('   ✅ CorrectEthiopianDateUtils shows CORRECT date');
  } else {
    print('   ❌ CorrectEthiopianDateUtils shows WRONG date');
  }
}