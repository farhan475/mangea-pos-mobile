class ApiConstants {
  ApiConstants._();

  // Base URL - sesuaikan dengan backend Go Anda
  // 10.0.2.2 untuk Android Emulator, 192.168.1.12 untuk device fisik/web
  static const String baseUrl = 'http://192.168.1.12:8080/api/v1';

  // Endpoints
  static const String categories = '/categories';
  static const String products = '/products';
  static const String orders = '/orders';
  static const String tables = '/tables';
  static const String sync = '/sync';
  static const String activityLogs = '/activity-logs';
  static const String dashboard = '/dashboard';
  static const String auth = '/auth';
  static const String users = '/users';
  static const String reports = '/reports';
  static const String stock = '/stock';

  // Timeouts
  static const Duration connectTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}
