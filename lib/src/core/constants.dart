// App-wide constants
class HiveBoxes {
  static const String favorites = 'favorites';
  static const String auth = 'auth';
  static const String cache = 'cache';
}

const String API_BASE_URL = String.fromEnvironment('API_BASE_URL',
    defaultValue: 'https://newsapi.org/v2');
const String API_KEY = String.fromEnvironment('API_KEY',
    defaultValue: 'f82657eeca52433faace45c79d906918');
const int DEFAULT_PAGE_SIZE = 20;
const Duration NETWORK_TIMEOUT = Duration(seconds: 15);

const List<String> SUPPORTED_CATEGORIES = [
  'business',
  'entertainment',
  'general',
  'health',
  'science',
  'sports',
  'technology',
];

const String FALLBACK_IMAGE =
    'https://images.unsplash.com/photo-1504711434969-e33886168f5c?auto=format&fit=crop&w=800&q=60';
