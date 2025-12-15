import 'dart:io';

void main() async {
  final path =
      '/home/night/Documents/Code/TeWo/TeWo-P/#dynamic_json_widgets_test/contents.json';
  final file = File(path);
  print('Checking path: $path');
  if (await file.exists()) {
    print('File exists!');
    print(await file.readAsString());
  } else {
    print('File NOT found!');
    final dir = Directory(
      '/home/night/Documents/Code/TeWo/TeWo-P/#dynamic_json_widgets_test',
    );
    if (await dir.exists()) {
      print('Directory exists. Listing contents:');
      await for (var entity in dir.list()) {
        print(entity.path);
      }
    } else {
      print('Directory NOT found!');
    }
  }
}
