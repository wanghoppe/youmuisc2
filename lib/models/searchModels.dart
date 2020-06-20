
import 'package:flutter/foundation.dart';
import 'package:youmusic2/client/client.dart';
import 'package:youmusic2/client/searchUtils.dart';
import 'package:youmusic2/main.dart';

class SearchCloseProvider extends ChangeNotifier{

  bool show = false;

  void setShow(bool val){
    if (show != val){
      show = val;
      notifyListeners();
    }
  }
}

class SearchingIndicator extends ChangeNotifier{

  bool searching = false;

  void setSearching(bool val){
    if (searching != val){
      searching = val;
      notifyListeners();
    }
  }
}

enum SearchBodyType {
  none,
  result,
  suggestion,
  history
}

class SearchBodyProvider extends ChangeNotifier{

  SearchBodyType type =  SearchBodyType.none;
  Map json;
  final SearchingIndicator indicator = SearchingIndicator();
  final _client = getIt<ApiClient>();

  void setSearchBody(SearchBodyType type, Map json){
    this.type = type;
    this.json = json;
    notifyListeners();
  }

  Future<void> search(String query) async{
    indicator.setSearching(true);
    final response = await _client.getSearchResponse(query);
    final json = await compute(getSearchResult, response);
    indicator.setSearching(false);
    setSearchBody(SearchBodyType.result, json);
    notifyListeners();
  }

}