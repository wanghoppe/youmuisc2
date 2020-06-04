//import 'package:audioplayers/audioplayers.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

void main(){
  test();
}

void test() async{
  final videoId = 'lkLViPVPUaw';
  final yt = YoutubeExplode();
  final mediaStreams = await yt.getVideoMediaStream(videoId);
  final audio140 = find140(mediaStreams);
  final audio251 = find251(mediaStreams);

  print(audio140.url);
  print(audio251.url);

//  AudioPlayer audioPlayer = AudioPlayer();
//
//  int result = await audioPlayer.play(audio251.url.toString());
//  if (result == 1) {
//    print('playing');
//  }
}

AudioStreamInfo find140(MediaStreamInfoSet mediaStreams){
  for (var audio in mediaStreams.audio) {
    if (audio.itag == 140) {
      return audio;
    }
  }
}

AudioStreamInfo find251(MediaStreamInfoSet mediaStreams){
  for (var audio in mediaStreams.audio) {
    if (audio.itag == 251) {
      return audio;
    }
  }
}