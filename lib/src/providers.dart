// Barrel file exporting commonly used providers and wiring dependencies
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:mini_news_intelligence/src/core/network/http_client.dart';
import 'package:mini_news_intelligence/src/shared/services/connectivity_service.dart';

final httpClientProvider = Provider<HttpClient>((ref) {
  return HttpClient(client: http.Client());
});

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  return connectivityService;
});
