// Connectivity service using connectivity_plus
import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  Future<bool> isConnected() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Stream<ConnectivityResult> get onConnectivityChanged =>
      _connectivity.onConnectivityChanged.map((results) =>
          results.isNotEmpty ? results.first : ConnectivityResult.none);
}

final connectivityService = ConnectivityService();

final connectivityProvider = StreamProvider<ConnectivityResult>((ref) {
  return connectivityService.onConnectivityChanged;
});
