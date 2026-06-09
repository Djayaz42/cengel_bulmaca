// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:convert';
import 'dart:html' as html;

void downloadJsonFile(String filename, String content) {
  final bytes = Uri.dataFromString(
    content,
    mimeType: 'application/json',
    encoding: const Utf8Codec(),
  );
  final anchor = html.AnchorElement(href: bytes.toString())
    ..download = filename
    ..style.display = 'none';
  html.document.body?.children.add(anchor);
  anchor.click();
  anchor.remove();
}
