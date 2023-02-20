import "dart:developer";

import "package:get/get.dart";
import "package:get/get_connect/connect.dart";
import "package:google_maps_integration/models/mock_codes_model.dart";

class NetworkService extends GetConnect {
  final String baseURL = "https://maps.googleapis.com/";

  Map<String, String> addAuthenticator() {
    final Map<String, String> headers = <String, String>{};
    return headers;
  }

  Map<String, String> addRequestModifier(Map<String, String> request) {
    return request;
  }

  void addResponseModifier() {}

  Future<dynamic> getRequest({
    required String point,
    required Map<String, dynamic> request,
    required void Function(Map<String, dynamic>) decodedResponse,
    required void Function(String) callbackHandle,
  }) async {
    Response<dynamic> response = const Response<dynamic>();
    try {
      response = await httpClient.get(
        baseURL + point,
        headers: addAuthenticator(),
        query: request,
        contentType: "application/json",
      );
    } on Exception catch (error) {
      callbackHandle("Exception: getRequest(): ${error.toString()}");
    }
    response.body != null
        ? await commonMock(
            response: response,
            decodedResponse: decodedResponse,
            callbackHandle: callbackHandle,
          )
        : callbackHandle("getRequest(): response.body: ${response.body}");
    return Future<dynamic>.value(response);
  }

  Future<void> commonMock({
    required Response<dynamic> response,
    required void Function(Map<String, dynamic>) decodedResponse,
    required void Function(String) callbackHandle,
  }) async {
    final MockCodesModel reason = await mockCodes(response.statusCode ?? 100);
    reason.statusCode.toString().startsWith("2")
        ? decodedResponse(response.body)
        : callbackHandle(
            mockMessage(reason),
          );
    return Future<void>.value();
  }

  Future<MockCodesModel> mockCodes(int code) async {
    MockCodesModel mockCodesModel = MockCodesModel();
    Response<dynamic> response = const Response<dynamic>();
    try {
      response = await httpClient.get("https://mock.codes/$code");
    } on Exception catch (error) {
      log("Exception: mockCodes(): ${error.toString()}");
    }
    response.body != null
        ? mockCodesModel = MockCodesModel.fromJson(response.body)
        : log("mockCodes(): response.body: ${response.body}");
    return Future<MockCodesModel>.value(mockCodesModel);
  }

  String mockMessage(MockCodesModel reason) {
    final String type = reason.statusCode.toString().startsWith("2")
        ? "type: 2×× Success\n"
        : reason.statusCode.toString().startsWith("3")
            ? "type: 3×× Redirection\n"
            : reason.statusCode.toString().startsWith("4")
                ? "type: 4×× Client Error\n"
                : reason.statusCode.toString().startsWith("5")
                    ? "type: 5×× Server Error\n"
                    : "Unknown Error\n";
    final String statusCode = "statusCode: ${reason.statusCode}\n";
    final String description = "description: ${reason.description}";
    return type + statusCode + description;
  }
}
