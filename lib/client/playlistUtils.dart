

import 'dart:convert';
import 'dart:io';

import 'package:youmusic2/client/client.dart';
import 'package:youmusic2/client/utils.dart';


void main(){
  test3();
}

void test() async{
  var s = await File('output/playlist_example.json').readAsString();
  final infoList = getInfoListFromStr(s);
  prettyWrite(File('output/playlist/lst1.json'), {'infoList': infoList});
}




void test2() async{

  final navi = <String, dynamic>{
    "clickTrackingParams": "CAgQoLMCGAkiEwjt8aGV-J3pAhWT38QKHX25BLMyCG11cy1ob21l",
    "browseEndpoint": {
      "browseId": "VLRDCLAK5uy_mplKe9BIYCO3ZuNWSHZr48bm9DUDzbWnE",
      "browseEndpointContextSupportedConfigs": {
        "browseEndpointContextMusicConfig": {
          "pageType": "MUSIC_PAGE_TYPE_PLAYLIST"
        }
      }
    }
  };

  var client = ApiClient();
  final str = await client.getPlaylistResponse(navi);

//  final f = File('output/playlist/raw.txt');
//  f.writeAsStringSync(str);

  final infoList = getInfoListFromStr(str);
  prettyWrite(File('output/playlist/example1.json'), {'info': infoList});
}

// read output/playlist/album.json
void test3() async{
  final navi = {'clickTrackingParams': 'CCoQoLMCGAUiEwjK2rqzicvpAhWHksQKHbW1AXU=',
    'browseEndpoint': {'browseId': 'MPREb_OPkowziTdzc', 'params': 'ggMrGilPTEFLNXV5X240UnVhYWJ3dnFSclNhUEdIa0xBejVpM1YzUHRXSE40VQ%3D%3D',
      'browseEndpointContextSupportedConfigs': {'browseEndpointContextMusicConfig':
    {'pageType': 'MUSIC_PAGE_TYPE_ALBUM'}}}};
  final client = ApiClient();
  final str = await client.getPlaylistResponse(navi);
  prettyWrite(File('output/playlist/album_raw.json'), jsonDecode(str));
//  final str = File('output/playlist/album_raw.json').readAsStringSync();
  final infoList = getAlbumFromStr(str);
  prettyWrite(File('output/playlist/album_out.json'), {'info': infoList});
}

List<Map<String, dynamic>> getAlbumFromStr(String str){

  final json = jsonDecode(str);
  List<Map> content = json['frameworkUpdates']['entityBatchUpdate']
  ['mutations'].cast<Map>();

  final infoList = content
    .where((row) => row['payload'].containsKey('musicTrack'))
    .map<Map<String, dynamic>>(getAlbumItem).toList();
  return infoList;
}

Map<String, dynamic> getAlbumItem(Map row){

  String ms2Min(String ms){
    final num = (int.parse(ms)/ 1000).floor();
    final min = (num/60).floor();
    final sec = num % 60;
    final leading = (sec < 10)?'0':'';
    return '$min:$leading$sec';
  }

  final itemMap = <String, dynamic>{};
  row = row['payload']['musicTrack'];
  itemMap['title'] = row['title'];
  itemMap['videoId'] = row['videoId'];
  itemMap['subtitle'] = row['artistNames'] + ' • ' + ms2Min(row['lengthMs']);
  return itemMap;
}


List<Map<String, dynamic>> getInfoListFromStr(String str){

  final json = jsonDecode(str);
  List<Map> content = json['contents']['singleColumnBrowseResultsRenderer']
    ['tabs'][0]['tabRenderer']['content']['sectionListRenderer']['contents'][0]
    ['musicPlaylistShelfRenderer']['contents'].cast<Map>();

  final infoList = content.map<Map<String, dynamic>>(getItemMap).toList();

//  print(infoList.length);
  return infoList;
}

Map<String, dynamic> getItemMap(Map row){
  final itemMap = <String, dynamic>{};
  row = row['musicResponsiveListItemRenderer'];
  final flexCols = row['flexColumns'];
  final _runs0 = flexCols[0]['musicResponsiveListItemFlexColumnRenderer']
    ['text']['runs'][0];
  itemMap['title'] = _runs0['text'];
  itemMap['navigationEndpoint'] = _runs0['navigationEndpoint'];

  itemMap['subtitle'] = flexCols[1]['musicResponsiveListItemFlexColumnRenderer']
  ['text']['runs'][0]['text'];

  final time = row['fixedColumns'][0]
    ['musicResponsiveListItemFixedColumnRenderer']['text']['runs'][0]['text'];

  itemMap['subtitle'] += ' • $time';

  itemMap['thumbnails'] = row['thumbnail']['musicThumbnailRenderer']
    ['thumbnail']['thumbnails'];
  return itemMap;
}
