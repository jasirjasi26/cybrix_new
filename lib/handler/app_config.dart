import 'package:shared_preferences/shared_preferences.dart';

class AppConfig {



  static const bool HTTPS = false;

  //configure this
  static String DOMAIN_PATH = "";


  static getApi() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.getString("api");
    DOMAIN_PATH=prefs.getString("api");
  }

  static setApi(String api) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("api",api);
    DOMAIN_PATH=prefs.getString("api");
  }
  //do not configure these below
  // static const String API_ENDPATH = "api/";
  // static const String PUBLIC_FOLDER = "public";
  // static const String PROTOCOL = HTTPS ? "https://" : "https://";
  // static const String RAW_BASE_URL = "${PROTOCOL}${DOMAIN_PATH}";
  // static const String BASE_URL = "${RAW_BASE_URL}/${API_ENDPATH}";

}
