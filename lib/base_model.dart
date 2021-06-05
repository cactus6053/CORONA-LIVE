class BaseModel {
  int _graphNum = 1;
  bool _valid = true;
  int _caseNum = 1 ;
  bool _casevalid = true;

  bool get isValid => _valid;

  int get isNum => _graphNum;

  int get iscase => _caseNum;

  bool get iscaseValid => _casevalid;

  set setValid(bool valid){
    _valid = valid;
  }

  set setGraphNum(int value){
    _graphNum = value;
  }

  set setcaseNum(int value){
    _caseNum = value;
  }

  set setcaseValid(bool valid){
    _casevalid = valid;
  }
}