//import 'package:audioplayers/audioplayers.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';
import 'dart:io' show Platform;

void main(){
  test();
}

void test() async{
  final videoId = 'lkLViPVPUaw';
  final yt = PlayerClient();
  final mediaStreams = await yt._client.getVideoMediaStream(videoId);
  final audio140 = yt._find140(mediaStreams);
  final audio251 = yt._find251(mediaStreams);

  print(audio140.url);
  print(audio251.bitrate);

//  AudioPlayer audioPlayer = AudioPlayer();
//
//  int result = await audioPlayer.play(audio251.url.toString());
//  if (result == 1) {
//    print('playing');
//  }
}

class PlayerClient{
  final _client = YoutubeExplode();

  Future<String> getStreamingUrl(String videoId) async{
    final mediaStreams = await _client.getVideoMediaStream(videoId);
    if (Platform.isAndroid){
      return _find251(mediaStreams).url.toString();
    }else if (Platform.isIOS){
      return _find140(mediaStreams).url.toString();
    }
    return null;
  }

  AudioStreamInfo _find140(MediaStreamInfoSet mediaStreams){
    for (var audio in mediaStreams.audio) {
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

