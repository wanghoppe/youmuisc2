import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'client.dart';


class HomePageStream{
  final _controller = StreamController<Map>();
  ApiClient client;

  HomePageStream({@required this.client}){
    _init();
  }

  void _init() async{
    var resString = await client.getFirstResponse();
    var resMap = await compute(getFirstInfoFromStr, resString);
    for (var row in resMap['list']){
      _controller.sink.add(row);
    }

    while (resMap['hasContinue']){
      resString = await client.getContinueResponse(
          resMap['continuation'], resMap['itct']
      );
      resMap = await compute(getContinueInfoFromStr, resString);
      for (var row in resMap['list']){
        _controller.sink.add(row);
      }
    }
    await _controller.close();
  }

  Stream<Map> get stream => _controller.stream;
}

Map<String, dynamic> getContinueInfoFromStr(String str){
  final infoMap = <String, dynamic>{};
  var infoList = <Map>[];
  final json = jsonDecode(str);
  final sectionListContinuation = json['continuationContents']
  ['sectionListContinuation'];
  for (final content in sectionListContinuation['contents']){
    if (content.containsKey('musicCarouselShelfRenderer')){
      infoList.add(_parseRow(content));
    }
  }
  infoMap['list'] = infoList;
  if (sectionListContinuation.containsKey('continuations')){
    final continueData = sectionListContinuation['continuations'][0]
    ['nextContinuationData'];

    infoMap['hasContinue'] = true;
    infoMap['continuation'] = continueData['continuation'];
    infoMap['itct'] = continueData['clickTrackingParams'];
  }else{
    infoMap['hasContinue'] = false;
  }
  return infoMap;
}


Map<String, dynamic> getFirstInfoFromStr(String str){
  final infoMap = <String, dynamic>{};
  var infoList = <Map>[];
  final json = jsonDecode(str);
  final sectionListRenderer = json['contents']['singleColumnBrowseResultsRenderer']
  ['tabs'][0]['tabRenderer']['content']['sectionListRenderer'];
  for (final content in sectionListRenderer['contents']){
    if (content.containsKey('musicCarouselShelfRenderer')){
      infoList.add(_parseRow(content));
    }
  }
  infoMap['list'] = infoList;
  if (sectionListRenderer.containsKey('continuations')){
    final continueData = sectionListRenderer['continuations'][0]
    ['nextContinuationData'];

    infoMap['hasContinue'] = true;
    infoMap['continuation'] = continueData['continuation'];
    infoMap['itct'] = continueData['clickTrackingParams'];
  }else{
    infoMap['hasContinue'] = false;
  }
  return infoMap;
}

Map<String, dynamic> _parseRow(row){
  final rowMap = <String, dynamic>{};
  rowMap['title'] = row['musicCarouselShelfRenderer']['header']
  ['musicCarouselShelfBasicHeaderRenderer']['title']['runs'][0]['text'];
  final items = row['musicCarouselShelfRenderer']['contents'];
  rowMap['itemList'] = [];
  for (final item in items){
    rowMap['itemList'].add(_parseItem(item));
  }
  return rowMap;
}

Map<String, dynamic> _parseItem(item){
  final itemMap = <String, dynamic>{};
  final content =  item['musicTwoRowItemRenderer'];
  itemMap['thumbnails'] = content['thumbnailRenderer']['musicThumbnailRenderer']
  ['thumbnail']['thumbnails'];
  itemMap['aspectRatio'] = content['aspectRatio'];
  itemMap['title'] = content['title']['runs'][0]['text'];
  itemMap['subtitleList'] = content['subtitle']['runs']?.map((it) => it['text'])?.toList();
  itemMap['navigationEndpoint'] = content['navigationEndpoint'];
  return itemMap;
}
