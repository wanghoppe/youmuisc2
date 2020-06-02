const queryParaBase = {
  'alt': 'json',
  'key': 'AIzaSyC9XL3ZjWddXya6X74dJoCTL-WEYFDNX30'
};


const bodyClientMap = {
  'clientName': 'WEB_REMIX',
  'clientVersion': '0.1',
  'hl': 'en',
  'gl': 'US',
  'experimentIds': [],
  'experimentsToken': '',
//      'utcOffsetMinutes': 480,
  'locationInfo': {
    'locationPermissionAuthorizationStatus': 'LOCATION_PERMISSION_AUTHORIZATION_STATUS_UNSUPPORTED'
  },
  'musicAppInfo': {
    'musicActivityMasterSwitch': 'MUSIC_ACTIVITY_MASTER_SWITCH_INDETERMINATE',
    'musicLocationMasterSwitch': 'MUSIC_LOCATION_MASTER_SWITCH_INDETERMINATE',
    'pwaInstallabilityStatus': 'PWA_INSTALLABILITY_STATUS_CAN_BE_INSTALLED'
  }
};


const bodyMap = {
  'context': {
    'client': bodyClientMap,
    'capabilities': {},
    'request': {
      'internalExperimentFlags': [
        {
          'key': 'force_music_enable_outertube_tastebuilder_browse',
          'value': 'true'
        },
        {
          'key': 'force_music_enable_outertube_playlist_detail_browse',
          'value': 'true'
        },
        {
          'key': 'force_music_enable_outertube_search_suggestions',
          'value': 'true'
        }
      ],
      'sessionIndex': 0
    },
    'activePlayers': {},
    'user': {
      'enableSafetyMode': false
    }
  }
};

const headerMapBase = <String, String>{
  'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.87 Safari/537.36',
  'Content-Type': 'application/json',
  'Accept': '*/*',
  'Referer': 'music.youtube.com',
};

const getHeaderMap = <String, String>{
  'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/80.0.3987.87 Safari/537.36',
};


const firstBodyMap = <String, dynamic>{
  'context': {
    'client': bodyClientMap,
    'capabilities': {},
    'request': {
      'internalExperimentFlags': [
        {
          'key': 'force_music_enable_outertube_tastebuilder_browse',
          'value': 'true'
        },
        {
          'key': 'force_music_enable_outertube_playlist_detail_browse',
          'value': 'true'
        },
        {
          'key': 'force_music_enable_outertube_search_suggestions',
          'value': 'true'
        }
      ],
      'sessionIndex': 0
    },
    'clickTracking': {
      'clickTrackingParams': 'IhMI2KSO4YWc6QIV0ojECh14-g9tMghleHRlcm5hbA=='
    },
    'activePlayers': {},
    'user': {
      'enableSafetyMode': false
    }
  },
  'browseId': 'FEmusic_home'
};

const headerTest = {
  'x-origin': 'https://music.youtube.com',
  'Authorization':'SAPISIDHASH 1590021454_c0cbce4e0ae1b19189f7b3a4d37c68a98a215e73',
  'Cookie': 'VISITOR_INFO1_LIVE=Bd47smnphgU; CONSENT=YES+CA.en+202002; PREF=f1=5000'
      '0000&cvdm=grid&f5=20030&al=zh-CN&f4=4000000&volume=100&hl=en; LOGIN_INFO=AFmm'
      'F2swRAIgMUkd2pFEoPjwz1AQFYA6sAZ2tr6Ml2ryWZ6WI8Q4KHUCIDJrEUKUxxhicGmEfMNn9c-AQ'
      'n2uZq1L-EQis6TZkql1:QUQ3MjNmenNiTzhUZy1ZMUlWTXF5eWcwSlIwX3lacFpLZXkyeU1IOHFqT3'
      'pUMTdWemNKSzZ5V0hXeVN0LVhzb2VxNTFEOWJVcGViTDdVWERZcjg2Um44a0t6UTRmZjZPSXgzO'
      'G42T29WRGtCWWsxMjhmRWtzS0dVSDVHOV9UdGJEdGZGd3RBNF9wdGlhS3lZVlVRLTVoaGk4TTBfa0'
      '1zT2RrQi1RSDh2ZlJvTTJUSEdNSG93NlZF; SID=xQcfPyhC6lIKEr-6pUtMhEzasxkQC0yabbnG6'
      'xG2zVqqXuKM89cAAqo1ydcCUtnVfZDPCw.; __Secure-3PSID=xQcfPyhC6lIKEr-6pUtMhEzasxkQ'
      'C0yabbnG6xG2zVqqXuKM-GL6yVbYljOo9rqV8vz9yg.; HSID=AL-hKG3MtBWX56deQ; SSID=Ad1O'
      'eZh4YSEhoPfI0; APISID=BLlMNaNaRf5tTUYq/AjIGMwMAng8_y4TqP; SAPISID=UVn0_svq6M'
      'NFFPO-/ACAWer2n7r3EnxtuG; __Secure-HSID=AL-hKG3MtBWX56deQ; __Secure-SSID=Ad1'
      'OeZh4YSEhoPfI0; __Secure-APISID=BLlMNaNaRf5tTUYq/AjIGMwMAng8_y4TqP; __Secure-'
      '3PAPISID=UVn0_svq6MNFFPO-/ACAWer2n7r3EnxtuG; YSC=5wkMIp7LjJo; dkv=b2e78a30cb2'
      'aab9a4e03e112a8f4dbcce3QEAAAAdGxpcGl+zcVeMA==; AST=MTU5MDAyMTUwMg==; SIDCC='
      'AJi4QfFBx5ggf-ymFk7GkUD1bwzhaIzPYW2YxPB1oGockD0BnE7O2rtNy-5oIaK5iHi5rqMVTQ'
};


const watchEndpointBody = {
  "enablePersistentPlaylistPanel": true,
  "tunerSettingValue": "AUTOMIX_SETTING_NORMAL",
  "videoId": "vaknSDdG6xs",
  "playlistId": "RDAMVMvaknSDdG6xs",
  "params": "wAEB",
  "isAudioOnly": true
};

const watchEndpointBody2 = {
  "enablePersistentPlaylistPanel": true,
  "tunerSettingValue": "AUTOMIX_SETTING_NORMAL",
  "playlistId": "RDMM",
  "params": "wAEB",
  "isAudioOnly": true
};

const watchEndpointBody20 = {
  "enablePersistentPlaylistPanel": true,
  "tunerSettingValue": "AUTOMIX_SETTING_NORMAL",
  'videoId': "AoAm4om0wTs",
  'playlistId': "PLp12xt0S4J0VNJC-eGFd77RLRuQawkaZn",
  "params": "wAEB",
  "isAudioOnly": true
};