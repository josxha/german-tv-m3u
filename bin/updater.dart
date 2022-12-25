import 'dart:io';
import 'm3u_service.dart';

Future<void> main(List<String> args) async {
  final responseString = await M3uService.getFilteredString();
  final file = File("german-tv.m3u");
  await file.writeAsString(responseString, mode: FileMode.writeOnly);
  print("success! 😎");
}