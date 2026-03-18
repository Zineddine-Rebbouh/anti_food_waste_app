import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, {this.statusCode});

  factory ApiException.fromDioException(DioException error) {
    if (error.type == DioExceptionType.connectionTimeout || 
        error.type == DioExceptionType.receiveTimeout || 
        error.type == DioExceptionType.sendTimeout) {
      return ApiException('Connection timed out. Please check your internet connection and try again.');
    }
    
    if (error.type == DioExceptionType.connectionError) {
      return ApiException('Network error. Please make sure you are connected to the internet.');
    }

    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;
      
      String parsedMessage = 'An unexpected error occurred.';
      
      if (data != null && data is Map<String, dynamic>) {
        if (data.containsKey('detail')) {
          parsedMessage = data['detail'];
        } else if (data.containsKey('message')) {
          parsedMessage = data['message'];
        } else if (data.containsKey('error')) {
          parsedMessage = data['error'];
        } else if (data.containsKey('non_field_errors') && data['non_field_errors'] is List) {
          parsedMessage = data['non_field_errors'][0].toString();
        } else if (data.isNotEmpty) {
          // Field error mapping from Django e.g { "email": ["This field must be unique."] }
          final firstKey = data.keys.first;
          final firstError = data[firstKey];
          if (firstError is List && firstError.isNotEmpty) {
            final val = firstError[0].toString();
            parsedMessage = "$firstKey: $val";
          } else if (firstError is String) {
            parsedMessage = "$firstKey: $firstError";
          }
        }
      } else if (data is String) {
         parsedMessage = data;
      }
      
      if (statusCode == 401) {
         parsedMessage = 'Session expired or unauthorised. Please log in again.';
      } else if (statusCode == 403) {
         parsedMessage = 'You do not have permission to perform this action.';
      } else if (statusCode == 404) {
         parsedMessage = 'The requested resource was not found.';
      } else if (statusCode != null && statusCode >= 500) {
         parsedMessage = 'Internal server error. Please try again later.';
      }

      return ApiException(parsedMessage, statusCode: statusCode);
    }
    
    return ApiException(error.message ?? 'An unknown network error occurred.');
  }

  @override
  String toString() => message;
}
