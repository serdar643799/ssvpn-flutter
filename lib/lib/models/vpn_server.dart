import 'dart:convert';
import '../services/vpn_engine.dart';

class VpnServer {
  final String id;
  final String country;
  final String city;
  final String countryCode;
  final String flag;
  final String ip;
  final int port;
  final String method;
  final String password;
  final String protocol;
  final bool isPremium;
  int ping;
  bool online;
  final String? uuid;
  final String? publicKey;
  final String? shortId;
  final String? sni;

  VpnServer({
    required this.id,
    required this.country,
    this.city = '',
    required this.countryCode,
    required this.flag,
    required this.ip,
    required this.port,
    this.method = 'chacha20-ietf-poly1305',
    this.password = '',
    this.protocol = 'ss',
    this.isPremium = false,
    this.ping = -1,
    this.online = true,
    this.uuid,
    this.publicKey,
    this.shortId,
    this.sni,
  });

  factory VpnServer.fromJson(Map<String, dynamic> j) => VpnServer(
        id: j['id'] ?? '',
        country: j['country'] ?? '',
        city: j['city'] ?? '',
        countryCode: j['country_code'] ?? '',
        flag: j['flag'] ?? '🌐',
        ip: j['ip'] ?? '',
        port: j['port'] ?? 443,
        method: j['method'] ?? 'chacha20-ietf-poly1305',
        password: j['password'] ?? '',
        protocol: j['protocol'] ?? 'ss',
        isPremium: j['is_premium'] ?? false,
        ping: j['ping'] ?? -1,
        online: j['online'] ?? true,
        uuid: j['uuid'],
        publicKey: j['public_key'],
        shortId: j['short_id'],
        sni: j['sni'] ?? 'www.amazon.com',
      );

  String? get vlessLink {
    if (protocol != 'vless' || uuid == null || publicKey == null || shortId == null) return null;
    return VpnEngine.buildVlessRealityLink(
      ip: ip, port: port, uuid: uuid!,
      publicKey: publicKey!, shortId: shortId!,
      sni: sni ?? 'www.amazon.com',
      name: '$country - S.S VPN',
    );
  }

  String toSsLink() {
    final userinfo = '$method:$password';
    final encoded = base64Url.encode(utf8.encode(userinfo)).replaceAll('=', '');
    return 'ss://$encoded@$ip:$port#$country';
  }

  String get pingLabel {
    if (ping < 0) return '-- ms';
    if (ping < 80) return '$ping ms ⚡';
    if (ping < 150) return '$ping ms';
    return '$ping ms';
  }

  static List<VpnServer> fallbackServers = [
    VpnServer(id: 'f1', country: 'United States', city: 'New York', countryCode: 'US', flag: '🇺🇸', ip: '0.0.0.0', port: 443, protocol: 'vless', ping: 85),
    VpnServer(id: 'f2', country: 'Germany', city: 'Frankfurt', countryCode: 'DE', flag: '🇩🇪', ip: '0.0.0.0', port: 443, protocol: 'vless', ping: 55),
  ];
}
