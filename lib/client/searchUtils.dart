

import 'dart:convert';

import 'package:youmusic2/client/client.dart';
import 'dart:io';

import 'package:youmusic2/client/utils.dart';

void main(){
  searchTest();
//  suggestTest();
}

void searchTest() async{
  final client = ApiClient();
  final str = await client.getSearchResponse('ed');
  final f = File('output/search/raw_search_ed.json');
  f.writeAsStringSync(str);
  final processed = getSearchResult(str);
  prettyWrite(File('output/search/after_search_ed.json'), processed);
}

void suggestTest() async{
  final client = ApiClient();
  final str = await client.getSearchSuggest('ed');
  final f = File('output/search/raw_suggest_ed.json');
  f.writeAsStringSync(str);
}

Map<String, dynamic> getSearchResult(String response){
  final resultMap = <String, dynamic>{};

  final json = jsonDecode(response);
  final List<Map> contents = json['contents']['sectionListRenderer']['contents'].cast<Map>();
  final List<Map> chips = json['header']['musicHeaderRenderer']['header']
    ['chipCloudRenderer']['chips'].cast<Map>();

  resultMap['sections'] = contents.map<Map<String, dynamic>>(getSearchSection).toList();
  resultMap['continuations'] = json['contents']['sectionListRenderer']['continuations'];
  resultMap['header'] = chips.map<Map<String, dynamic>>(getHeaderChips).toList();

  return resultMap;
}

Map<String, dynamic> getHeaderChips(Map json){
  final chipMap = <String, dynamic>{};
  json = json['chipCloudChipRenderer'];
  chipMap['text'] = json['text']['runs'][0]['text'];
  chipMap['searchEndpoint'] = json['navigationEndpoint']['searchEndpoint'];
  return chipMap;
}

Map<String, dynamic> getSearchSection(Map json){
  final sectionMap = <String, dynamic>{};
  json = json['musicShelfRenderer'];
  final List<Map> contents = json['contents'].cast<Map>();

  sectionMap['rows'] = contents.map<Map<String, dynamic>>(getSearchRow).toList();
  sectionMap['title'] = json['title']['runs'][0]['text'];

  // hasMore & searchEndpoint
  if (json.containsKey('bottomEndpoint')){
    sectionMap['searchEndpoint'] = json['bottomEndpoint']['searchEndpoint'];
    sectionMap['hasMore'] = true;
  }else{
    sectionMap['hasMore'] = false;
  }

  return sectionMap;
}

enum SearchRowType{
  player,
  artist,
  playlist
}

Map<String, dynamic> getSearchRow(Map json){
  final rowMap = <String, dynamic>{};
  json = json['musicResponsiveListItemRenderer'];

  final List flexColumns =  json['flexColumns'];
  final List thumbnails = json['thumbnail']['musicThumbnailRenderer']
  ['thumbnail']['thumbnails'];

  rowMap['title'] = flexColumns[0]['musicResponsiveListItemFlexColumnRenderer']
    ['text']['runs'][0]['text'];
  rowMap['subtitle'] = flexColumns.sublist(1).map<String>((e) => e['musicResponsiveListItemFlexColumnRenderer']
    ['text']['runs'][0]['text']).toList().join(' • ');

  // type & endpoint
  if (json.containsKey('navigationEndpoint')){
    final browseEndpoint = json['navigationEndpoint']['browseEndpoint'];
    if (browseEndpoint['browseEndpointContextSupportedConfigs']
    ['browseEndpointContextMusicConfig']['pageType'] == 'MUSIC_PAGE_TYPE_ARTIST'){
      rowMap['type'] = SearchRowType.artist;
    }else{
      rowMap['type'] = SearchRowType.playlist;
    }
    rowMap['endpoint'] = browseEndpoint;
  }else{
    rowMap['type'] = SearchRowType.player;
    rowMap['endpoint'] = json['doubleTapCommand']['watchEndpoint'];
  }

  rowMap['thumbnail1'] = (thumbnails.length > 1)
      ? thumbnails[thumbnails.length - 2]['url']
      : thumbnails[0]['url'];

  rowMap['thumbnail2'] = thumbnails.last['url'];

  // cropCircle
  if (json['thumbnail']['musicThumbnailRenderer']
    ['thumbnailCrop'] == 'MUSIC_THUMBNAIL_CROP_CIRCLE'){
    rowMap['cropCircle'] = true;
  }else{
    rowMap['cropCircle'] = false;
  }

  return rowMap;
}