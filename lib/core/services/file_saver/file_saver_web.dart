import 'dart:async';
import 'dart:convert';
import 'dart:html' as html;

Future<void> saveAndLaunchFile(List<int> bytes, String fileName) async {
  final base64 = base64Encode(bytes);
  final anchor = html.AnchorElement(
    href: 'data:application/octet-stream;charset=utf-16le;base64,$base64',
  );
  anchor.download = fileName;
  anchor.click();
}
