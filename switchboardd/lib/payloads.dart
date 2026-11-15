import 'package:switchboardd/consts.dart';

class BasicResponse {
  bool Success = false;
  String Path = "/";
  String Method = "GET";
  String ID = UUID_ZERO;
  String Reason = "";

  BasicResponse({
    required this.Success,
    required this.Path,
    required this.Method,
    required this.ID,
    required this.Reason,
  });

  /// Decode universal response fields.
  void decode(Map<String, dynamic> js) {
    Success = js['success'] ?? false;
    Path = js['path'] ?? "/";
    Method = js['method'] ?? "GET";
    ID = js['id'] ?? UUID_ZERO;
    Reason = js['reason'] ?? "";
  }

  /// Encode universal response fields.
  Map<String, dynamic> encode() {
    return {
      "success": Success,
      "path": Path,
      "method": Method,
      "id": ID,
      "reason": Reason,
    };
  }
}

class ServerPublicKeyResponse extends BasicResponse {
  String pemData = "";

  ServerPublicKeyResponse({
    required super.Success,
    required super.Path,
    required super.Method,
    required super.ID,
    required super.Reason,
    required this.pemData,
  });

  /// Decode the response.
  ServerPublicKeyResponse.fromJson(Map<String, dynamic> js)
    : pemData = "",
      super(
        Success: false,
        Path: "/",
        Method: "GET",
        ID: UUID_ZERO,
        Reason: "",
      ) {
    super.decode(js);

    final data = js['data'] as Map<String, dynamic>;
    pemData = data['pubKey'] ?? "";
  }

  @override
  Map<String, dynamic> encode() {
    final result = super.encode();

    result['data'] = {"pubKey": pemData};

    return result;
  }
}

class ServerVersionResponse extends BasicResponse {
  String product;
  String version;

  ServerVersionResponse({
    required this.product,
    required this.version,
    required super.Success,
    required super.Path,
    required super.Method,
    required super.ID,
    required super.Reason,
  });

  ServerVersionResponse.fromJson(Map<String, dynamic> js)
    : product = "",
      version = "",
      super(ID: "", Success: true, Method: "", Reason: "", Path: "") {
    super.decode(js);

    product = js['product'] as String;
    version = js['version'] as String;
  }

  @override
  Map<String, dynamic> encode() {
    var base = super.encode();
    base["data"] = {"product": product, "version": version};

    return base;
  }
}
