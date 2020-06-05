


import 'package:just_audio/just_audio.dart';


class AudioPlayerProvider{
  static const testUrl = 'https://r6---sn-ni5f-t8gs.googlevideo.com/videoplayback?expire=1591320751&ei=T0zZXsK0Hcz_kga8upi4Aw&ip=24.87.163.50&id=o-AFXmubMFvoo9KhLduUKZ2hROoKtHFaIe5TCPbBYXCk4E&itag=251&source=youtube&requiressl=yes&mh=3A&mm=31%2C26&mn=sn-ni5f-t8gs%2Csn-vgqsrnek&ms=au%2Conr&mv=m&mvi=5&pcm2cms=yes&pl=14&initcwndbps=1766250&vprv=1&mime=audio%2Fwebm&gir=yes&clen=4377575&dur=267.261&lmt=1540664086012589&mt=1591299045&fvip=2&keepalive=yes&c=WEB&txp=5411222&sparams=expire%2Cei%2Cip%2Cid%2Citag%2Csource%2Crequiressl%2Cvprv%2Cmime%2Cgir%2Cclen%2Cdur%2Clmt&lsparams=mh%2Cmm%2Cmn%2Cms%2Cmv%2Cmvi%2Cpcm2cms%2Cpl%2Cinitcwndbps&lsig=AG3C_xAwRgIhALecGzvSO6wqZK7rpXdFjScUTbJMF3SnOlOIyKstdHjJAiEAxBt31SagKvtiTB-cntlF-vcl9czQOu_1JMCVXewWAiQ%3D&sig=AOq0QJ8wRQIhAKkEpIGrQaWM4kYcPFLcW-VPHmua109TwmFQA4Zt7HXJAiBnQCSxNKoNvHej5vAAyvkCDkX4CKqcSbkV72-0JTTf_g%3D%3D';
  final _audioPlayer = AudioPlayer();
  Future<void> finishSet;


  AudioPlayerProvider(){
    print('here1');
    finishSet = setUrl();
  }

  Stream<Duration> get durationStream => _audioPlayer.durationStream;

  Stream<Duration> get positionStream => _audioPlayer.getPositionStream();

  Stream<Duration> get bufferStream => _audioPlayer.bufferedPositionStream;

  Future<void> setUrl({String url: testUrl}) async{
    print('here2');
    await _audioPlayer.setUrl(url);
    print('setUrl finished');
  }
  
  void play() async{
    await finishSet;
    await _audioPlayer.play();
  }

  void pause() async{
    await finishSet;
    await _audioPlayer.pause();
  }

  Future<void> seek(Duration position) async{
    await _audioPlayer.seek(position);
  }
}