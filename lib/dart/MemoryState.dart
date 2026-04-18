import 'dart:async';

class MemoryState {
  static final MemoryState _state = MemoryState._init();

  factory MemoryState() {
    return _state;
  }

  MemoryState._init();

  bool useSQL = false;
  String mariaDBHost = "";
  String mariaDBUser = "";
  String mariaDBPass = "";
  String mariaDBName = "";
  String botToken = "";
  String authenticationToken = "";

  Timer? flushTimer;
  bool terminating = false;
}
