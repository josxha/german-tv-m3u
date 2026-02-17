import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:m3u_nullsafe/m3u_nullsafe.dart';

Future<void> main(List<String> args) async {
  final playlist = await _fetchUpstream();
  final expressions = await _readExpressions();
  final filtered = _filter(playlist, expressions);
  final playlistString = _playlistToString(filtered);
  await File('german-tv.m3u').writeAsString(playlistString, mode: .writeOnly);
  // ignore: avoid_print
  print('success! 😎');
}

Future<List<M3uGenericEntry>> _fetchUpstream() async {
  const url =
      'https://raw.githubusercontent.com/jnk22/kodinerds-iptv/master/iptv/kodi/kodi_tv.m3u';
  final response = await http.get(Uri.parse(url));
  return M3uParser.parse(response.body);
}

Future<Set<RegExp>> _readExpressions() async {
  final file = File('expressions.txt');
  if (!file.existsSync()) {
    throw Exception('expressions.txt not found');
  }
  final lines = await file.readAsLines();
  return lines
      .map((line) => line.trim())
      .where((line) => line.isNotEmpty)
      .map((e) => RegExp('^$e( HD)?\$'))
      .toSet();
}

List<M3uGenericEntry> _filter(
  List<M3uGenericEntry> playlist,
  Set<RegExp> expressions,
) {
  final entries = <String, M3uGenericEntry>{};
  for (final entry in playlist) {
    final tvgName = entry.attributes['tvg-name']?.trim();
    if (tvgName == null || tvgName.isEmpty) continue;
    if (entries.containsKey(tvgName)) continue;

    // if the tvg-name does not match any of the expressions, skip it
    for (final expression in expressions) {
      if (expression.hasMatch(tvgName)) {
        // ignore: avoid_print
        print('[$tvgName] matches ${expression.pattern}');
        entries[tvgName] = entry;
        break;
      }
    }
  }
  return entries.values.toList(growable: false);
}

String _playlistToString(List<M3uGenericEntry> playlist) {
  final lines = ['#EXTM3U'];
  for (final entry in playlist) {
    final content = ['#EXTINF:-1'];
    for (final attribute in entry.attributes.entries) {
      content.add('${attribute.key}="${attribute.value ?? ""}"');
    }
    lines
      ..add("${content.join(" ")},${entry.title}")
      ..add(entry.link);
  }
  return lines.join('\n');
}
