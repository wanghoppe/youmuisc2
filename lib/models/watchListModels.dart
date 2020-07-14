import 'package:flutter/cupertino.dart';
import 'package:youmusic2/client/client.dart';
import 'package:youmusic2/client/watchUtils.dart';
import 'package:youmusic2/main.dart';
import 'package:flutter/foundation.dart';
import 'dart:io';

import 'package:youmusic2/models/controllerModels.dart';

class WatchListProvider extends ChangeNotifier {
  final _client = getIt<ApiClient>();
  final _controllers =
      getIt<HomeNavigatorController>();

  bool loading = true;
  bool fromNet = true;

  bool isShuffle;
  bool isInfinite;
  Map watchPlaylistEndpoint;
  String continuation;
  List<WatchItemProvider> watchList;
  int currentIdx;

  void setLoading(bool value, {bool forceLoad: false}) {
    if (loading != value || forceLoad) {
      loading = value;
      notifyListeners();
    }
  }

  Future<void> loadFromEndpoint(Map watchEndPoint, {currentVideoId}) async {
    print(watchEndPoint);
    setLoading(true);

    fromNet = true;
    final temp = {
      'videoId': watchEndPoint['videoId'],
      'playlistId': watchEndPoint['playlistId'],
      'params': watchEndPoint['params'] ?? 'wAEB'
    };
    final response = await _client.getWatchResponse(temp);
    final watchMap = await compute(getWatchMapFromStr, response);
//    print(watchMap);

    final List<Map> playList = watchMap['playlist'];
    watchList = [];
    for (var i = 0; i < playList.length; ++i) {
      final map = playList[i];
      if (map['videoId'] == currentVideoId) {
        currentIdx = i;
        watchList.add(WatchItemProvider(map, playing: true));
      } else {
        watchList.add(WatchItemProvider(map, playing: false));
      }
    }
    if (currentVideoId == null) {
      watchList[0].playing = true;
      currentIdx = 0;
    }
    isShuffle = watchMap['isShuffle'];
    isInfinite = watchMap['isInfinite'];
    if (watchMap.containsKey('watchPlaylistEndpoint')) {
      watchPlaylistEndpoint = watchMap['watchPlaylistEndpoint'];
    }
//    print('here2');
    if (watchMap.containsKey('continuation')) {
      continuation = watchMap['continuation'];
    }
//    _controllers.createScrollController(currentIdx*66.0);
    setLoading(false);
    await Future.delayed(Duration(milliseconds: 200));
    _scrollToCurrentIndex();
  }

  Future<void> loadFromLocal(List<File> fileList, int index) async {
//    setLoading(true);
    fromNet = false;
    currentIdx = index;
    watchList = [];
    for (var i = 0; i < fileList.length; ++i) {
      final file = fileList[i];
      watchList.add(_getItemProviderFromFile(file, i == index));
    }
    isShuffle = null;
    isInfinite = null;
    watchPlaylistEndpoint = null;
    continuation = null;
//    _controllers.createScrollController(currentIdx*66.0);
    setLoading(false, forceLoad: true);
    await Future.delayed(Duration(milliseconds: 200));
    _scrollToCurrentIndex();
  }

  void changePlayIndex(int index) {
    if (index != currentIdx) {
      watchList[currentIdx].setPlaying(false);
      watchList[index].setPlaying(true);
      currentIdx = index;
      _scrollToCurrentIndex();
    }
  }

  void _scrollToCurrentIndex(){
    var position;
    if (watchList.length - currentIdx > 7){
      position = 66.0 * currentIdx;
    }else{
      position = _controllers.watchListController.position.maxScrollExtent;
    }
    _controllers.watchListController.animateTo(position,
        duration: Duration(milliseconds: 600), curve: Curves.ease);
  }

  WatchItemProvider getAndPlayNext() {
    var nextIdx;
    if (currentIdx == watchList.length - 1) {
      nextIdx = 0;
    } else {
      nextIdx = currentIdx + 1;
    }
    changePlayIndex(nextIdx);
    return watchList[nextIdx];
  }

  WatchItemProvider getAndPlayPrev() {
    var nextIdx;
    if (currentIdx == 0) {
      nextIdx = watchList.length - 1;
    } else {
      nextIdx = currentIdx - 1;
    }
    changePlayIndex(nextIdx);
    return watchList[nextIdx];
  }

  WatchItemProvider _getItemProviderFromFile(File file, bool playing) {
    final fileName = file.path.split('/').last;
    final fileNameLst = fileName.split(':::');
    final videoId = fileNameLst[2].substring(0, 11);
    return WatchItemProvider({
      'title': fileNameLst[0],
      'subtitle': fileNameLst[1],
      'videoId': videoId,
      'localPath': file.path,
      'channel': fileNameLst[1],
      'thumbnail1': file.parent.parent.path + '/img/$videoId',
      'thumbnail2': file.parent.parent.path + '/img/$videoId'
    }, playing: playing, network: false);
  }
}

class WatchItemProvider extends ChangeNotifier {
  String title;
  String subtitle;
  String channel;
  String thumbnail1;
  String thumbnail2;
  String videoId;
  String localPath;
  bool playing;

  bool fromNet;

  WatchItemProvider(Map map, {this.playing, bool network})
      : title = map['title'],
        subtitle = map['subtitle'],
        channel = map['channel'],
        thumbnail1 = map['thumbnail1'],
        thumbnail2 = map['thumbnail2'],
        videoId = map['videoId'],
        localPath = map['localPath'],
        fromNet = network ?? true;

  void setPlaying(bool value) {
    if (playing != value) {
      playing = value;
      notifyListeners();
    }
  }
}
