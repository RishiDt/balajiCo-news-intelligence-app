// Entry point for Mini News Intelligence App
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:mini_news_intelligence/src/core/app_routes.dart';
import 'package:mini_news_intelligence/src/core/constants.dart';
import 'package:mini_news_intelligence/src/core/theme.dart';
import 'package:mini_news_intelligence/src/data/models/article_model.dart';
import 'package:mini_news_intelligence/src/data/models/user_model.dart';
import 'package:mini_news_intelligence/src/providers.dart';
import 'package:mini_news_intelligence/src/config/logger.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();
  // Register adapters (manual adapters are implemented in models)
  Hive.registerAdapter(ArticleModelAdapter());
  Hive.registerAdapter(UserModelAdapter());

  // Open boxes
  await Hive.openBox<ArticleModel>(HiveBoxes.favorites);
  await Hive.openBox<Map>(HiveBoxes.cache);
  await Hive.openBox<UserModel>(HiveBoxes.auth);

  // Run guarded zone to capture errors
  FlutterError.onError = (details) {
    Logger.error('FlutterError', details.exceptionAsString());
    FlutterError.dumpErrorToConsole(details);
  };

  runZonedGuarded(() {
    runApp(const ProviderScope(child: MyApp()));
  }, (error, stack) {
    Logger.error('Zoned Error', error.toString());
  });
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  bool _initialized = false;
  bool _isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _initAuthState();
  }

  Future<void> _initAuthState() async {
    try {
      final authBox = Hive.box<UserModel>(HiveBoxes.auth);
      final user = authBox.get('user');
      setState(() {
        _isAuthenticated = user != null;
        _initialized = true;
      });
    } catch (e, st) {
      Logger.error('Auth init failed', e.toString());
      setState(() {
        _initialized = true;
        _isAuthenticated = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_initialized) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const Scaffold(
          body: Center(child: CircularProgressIndicator()),
        ),
      );
    }

    return ProviderScope(
      overrides: [],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Mini News Intelligence',
        theme: AppTheme.lightTheme,
        navigatorKey: _navigatorKey,
        initialRoute: _isAuthenticated ? AppRoutes.routeHome : AppRoutes.routeLogin,
        onGenerateRoute: AppRoutes.generateRoute,
      ),
    );
  }
}
