enum UrlLink { isLive, isDev, isLocalServer }

enum ApiUrl { base, baseImage, products }

extension ApiUrlExtention on ApiUrl {
  static String _baseUrl = '';
  static String _baseImageUrl = '';

  static void setUrl(UrlLink urlLink) {
    switch (urlLink) {
      case UrlLink.isLive:
        _baseUrl = '';
        _baseImageUrl = '';
        break;
      case UrlLink.isDev:
        _baseUrl = '';
        _baseImageUrl = '';
        break;
      case UrlLink.isLocalServer:
        _baseUrl = '';
        break;
    }
  }

  String get url {
    switch (this) {
      case ApiUrl.base:
        return _baseUrl;
      case ApiUrl.baseImage:
        return _baseImageUrl;
      case ApiUrl.products:
        return "/products";
    }
  }
}

