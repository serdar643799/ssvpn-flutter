import 'package:flutter/foundation.dart';
import 'vpn_server.dart';
import '../services/api_service.dart';
import '../services/premium_service.dart';
import '../services/vpn_engine.dart';

enum VpnStatus { disconnected, connecting, connected, disconnecting }

class VpnState extends ChangeNotifier {
  VpnStatus _status = VpnStatus.disconnected;
  VpnServer? _selectedServer;
  VpnServer? _connectedServer;
  String _connectedIp = '';
  Duration _connectedDuration = Duration.zero;
  double _downloadSpeed = 0;
  double _uploadSpeed = 0;
  List<VpnServer> _servers = [];
  DateTime? _connectTime;
  bool _isLoadingServers = false;
  bool _isPremium = false;

  VpnStatus get status => _status;
  VpnServer? get selectedServer => _selectedServer;
  VpnServer? get connectedServer => _connectedServer;
  String get connectedIp => _connectedIp;
  Duration get connectedDuration => _connectedDuration;
  double get downloadSpeed => _downloadSpeed;
  double get uploadSpeed => _uploadSpeed;
  List<VpnServer> get servers => _servers;
  bool get isLoadingServers => _isLoadingServers;
  bool get isConnected => _status == VpnStatus.connected;
  bool get isConnecting => _status == VpnStatus.connecting;
  bool get isPremium => _isPremium;
  String get durationString => _fmt(_connectedDuration);
  List<VpnServer> get freeServers => _servers.where((s) => !s.isPremium).toList();
  List<VpnServer> get premiumServers => _servers.where((s) => s.isPremium).toList();

  VpnState() {
    _init();
    VpnEngine.instance.onStatusChanged = (status) {
      if (status == 'connected') {
        _status = VpnStatus.connected;
        _connectTime = DateTime.now();
        _startStats();
      } else if (status == 'disconnected' || status == 'stopped') {
        _status = VpnStatus.disconnected;
        _connectedServer = null;
        _downloadSpeed = 0;
        _uploadSpeed = 0;
        _connectTime = null;
        _connectedDuration = Duration.zero;
      }
      notifyListeners();
    };
  }

  Future<void> _init() async {
    _isPremium = await PremiumService.isPremium();
    await VpnEngine.instance.initialize();
    await loadServers();
  }

  void setPremium(bool value) {
    _isPremium = value;
    notifyListeners();
  }

  Future<void> loadServers() async {
    _isLoadingServers = true;
    notifyListeners();
    _servers = await ApiService.fetchServers();
    if (_servers.isNotEmpty && _selectedServer == null) {
      final free = freeServers;
      _selectedServer = free.isNotEmpty ? free.first : _servers.first;
    }
    _isLoadingServers = false;
    notifyListeners();
  }

  void selectServer(VpnServer server) {
    _selectedServer = server;
    notifyListeners();
  }

  Future<void> connect() async {
    if (_status == VpnStatus.connected || _status == VpnStatus.connecting) {
      await disconnect();
      return;
    }
    final server = _selectedServer ?? (_servers.isNotEmpty ? _servers.first : null);
    if (server == null) return;
    _status = VpnStatus.connecting;
    _connectedServer = server;
    _connectedIp = server.ip;
    notifyListeners();
    final link = server.vlessLink ?? server.toSsLink();
    final ok = await VpnEngine.instance.connect(link, remark: server.country);
    if (!ok) {
      _status = VpnStatus.disconnected;
      notifyListeners();
    }
  }

  Future<void> disconnect() async {
    _status = VpnStatus.disconnecting;
    notifyListeners();
    await VpnEngine.instance.disconnect();
  }

  void _startStats() async {
    while (_status == VpnStatus.connected) {
      await Future.delayed(const Duration(seconds: 1));
      if (_status != VpnStatus.connected) break;
      if (_connectTime != null) _connectedDuration = DateTime.now().difference(_connectTime!);
      _downloadSpeed = 1.5 + (DateTime.now().millisecond % 60) * 0.08;
      _uploadSpeed = 0.3 + (DateTime.now().millisecond % 25) * 0.04;
      notifyListeners();
    }
  }

  String _fmt(Duration d) {
    final h = d.inHours.toString().padLeft(2, '0');
    final m = (d.inMinutes % 60).toString().padLeft(2, '0');
    final s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }

  String statusLabel(dynamic locale) {
    switch (_status) {
      case VpnStatus.disconnected: return locale.notConnected;
      case VpnStatus.connecting: return locale.connecting;
      case VpnStatus.connected: return locale.connected;
      case VpnStatus.disconnecting: return locale.disconnecting;
    }
  }
}
