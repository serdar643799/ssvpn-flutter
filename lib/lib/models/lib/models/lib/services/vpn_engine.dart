import 'package:flutter/foundation.dart';
import 'package:flutter_v2ray/flutter_v2ray.dart';

class VpnEngine {
  static VpnEngine? _instance;
  static VpnEngine get instance => _instance ??= VpnEngine._();
  VpnEngine._();

  late FlutterV2ray _v2ray;
  bool _initialized = false;
  String _status = 'disconnected';
  Function(String)? onStatusChanged;

  Future<void> initialize() async {
    if (_initialized) return;
    _v2ray = FlutterV2ray(
      onStatusChanged: (status) {
        _status = status.state.toLowerCase();
        onStatusChanged?.call(_status);
      },
    );
    await _v2ray.initializeV2Ray();
    _initialized = true;
  }

  static String buildVlessRealityLink({
    required String ip,
    required int port,
    required String uuid,
    required String publicKey,
    required String shortId,
    String sni = 'www.amazon.com',
    String name = 'S.S VPN',
  }) {
    final params = {
      'encryption': 'none',
      'flow': 'xtls-rprx-vision',
      'security': 'reality',
      'sni': sni,
      'fp': 'chrome',
      'pbk': publicKey,
      'sid': shortId,
      'type': 'tcp',
      'headerType': 'none',
    };
    final query = params.entries.map((e) => '${e.key}=${Uri.encodeComponent(e.value)}').join('&');
    return 'vless://$uuid@$ip:$port?$query#${Uri.encodeComponent(name)}';
  }

  Future<bool> connect(String shareLink, {String remark = 'S.S VPN'}) async {
    await initialize();
    final hasPermission = await _v2ray.requestPermission();
    if (!hasPermission) return false;
    try {
      final parser = V2RayURL.parseFromURL(shareLink);
      await _v2ray.startV2Ray(
        remark: remark,
        config: parser.getFullConfiguration(),
        blockedApps: null,
        bypassSubnets: null,
        proxyOnly: false,
      );
      return true;
    } catch (e) {
      debugPrint('Bağlantı hatası: $e');
      return false;
    }
  }

  Future<void> disconnect() async {
    if (!_initialized) return;
    await _v2ray.stopV2Ray();
  }

  String get status => _status;
  bool get isConnected => _status == 'connected';
}
