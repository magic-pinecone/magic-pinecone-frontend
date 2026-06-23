abstract class BackendUrlConfig {
  bool setBaseUrl(String url);

  void reset();
}

abstract class ThemePreferenceConfig {
  void toggle();

  void setDarkMode(bool enabled);
}
