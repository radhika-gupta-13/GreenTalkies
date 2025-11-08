enum Environment {
  dev,     // Local
  ngrok,   // Temporary public
  prod,    // Hosted
}

class RuntimeConfig {
  Environment _environment = Environment.dev;

  // Singleton pattern
  static final RuntimeConfig _instance = RuntimeConfig._internal();
  factory RuntimeConfig() => _instance;
  RuntimeConfig._internal();

  // Get current backend URL
  String get backendUrl {
    switch (_environment) {
      case Environment.dev:
        return "http://192.168.0.xxx:3000"; // Local backend
      case Environment.ngrok:
        return "https://abcd1234.ngrok.io"; // Ngrok URL
      case Environment.prod:
        return "https://greentalkies-backend.up.railway.app"; // Hosted
    }
  }

  // Change environment dynamically
  void setEnvironment(Environment env) {
    _environment = env;
  }

  Environment get environment => _environment;
}

class AppConfig {
  // Toggle this to false for local dev, true for production APK
  static const bool isProduction = true;

  // Backend URL
  static String get backendUrl {
    if (isProduction) {
      return "https://your-production-backend.com"; // <-- replace with your hosted server
    } else {
      return "http://10.0.2.2:4000"; // Local dev/emulator
    }
  }
}
