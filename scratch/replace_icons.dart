import 'dart:io';

void main() {
  final dir = Directory('lib');
  final files = dir.listSync(recursive: true).whereType<File>().where((f) => f.path.endsWith('.dart'));
  
  for (final file in files) {
    var content = file.readAsStringSync();
    if (content.contains('Icons.attach_money')) {
      content = content.replaceAll('Icons.attach_money', 'Icons.account_balance_wallet');
      file.writeAsStringSync(content);
      print('Updated \${file.path}');
    }
  }
}
