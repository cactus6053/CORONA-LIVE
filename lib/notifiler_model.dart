import 'package:flutter/foundation.dart';
import 'package:pa3/base_model.dart';

class StatelessNotifier extends BaseModel with ChangeNotifier {

  @override
  set setValid(bool valid){
    super.setValid = valid;
    notifyListeners();
  }

  @override
  set setcaseValid(bool valid){
    super.setcaseValid = valid;
    notifyListeners();
  }

  @override
  set setcaseNum(int value){
    super.setcaseNum = value;
    notifyListeners();
  }

  @override
  set setGraphNum(int value){
    super.setGraphNum = value;
    notifyListeners();
  }

  @override
  void dispose() {
    super.dispose();
  }
}