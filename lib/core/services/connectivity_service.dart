import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Centralized service to monitor network connectivity across the application.
class ConnectivityService {
  final Connectivity _connectivity;
  final StreamController<bool> _isOnlineController = StreamController<bool>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isOnline = true;

  ConnectivityService([Connectivity? connectivity])
      : _connectivity = connectivity ?? Connectivity() {
    _init();
  }

  bool get isOnline => _isOnline;
  Stream<bool> get isOnlineStream => _isOnlineController.stream;

  void _init() {
    _checkInitialConnectivity();
    _subscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  Future<void> _checkInitialConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      _updateConnectionStatus(results);
    } catch (e) {
      debugPrint('Connectivity check failed: $e');
      _isOnline = true;
      _isOnlineController.add(true);
    }
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final hasConnection = results.any((r) =>
        r == ConnectivityResult.mobile ||
        r == ConnectivityResult.wifi ||
        r == ConnectivityResult.ethernet ||
        r == ConnectivityResult.vpn ||
        r == ConnectivityResult.other);

    if (_isOnline != hasConnection) {
      _isOnline = hasConnection;
      _isOnlineController.add(_isOnline);
      debugPrint('Network connectivity changed: isOnline = $_isOnline');
    }
  }

  void dispose() {
    _subscription?.cancel();
    _isOnlineController.close();
  }
}

/// Global provider for the ConnectivityService
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Stream provider for live online/offline state
final isOnlineStreamProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.isOnlineStream;
});

/// Direct boolean provider for current connectivity state
final isOnlineProvider = StateNotifierProvider<IsOnlineNotifier, bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return IsOnlineNotifier(service);
});

class IsOnlineNotifier extends StateNotifier<bool> {
  final ConnectivityService _service;
  StreamSubscription<bool>? _sub;

  IsOnlineNotifier(this._service) : super(_service.isOnline) {
    _sub = _service.isOnlineStream.listen((status) {
      state = status;
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
