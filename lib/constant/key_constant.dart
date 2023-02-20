class KeyConstant {
  factory KeyConstant() {
    return _singleton;
  }

  KeyConstant._internal();

  static final KeyConstant _singleton = KeyConstant._internal();

  final String apiKey = "AIzaSyAZcErImmvpgzC5LNocJsk1E6EU8JfloCQ";
}
