import 'package:frtdb_chat/src/constants/string_constants.dart';

import 'dio_services.dart';

class ApiRepository {
  static late ApiClient apiClient;

  ApiRepository() {
    apiClient = ApiClient();
  }

  static Future<dynamic> sendNotification(String token, dynamic data) {
    return apiClient.post(ApiConstant.fNotificationApi, token, data);
  }
}