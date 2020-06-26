//import 'package:audioplayers/audioplayers.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'dart:io' show Platform;

void main(){
  test();
}

void test() async{
  final videoId = 'JGwWNGJdvx8';
  final yt = PlayerClient();
  final mediaStreams = await yt._client.getVideoMediaStream(videoId);
//  final audio140 = yt._find140(mediaStreams);
//  final audio251 = yt._find251(mediaStreams);

//  print(audio140.container);
//  print(audio140.audioEncoding);
//
//  print(audio251.container);
//  print(audio251.audioEncoding);
//
//
  print(mediaStreams.video.length);
  for (var muxed in mediaStreams.muxed){
//    print(muxed.container);
//    print(muxed.itag);
//    print(muxed.size);
    print(muxed.toString());
    print(muxed.size);
//    print(muxed.);
    print(muxed.url);
  }
}

class PlayerClient{
  final _client = YoutubeExplode();

  Future<String> getStreamingUrl(String videoId) async{
    final mediaStreams = await _client.getVideoMediaStream(videoId);
    if (Platform.isAndroid){
//      print(mediaStreams.audio.last.url.toString());
      return mediaStreams.audio.last.url.toString();
    }else if (Platform.isIOS){
//      print('fetching 140');
//      print(_find140(mediaStreams).url);
//      return _find140(mediaStreams).url.toString();
      return mediaStreams.muxed.last.url.toString();
    }
    return null;
  }

  AudioStreamInfo _find140(MediaStreamInfoSet mediaStreams){
    for (var audio in mediaStreams.audio) {
      print(audio.itag);
      print(audio.audioEncoding);
      print(audio.bitrate);
      print(audio.downloadStream());
      print('\n');
      if (audio.itag == 140) {
        return audio;
      }
    }
    return null;
  }

  AudioStreamInfo _find251(MediaStreamInfoSet mediaStreams){
    for (var audio in mediaStreams.audio) {
      if (audio.itag == 251) {
        return audio;
      }
    }
    return null;
  }
}

