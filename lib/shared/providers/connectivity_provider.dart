import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'connectivity_provider.g.dart';

@Riverpod(keepAlive: true)
Stream<ConnectivityResult> connectivity(Ref ref) {
  return Connectivity().onConnectivityChanged.map((results) =>
      results.isNotEmpty ? results.first : ConnectivityResult.none);
}

@Riverpod(keepAlive: true)
bool isOnline(Ref ref) {
  final result = ref.watch(connectivityProvider).value;
  return result != null && result != ConnectivityResult.none;
}
