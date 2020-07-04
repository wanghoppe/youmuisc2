import 'dart:async';

import 'package:audio_service/audio_service.dart';
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

  AudioPlayerProvider() {
    AudioService.connect();
    AudioService.start(backgroundTaskEntrypoint: _audioPlayerTaskEntrypoint);

    AudioService.playbackStateStream.listen((state) {
      print('here');
      print(state.updateTime);
      print('state');
      _playingSubject.add(state.playing);
//      _positionSubject.add(state.currentPosition);
      _bufferSubject.add(state.bufferedPosition);

      if (state.processingState == AudioProcessingState.buffering){
        _bufferingSubject.add(true);
      }else{
        _bufferingSubject.add(false);
      }

    });

    AudioService.currentMediaItemStream.listen((event) {
      _durationSubject.add(event.duration);
    });

    AudioService.customEventStream.listen((event) {
      switch (event.key){
        case 'position':
          _positionSubject.add(event.value);
          break;
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
//    if (_audioPlayer.playbackState == AudioPlaybackState.playing){
//      await _audioPlayer.stop();
//    }
    final url = await _playerClient.getStreamingUrl(videoId);
    await AudioService.playFromMediaId(url);
//    await _audioPlayer.setUrl(url);
//    await _audioPlayer.play(); //todo
//
//    if (! _audioPlayer.playbackEvent.buffering) _bufferingSubject.add(false);
  }

  void play() {
    AudioService.play();
//    _playingSubject.add(true);
//    await finishSet;
//    await _audioPlayer.play();
  }

  void pause() async {
    AudioService.pause();
//    _playingSubject.add(false);
  }

  Future<void> seek(Duration position) {
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

  @override
  void onPlayMediaItem(MediaItem mediaItem) {
    _mediaItem = mediaItem;
  }

  @override
  onStart(Map<String, dynamic> params) {
    _playingSubscription = _audioPlayer.playbackEventStream
        .map((event) => event.state == AudioPlaybackState.playing)
        .distinct()
        .listen(_sendPlaying);

    _durationSubscription = _audioPlayer.durationStream.listen(_sendDuration);

    _positionSubscription = _audioPlayer.getPositionStream(
        Duration(milliseconds: 500)
    ).listen(_sendPosition);

    _bufferSubscription = _audioPlayer.bufferedPositionStream.listen(_sendBuffer);

    _bufferingSubscription = _audioPlayer.bufferingStream.listen(_sendBuffering);

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
    _sendPlaying(true);
  }

  @override
  void onPause() {
    _audioPlayer.pause();
    _sendPlaying(false);
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
      Duration buffer,
      AudioProcessingState processingState
  }) async {
//    print('in the _setState: ${position.inMilliseconds}');
//    print(duration);
//    print(buffer);
//    print(processingState);
    await AudioServiceBackground.setState(
        controls: getControls(),
        systemActions: [MediaAction.seekTo],
        processingState: processingState ?? AudioProcessingState.ready,
        playing: playing ?? _audioPlayer.playbackState == AudioPlaybackState.playing,
        position: _audioPlayer.playbackEvent.position,
        bufferedPosition: buffer
    );
  }

  void _sendPlaying(bool value){
    _setState(playing: value);
  }

  void _sendDuration(Duration value){

    AudioServiceBackground.setMediaItem(
      MediaItem(
          album: (_mediaItem != null) ? _mediaItem.album: '',
          id: (_mediaItem != null) ? _mediaItem.id : 'id',
          title: (_mediaItem != null) ? _mediaItem.title: 'YouMusic2',
          artUri: (_mediaItem != null) ? _mediaItem.artUri: null,
          duration: value
      )
    );
  }

  void _sendPosition(Duration value){
    AudioServiceBackground.sendCustomEvent(
      CustomBackEvent('position', value)
    );
  }

  void _sendBuffer(Duration value){
    print('sending buffer, expect to see here');
    _setState(buffer: value);
  }

  void _sendBuffering(bool value){
    if (value) _setState(processingState: AudioProcessingState.buffering);
    else _setState(processingState: AudioProcessingState.none);
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

    AudioService.playMediaItem(
      MediaItem(
        id: titleVal,
        album: subtitleVal,
        title: titleVal,
        artUri: image
      )
    );
  }
}

class MediaItemMemo{
  String album;
  String title;
  String artUrl;
}
