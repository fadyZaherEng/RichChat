enum Flavor {
  development,
  production,
}

class F {
  static Flavor? appFlavor;

  static String get name => appFlavor?.name ?? '';

  static String get title {
    switch (appFlavor) {
      case Flavor.development:
        return 'City Eye Dev';
      case Flavor.production:
        return 'City Eye';
      default:
        return 'title';
    }
  }

}
