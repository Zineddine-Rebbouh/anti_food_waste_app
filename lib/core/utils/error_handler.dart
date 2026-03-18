import 'package:dio/dio.dart';
import 'package:anti_food_waste_app/core/network/api_exceptions.dart';

class AppErrorHandler {
  static String getMessage(dynamic error) {
    if (error is ApiException) {
      return error.message;
    } else if (error is DioException) {
      final apiException = ApiException.fromDioException(error);
      return apiException.message;
    } else if (error is Exception) {
      return error.toString().replaceAll('Exception: ', '');
    }
    return 'An unexpected error occurred. Please try again.';
  }
}
