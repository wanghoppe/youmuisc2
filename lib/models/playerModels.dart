import 'dart:async';

import 'package:audio_service/audio_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:rxdart/rxdart.dart';
import 'package:youmusic2/main.dart';
import 'package:youmusic2/playerClient/playerClient.dart';

MediaControl playControl = MediaControl(
  androidIcon: 'drawable/ic_action_play_arrow',
  label: 'Play',
  action: MediaAction.play,
);
MediaControl pauseControl = MediaControl(
  androidIcon: 'drawable/ic_action_pause',
  label: 'Pause',
  action: MediaAction.pause,
);
MediaControl skipToNextControl = MediaControl(
  androidIcon: 'drawable/ic_action_skip_next',
  label: 'Next',
  action: MediaAction.skipToNext,
);
MediaControl skipToPreviousControl = MediaControl(
  androidIcon: 'drawable/ic_action_skip_previous',
  label: 'Previous',
  action: MediaAction.skipToPrevious,
);
MediaControl stopControl = MediaControl(
  androidIcon: 'drawable/ic_action_stop',
  label: 'Stop',
  action: MediaAction.stop,
);

class AudioPlayerProvider {

  final _playerClient = getIt<PlayerClient>();

  final _playingSubject = BehaviorSubject<bool>();
  final _bufferingSubject = BehaviorSubject<bool>();
  final _durationSubject = BehaviorSubject<Duration>();
  final _positionSubject = BehaviorSubject<Duration>();
  final _bufferSubject = BehaviorSubject<Duration>();

  PlaybackState _playbackState;

  AudioPlayerProvider() {
    AudioService.start(backgroundTaskEntrypoint: _audioPlayerTaskEntrypoint);

    AudioService.playbackStateStream.listen((PlaybackState state) {
      print('receive here');
      print(state.processingState);
      if (state.processingState == AudioProcessingState.buffering){
        _bufferingSubject.add(true);
      }else{
        _bufferingSubject.add(false);
      }

      _playbackState = state;
      _playingSubject.add(state.playing);
    });

    AudioService.currentMediaItemStream.listen((event) {
      _durationSubject.add(event.duration);
    });

    AudioService.customEventStream.listen((event) {
//      print(event);
      switch (event.key){
        case 'position':
          _positionSubject.add(event.value);
          break;
        case 'buffer':
          _bufferSubject.add(event.value);
          break;
        case 'buffering':
          _bufferingSubject.add(event.value);
      }
    });

    Stream.periodic(Duration(milliseconds: 500)).listen((event) {
      if (_playbackState != null){
//        print(_playbackState.currentPosition);
        _positionSubject.add(_playbackState.currentPosition);
      }
    });
  }

  Stream<Duration> get durationStream => _durationSubject.distinct();

  Stream<Duration> get positionStream => _positionSubject.distinct();

  Stream<Duration> get bufferStream => _bufferSubject.distinct();

  Stream<bool> get playingStream => _playingSubject.distinct();

  Stream<bool> get bufferingStream => _bufferingSubject.distinct();

  Future<void> playFromVideoId(String videoId) async{
    _bufferingSubject.add(true);
    _durationSubject.add(null);
    final url = await _playerClient.getStreamingUrl(videoId);
    await AudioService.playFromMediaId(url);
  }

  void play() {
    AudioService.play();
  }

  void pause() async {
    AudioService.pause();
  }

  void seekTo(Duration position) {
    AudioService.seekTo(position);
  }
}

void _audioPlayerTaskEntrypoint() async {
  AudioServiceBackground.run(() => AudioPlayerTask());
}

class CustomBackEvent{
  final String key;
  final dynamic value;

  CustomBackEvent(this.key, this.value);
}

class AudioPlayerTask extends BackgroundAudioTask {

  final _audioPlayer = AudioPlayer();

  MediaItem _mediaItem;

  StreamSubscription<bool> _playingSubscription;
  StreamSubscription<Duration> _durationSubscription;
  StreamSubscription<Duration> _positionSubscription;
  StreamSubscription<Duration> _bufferSubscription;
  StreamSubscription<bool> _bufferingSubscription;

  StreamSubscription<AudioPlaybackEvent> _eventSubscription;

  @override
  Future<void> onUpdateMediaItem(MediaItem mediaItem) {
    _mediaItem = mediaItem;
    return null;
  }

