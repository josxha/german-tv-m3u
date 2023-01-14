import 'package:m3u_nullsafe/m3u_nullsafe.dart';
import 'package:http/http.dart' as http;

class M3uService {
  List<M3uGenericEntry> playlist;

  M3uService(this.playlist);

  static Future<String> getFilteredString() async {
    final service = await create();
    service.filter();
    return service.playlistToString();
  }

  static Future<M3uService> create() async {
    final uri = Uri.parse("https://raw.githubusercontent.com/jnk22/kodinerds-iptv/master/iptv/kodi/kodi_tv.m3u");
    final response = await http.get(uri);
    var playlist = await M3uParser.parse(response.body);
    return M3uService(playlist);
  }

  void filter() {
    List<M3uGenericEntry> list = [];
    const allowedCategories = ["Vollprogramm", "Spartenprogramm", "Regional"];
    List<String> regionalSenders = [];
    for (final entry in playlist) {

      // filter categories
      String? groupTitle = entry.attributes["group-title"];
      if (groupTitle == null) {
        continue;
      }
      var isAllowedCategory = false;
      for (final allowedCategory in allowedCategories) {
        if (groupTitle.contains(allowedCategory)) {
          isAllowedCategory = true;
        }
      }
      if (!isAllowedCategory) {
        continue;
      }

      // filter other languages
      String? tvgName = entry.attributes["tvg-name"];
      if (tvgName == null) {
        continue;
      }
      if (tvgName.contains("(FR)") || tvgName.contains("(EN)")) {
        continue;
      }

      // duplicate streams from regional senders
      if (groupTitle == "Regional") {
        final firstWord = tvgName.split(" ").first;
        if (regionalSenders.contains(firstWord)) {
          continue;
        }
        regionalSenders.add(firstWord);
      }

      // add to filtered list
      list.add(entry);
    }
    playlist = list;
  }

  String playlistToString() {
    final lines = ["#EXTM3U"];
    for (final entry in playlist) {
      final content = ["#EXTINF:-1"];
      for (final attribute in entry.attributes.entries) {
        content.add('${attribute.key}="${attribute.value ?? ""}"');
      }
      lines.add("${content.join(" ")},${entry.title}");
      lines.add(entry.link);
    }
    return lines.join("\n");
  }
}
