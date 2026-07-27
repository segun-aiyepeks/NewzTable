import 'package:dio/dio.dart';
import 'package:newztable/core/constants/app_constants.dart';

class ApiClient {
  ApiClient._();

  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: AppConstants.baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      }
    )
  )..interceptors.addAll([
    _LoggingInterceptor(),
    _ErrorInterceptor()
  ]);

  static String? _deviceId;

  static void setDeviceId(String deviceId) {
    _deviceId = deviceId;
    _dio.options.headers['X-Device-Id'] = deviceId;
  }

  static Future<Response> get(
    String endpoint, {
      Map<String, dynamic>? queryParameters
    }) async {
      return await _dio.get(
        endpoint,
        queryParameters: queryParameters
      );
    }

  static Future<Response> post(
    String endpoint, {
      Map<String, dynamic>? data
    }) async {
      return await _dio.post(endpoint, data: data);
  }

  static Future<Response> put(
    String endpoint, {
      Map<String, dynamic>? data
    }) async {
      return await _dio.put(endpoint, data: data);
  }

  static Future<Response> delete(String endpoint) async {
    return await _dio.delete(endpoint);
  }
}

class _LoggingInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    print('[api] ${options.method} ${options.path}');
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response<dynamic> response, ResponseInterceptorHandler handler) {
    print('[api] ${response.statusCode} ${response.requestOptions.path}');
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    print('[api] error ${err.response?.statusCode} ${err.requestOptions.path}');
    super.onError(err, handler);
  }
}

class _ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    String message;

    switch (err.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timed out. Please check your internet.';
        break;
      case DioExceptionType.connectionError:
        message = 'Could not reach the server. Please try again.';
        break;
      case DioExceptionType.badResponse:
        final statusCode = err.response?.statusCode;
        if(statusCode == 401) {
          message = 'Unauthorized request.';
        } else if (statusCode == 404) {
          message = 'Resource not found';
        } else if (statusCode == 500) {
          message = 'Server error. Please try again later.';
        } else {
          message = 'Something went wrong.';
        }
      break;
    default:
      message = 'An unexpected error occured.';
    }

    handler.next(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: message
      )
    );
  }
}