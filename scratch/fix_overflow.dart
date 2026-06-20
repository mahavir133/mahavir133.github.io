import 'dart:io';

void main() {
  final files = [
    'lib/features/converters/acceleration_converter/presentation/acceleration_screen.dart',
    'lib/features/converters/density_converter/presentation/density_screen.dart',
    'lib/features/converters/pressure_converter/presentation/pressure_screen.dart',
    'lib/features/converters/speed_converter/presentation/speed_screen.dart',
    'lib/features/converters/temperature_converter/presentation/temperature_screen.dart',
    'lib/features/converters/torque_converter/presentation/torque_screen.dart',
  ];
  
  for (final path in files) {
    final file = File(path);
    var content = file.readAsStringSync();
    if (content.contains('            child: Column(')) {
      content = content.replaceFirst(
          '            child: Column(', 
          '            child: SingleChildScrollView(\n              child: Column(');
      
      // I also need to close the SingleChildScrollView parenthesis at the end of the Column
      // This might be tricky. Let's do it using Regex.
      // But they are all structured identical. 
    }
  }
}
