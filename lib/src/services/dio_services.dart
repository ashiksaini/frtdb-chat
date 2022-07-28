import 'dart:io';
import 'package:dio/adapter.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

class ApiClient {
  late Dio _dio;

  /// POST...
  Future<dynamic> post(String url, String token, dynamic data) async {
    _dio = getDio(false, token);

    try {
      Response _response = await _dio.post(url, data: data);
      if (_response.statusCode == 200 || _response.data != null) {
        // onSuccess
        return _response;
      } else {
        // onFailure
        throw 'Something went wrong';
      }
    } on DioError catch(error) {
      if(error.type == DioErrorType.connectTimeout) {
        throw 'Connection Timeout';
      } else if(error.type == DioErrorType.receiveTimeout) {
        throw 'Receive Timeout';
      }
    }
  }

  /// Dio Settings...
  Dio getDio(bool formUrlEncodedContent, String? token) {
    BaseOptions options = BaseOptions(
      connectTimeout: 1000 * 120,
      receiveTimeout: 12000,
    );
    _dio = Dio(options);
    if (!kReleaseMode) _dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
    (_dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (HttpClient client) {
      client.badCertificateCallback = (X509Certificate cert, String host, int port) => true;
    };

    if (formUrlEncodedContent) {}

    _dio.options.headers = {"Authorization": token};
    return _dio;
  }
}
