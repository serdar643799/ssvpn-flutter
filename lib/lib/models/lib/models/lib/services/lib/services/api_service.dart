import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/vpn_server.dart';

class ApiService {
  static const String baseUrl =
      'https://ssvpn-backend-production.up.railway.app/api';

  static Future<List<VpnServer>> fetchServers() async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/servers'))
          .timeout(const Duration(seconds: 10));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List servers = data['servers'] ?? [];
        return servers.map((s) => VpnServer.fromJson(s)).toList();
      }
    } catch (e) {
      debugPrint('API hatası: $e');
    }
    return VpnServer.fallbackServers;
  }
}
