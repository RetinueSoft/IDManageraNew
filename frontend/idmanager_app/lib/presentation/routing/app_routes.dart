class AppRoutes {
  AppRoutes._();

  static const dashboard = '/';
  static const templates = '/templates';
  static const users = '/users';
  static const points = '/points';
  static const generateCard = '/cards/generate';
  static const auditLog = '/audit-log';

  static String templateNew() => '$templates/new';
  static String templateEdit(int id) => '$templates/$id';

  static const templateDesignPattern = '/templates/:templateId/design';
  static String templateDesign(int id) => '$templates/$id/design';

  static String userNew() => '$users/new';
  static String userEdit(int id) => '$users/$id';
}
