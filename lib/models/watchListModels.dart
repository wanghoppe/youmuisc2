
import 'package:flutter/cupertino.dart';
import 'package:youmusic2/client/client.dart';
import 'package:youmusic2/client/watchUtils.dart';
import 'package:youmusic2/main.dart';
import 'package:flutter/foundation.dart';

class WatchListProvider extends ChangeNotifier{

  final _client = getIt<ApiClient>();

  bool loading = true;

  bool isShuffle;
  bool isInfinite;
  Map<String, String> watchPlaylistEndpoint;
  String continuation;
  List<WatchItemProvider> watchList;
  int currentIdx;

  void setLoading(bool value){
    if (loading != value){
      loading = value;
      notifyListeners();
    }
  }

  Future<void> loadFromEndpoint(Map watchEndPoint, {currentVideoId}) async{
//    print(watchEndPoint);
    setLoading(true);

    final temp = {
      'videoId': watchEndPoint['videoId'],
      'playlistId': watchEndPoint['playlistId'],
      'params': watchEndPoint['params']
    };
    final response = await _client.getWatchResponse(temp);
    final map = await compute(getWatchMapFromStr, response);

    final List<Map> playList = map['playlist'];
    watchList = [];
    for (var i = 0; i < playList.length; ++i) {
      var map = playList[i];
      if (map['videoId'] == currentVideoId){
        currentIdx = i;
        watchList.add(WatchItemProvider(map, playing: true));
      }else{
        watchList.add(WatchItemProvider(map, playing: false));
      }
    }
    if (currentVideoId == null){
      watchList[0].playing = true;
      currentIdx = 0;
    }

    isShuffle = map['isShuffle'];
    isInfinite = map['isInfinite'];
    if (map.containsKey('watchPlaylistEndpoint')){
      watchPlaylistEndpoint = map['watchPlaylistEndpoint'];
    }
    if (map.containsKey('continuation')){
      continuation = map['continuation'];
    }
    setLoading(false);
  }

  void changePlayIndex(int index){
    if (index != currentIdx){
      watchList[currentIdx].setPlaying(false);
      watchList[index].setPlaying(true);
      currentIdx = index;
    }
  }

  WatchItemProvider getAndPlayNext(){
    watchList[currentIdx].setPlaying(false);
    if (currentIdx == watchList.length - 1){
      currentIdx = 0;
    }else{
      currentIdx ++;
    }
    print(currentIdx);
    watchList[currentIdx].setPlaying(true);
    return watchList[currentIdx];
  }


  WatchItemProvider getAndPlayPrev(){
    watchList[currentIdx].setPlaying(false);
    if (currentIdx == 0){
      currentIdx = watchList.length - 1;
    }else{
      currentIdx --;
    }
    watchList[currentIdx].setPlaying(true);
    return watchList[currentIdx];
  }



}

class WatchItemProvider extends ChangeNotifier{

  String title;
  String subtitle;
  String channel;
  String thumbnail1;
  String thumbnail2;
  String videoId;
  bool playing;

  WatchItemProvider(Map map, {this.playing}):
    title = map['title'],
    subtitle = map['subtitle'],
    channel = map['channel'],
    thumbnail1 = map['thumbnail1'],
    thumbnail2 = map['thumbnail2'],
    videoId = map['videoId'];

  void setPlaying(bool value){
    if (playing != value){
      playing = value;
      notifyListeners();
    }
  }

}