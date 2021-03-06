import 'dart:convert';

import 'package:youmusic2/client/client.dart';
import 'package:youmusic2/client/utils.dart';
import 'dart:io';
import 'requestConst.dart' as c;

void main() {
  test();
//  test2();
//  test3();
}

void test() async {
  final client = ApiClient();
  final test = {
//    'videoId': "AoAm4om0wTs",
//    'playlistId': "PLp12xt0S4J0VNJC-eGFd77RLRuQawkaZn",
//    "params": "wAEB",
    'videoId': '6VRioN8euIs',
    'playlistId': 'PL0C9A38D8FA52CF4B',
    'params': 'wAEB'
  };
  final response = await client.getWatchResponse(test);
  prettyWrite(File('output/watch/raw.json'), jsonDecode(response));
  print('raw file is written');
  final playMap = getWatchMapFromStr(response);
  prettyWrite(File('output/watch/after1.json'), playMap);

}

void test2() async {
  final client = ApiClient();
  final response = await client.getWatchResponse(c.watchEndpointBody2);
//  prettyWrite(File('output/watch/raw_mix.json'), jsonDecode(str));
  final playMap = getWatchMapFromStr(response);
  prettyWrite(File('output/watch/after_mix.json'), playMap);
}

void test3() async {
  final client = ApiClient();
  final response = await client.getWatchResponse(c.watchEndpointBody20);
  prettyWrite(File('output/watch/raw_20.json'), jsonDecode(response));
  final playMap = getWatchMapFromStr(response);
  prettyWrite(File('output/watch/after_top20.json'), playMap);
}

///Utils Function

Map<String, dynamic> getWatchMapFromStr(String response, {bool isShuffle: false}) {
  final playerMap = <String, dynamic>{};

  final json = jsonDecode(response);
  final Map playlistPanelRenderer = json['contents']
          ['singleColumnMusicWatchNextResultsRenderer']['playlist']
      ['playlistPanelRenderer'];
  final List contents = playlistPanelRenderer['contents'].cast<Map>();
  final bool isInfinite = playlistPanelRenderer['isInfinite'];
  if (playlistPanelRenderer.containsKey('continuations')){
    final Map conItem = playlistPanelRenderer['continuations'][0];
    playerMap['continuation'] = conItem[conItem.keys.toList()[0]]['continuation'];
  }else{
    playerMap['watchPlaylistEndpoint'] = contents.last
      ['automixPreviewVideoRenderer']['content']['automixPlaylistVideoRenderer']
      ['navigationEndpoint']['watchPlaylistEndpoint'];
  }

  playerMap['isShuffle'] = isShuffle;
  playerMap['playlist'] = contents
      .where((e) => e.containsKey('playlistPanelVideoRenderer'))
      .map<Map>((e) => _getPlaylistItem(e['playlistPanelVideoRenderer']))
      .where((element) => element != null).toList();
  playerMap['isInfinite'] = isInfinite;
  return playerMap;
}

Map<String, dynamic> _getPlaylistItem(Map json) {
  try{
    final item = <String, dynamic>{};
    List thumbnailList = json['thumbnail']['thumbnails'];

    item['title'] = json['title']['runs'][0]['text'] as String;
    item['subtitle'] = json['longBylineText']['runs'][0]['text'] as String;
    item['channel'] = item['subtitle'].split(' • ')[0];
    item['thumbnail1'] = thumbnailList.first['url'] as String;
    item['thumbnail2'] = thumbnailList.last['url'] as String;
    item['videoId'] = json['videoId'];
    return item;
  }catch(e){
//    print(json);
    return null;
  }
}
