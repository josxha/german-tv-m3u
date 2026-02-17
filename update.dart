import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:m3u_nullsafe/m3u_nullsafe.dart';

Future<void> main(List<String> args) async {
  var playlist = await _fetchUpstream();
  playlist = _filter(playlist);
  final playlistString = _playlistToString(playlist);
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

List<M3uGenericEntry> _filter(List<M3uGenericEntry> playlist) {
  final list = <M3uGenericEntry>[];
  const allowedCategories = {'Vollprogramm', 'Spartenprogramm', 'Regional'};
  const whitelist = {'tagesschau24'};
  final regionalSenders = <String>{};
  for (final entry in playlist) {
    final tvgName = entry.attributes['tvg-name'];
    if (tvgName == null) continue;
    final groupTitle = entry.attributes['group-title'];
    if (groupTitle == null) continue;

    // whitelist senders
    if (whitelist.contains(tvgName)) {
      list.add(entry);
      continue;
    }

    // filter categories
    var isAllowedCategory = false;
    for (final allowedCategory in allowedCategories) {
      if (groupTitle.contains(allowedCategory)) {
        isAllowedCategory = true;
      }
    }
    if (!isAllowedCategory) continue;

    // filter other languages
    if (tvgName.endsWith('(FR)') ||
        tvgName.endsWith('(EN)') ||
        tvgName.endsWith('(AT)')) {
      continue;
    }
    if (tvgName.contains(RegExp(r'.*\([A-Z]{2}\)'))) continue;

    // duplicate streams from regional senders
    if (groupTitle == 'Regional') {
      final firstWord = tvgName.split(' ').first;
      if (regionalSenders.contains(firstWord)) continue;
      regionalSenders.add(firstWord);
    }

    // add to filtered list
    list.add(entry);
  }
  return list;
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
