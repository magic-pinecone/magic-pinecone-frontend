const courseSharePath = '/magic-pinecone-lite';
const _productionShareOrigin = 'https://magic-pinecone.github.io';

Uri buildCourseShareUrl({required Uri baseUri, required String code}) {
  final shareBaseUri = _isLocalDevelopmentUri(baseUri)
      ? Uri.parse(_productionShareOrigin)
      : baseUri;

  return shareBaseUri.replace(
    path: courseSharePath,
    queryParameters: {'c': code},
    fragment: '',
  );
}

bool _isLocalDevelopmentUri(Uri uri) {
  return uri.host == 'localhost' ||
      uri.host == '127.0.0.1' ||
      uri.host == '::1' ||
      uri.host.isEmpty;
}

Uri removeCourseShareCode(Uri uri) {
  if (!uri.queryParameters.containsKey('c')) return uri;

  final queryParameters = Map<String, String>.from(uri.queryParameters)
    ..remove('c');

  return Uri(
    scheme: uri.scheme,
    userInfo: uri.userInfo,
    host: uri.host,
    port: uri.hasPort ? uri.port : null,
    path: uri.path,
    queryParameters: queryParameters.isEmpty ? null : queryParameters,
    fragment: uri.fragment,
  );
}