  @override
  onStart(Map<String, dynamic> params) {
//    _playingSubscription = _audioPlayer.playbackEventStream
//        .map((event) => event.state == AudioPlaybackState.playing)
//        .distinct()
//        .listen(_sendPlaying);

    _durationSubscription = _audioPlayer.durationStream.listen(_sendDuration);

//    _positionSubscription = _audioPlayer.getPositionStream(
//        Duration(milliseconds: 500)
//    ).listen(_sendPosition);

    _bufferSubscription = _audioPlayer.bufferedPositionStream.distinct().listen(_sendBuffer);

//    _bufferingSubscription = _audioPlayer.bufferingStream
//        .debounceTime(Duration(milliseconds: 100))
//        .distinct()
//        .listen(_sendBuffering);

    _eventSubscription = _audioPlayer.playbackEventStream.listen((event) {
      final bufferingState = event.buffering ? AudioProcessingState.buffering
          : AudioProcessingState.ready;
      _setState(processingState: bufferingState);
    });

  }

  @override
  void onPlayFromMediaId(String mediaId) async{
    if (_audioPlayer.playbackState == AudioPlaybackState.playing){
      await _audioPlayer.stop();
    }
    await _audioPlayer.setUrl(mediaId);
    await _audioPlayer.play();
  }

  @override
  void onPlay() {
    _audioPlayer.play();
  }

  @override
  void onPause() {
    _audioPlayer.pause();
  }

  @override
  void onSeekTo(Duration position) {
    _audioPlayer.seek(position);
  }

  @override
  Future<void> onStop() async{
    await _audioPlayer.stop();
    await _audioPlayer.dispose();

    _playingSubscription.cancel();
    _durationSubscription.cancel();
    _positionSubscription.cancel();
    _bufferingSubscription.cancel();
    _bufferSubscription.cancel();

    // Shut down this task
    await super.onStop();
  }

  List<MediaControl> getControls() {
    if (_audioPlayer.playbackState == AudioPlaybackState.playing) {
      return [
        skipToPreviousControl,
        pauseControl,
        stopControl,
        skipToNextControl
      ];
    } else {
      return [
        skipToPreviousControl,
        playControl,
        stopControl,
        skipToNextControl
      ];
    }
  }

  Future<void> _setState ({
    bool playing,
    AudioProcessingState processingState
  }) async {

    await AudioServiceBackground.setState(
      controls: getControls(),
      systemActions: [MediaAction.seekTo],
      processingState: processingState ?? AudioServiceBackground.state.processingState,
      playing: playing ?? _audioPlayer.playbackState == AudioPlaybackState.playing,
      position: _audioPlayer.playbackEvent.position
    );
  }

  void _sendPlaying(bool value){
    print('send playing $value');
    _setState(playing: value);
  }

  void _sendDuration(Duration value){
    print('send duration');

    AudioServiceBackground.setMediaItem(
      _mediaItem.copyWith(duration: value)
    );
  }

//  void _sendPosition(Duration value){
//    AudioServiceBackground.sendCustomEvent(
//      CustomBackEvent('position', value)
//    );
//  }

  void _sendBuffer(Duration value){
    AudioServiceBackground.sendCustomEvent(
        CustomBackEvent('buffer', value)
    );
  }

  void _sendBuffering(bool value){
    print('sending buffering $value');
    AudioServiceBackground.sendCustomEvent(
        CustomBackEvent('buffering', value)
    );
  }

}

class PlayerInfoProvider extends ChangeNotifier {
  Future<String> futureUrl;

  Future<String> futureTitle;

  Future<String> futureSubtitle;

  Future<void> setValue(
      Future<String> url, Future<String> title, Future<String> subtitle) async {
    futureUrl = url;
    futureTitle = title;
    futureSubtitle = subtitle;
    notifyListeners();

    final image = await url;
    final titleVal = await title;
    final subtitleVal = await subtitle;

    AudioService.updateMediaItem(
      MediaItem(
        id: titleVal,
        album: subtitleVal,
        title: titleVal,
        artUri: image
      )
    );
  }
}

class CustomAudioServiceWidget extends StatefulWidget{

  final Widget child;

  CustomAudioServiceWidget({@required this.child});

  @override
  _CustomAudioServiceWidgetState createState() => _CustomAudioServiceWidgetState();
}

class _CustomAudioServiceWidgetState extends State<CustomAudioServiceWidget> {

  @override
  void initState() {
    super.initState();
    AudioService.connect();
  }

  @override
  void dispose() {
    AudioService.disconnect();
    super.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
