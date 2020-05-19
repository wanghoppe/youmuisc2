

import 'dart:convert';
import 'dart:io';

import 'package:youmusic2/client/client.dart';
import 'package:youmusic2/client/utils.dart';


void main(){
  test2();
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
