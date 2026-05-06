import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _isOnlineController =
      StreamController<bool>.broadcast();

  Stream<bool> get onlineStream => _isOnlineController.stream;
  bool _isOnline = false;
  bool get isOnline => _isOnline;

  ConnectivityService() {
    _connectivity.onConnectivityChanged.listen((results) {
      _isOnline = results.any((r) =>
          r != ConnectivityResult.none);
      _isOnlineController.add(_isOnline);
    });
    _checkInitial();
  }

  Future<void> _checkInitial() async {
    final results = await _connectivity.checkConnectivity();
    _isOnline = results.any((r) => r != ConnectivityResult.none);
    _isOnlineController.add(_isOnline);
  }

  void dispose() {
    _isOnlineController.close();
  }
}

final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  ref.onDispose(service.dispose);
  return service;
});

final isOnlineProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.onlineStream;
});
