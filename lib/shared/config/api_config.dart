class ApiConfig {
  // Thay đổi địa chỉ này thành địa chỉ backend của bạn
  static const String baseUrl = 'http://192.168.1.6:8080';

  // API endpoints
  static const String auth = '/auth';
  static const String services = '/services';
  static const String stylists = '/stylists';
  static const String appointments = '/appointments';
  static const String categories = '/categories';
  static const String products = '/products';
  static const String ratings = '/ratings';
  static const String notifications = '/notifications';
  static const String workingHours = '/working-hours';
  static const String availability = '/availability';
  static const String users = '/users';
  static const String stylistSchedules = '/stylist-schedules';
  static const String payments = '/payments';

  // Helper method to get full URL
  static String getUrl(String endpoint) {
    return baseUrl + endpoint;
  }
}
