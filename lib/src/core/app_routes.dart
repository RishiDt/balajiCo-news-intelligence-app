// Centralized route names and generator
import 'package:flutter/material.dart';
import 'package:mini_news_intelligence/src/features/auth/ui/login_screen.dart';
import 'package:mini_news_intelligence/src/features/news/ui/article_detail_screen.dart';
import 'package:mini_news_intelligence/src/features/news/ui/favorites_screen.dart';
import 'package:mini_news_intelligence/src/features/news/ui/home_screen.dart';
import 'package:mini_news_intelligence/src/features/news/ui/search_screen.dart';
import 'package:mini_news_intelligence/src/data/models/article_model.dart';

class AppRoutes {
  static const String routeLogin = '/login';
  static const String routeHome = '/home';
  static const String routeArticleDetail = '/article_detail';
  static const String routeFavorites = '/favorites';
  static const String routeSearch = '/search';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case routeLogin:
        return MaterialPageRoute(builder: (_) => const LoginScreen());
      case routeHome:
        return MaterialPageRoute(builder: (_) => const HomeScreen());
      case routeArticleDetail:
        final args = settings.arguments;
        if (args is ArticleModel) {
          return MaterialPageRoute(
            builder: (_) => ArticleDetailScreen(article: args),
            settings: settings,
          );
        }
        return _errorRoute('Missing Article');
      case routeFavorites:
        return MaterialPageRoute(builder: (_) => const FavoritesScreen());
      case routeSearch:
        return MaterialPageRoute(builder: (_) => const SearchScreen());
      default:
        return _errorRoute('Route not found');
    }
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(child: Text(message)),
      ),
    );
  }
}
