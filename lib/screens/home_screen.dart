import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/vpn_state.dart';
import '../services/locale_service.dart';
import 'server_list_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<VpnState, LocaleService>(
      builder: (context, vpn, locale, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF0D1B2A),
          body: SafeArea(
            child: Column(
              children: [
                _buildTopBar(context, vpn, locale),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _buildStatusCard(vpn, locale),
                        const SizedBox(height: 32),
                        _buildConnectButton(context, vpn, locale),
                        const SizedBox(height: 32),
                        if (vpn.isConnected) ...[
                          _buildStatsRow(vpn, locale),
                          const SizedBox(height: 24),
                        ],
                        _buildSelectedServer(context, vpn, locale),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopBar(BuildContext context, VpnState vpn, LocaleService locale) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(children: [
            Container(
              width: 36, height: 36,
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF00D4FF), Color(0xFF0066FF)]),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.bolt, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 10),
            const Text('S.S VPN', style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
          ]),
          Row(children: [
            if (vpn.isPremium)
              Container(
                margin: const EdgeInsets.only(right: 6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [Color(0xFFFFAA00), Color(0xFFFF6600)]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text('👑 VIP', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              ),
            GestureDetector(
              onTap: () => _showLanguagePicker(context, locale),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A2840),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(locale.currentFlag, style: const TextStyle(fontSize: 16)),
                  const SizedBox(width: 5),
                  Text(locale.currentName, style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                  const SizedBox(width: 3),
                  const Icon(Icons.arrow_drop_down, color: Colors.white38, size: 16),
                ]),
              ),
            ),
            IconButton(
              onPressed: () => vpn.loadServers(),
              icon: const Icon(Icons.refresh, color: Colors.white54, size: 22),
            ),
          ]),
        ],
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildStatusCard(VpnState vpn, LocaleService locale) {
    final isConnected = vpn.isConnected;
    final isConnecting = vpn.isConnecting;
    Color statusColor = isConnected ? const Color(0xFF00FF88) : isConnecting ? const Color(0xFFFFAA00) : const Color(0xFFFF4466);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2840),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(children: [
        Container(
          width: 48, height: 48,
          decoration: BoxDecoration(color: statusColor.withOpacity(0.15), borderRadius: BorderRadius.circular(14)),
          child: Icon(isConnected ? Icons.shield : Icons.shield_outlined, color: statusColor, size: 26),
        ),
        const SizedBox(width: 16),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(vpn.statusLabel(locale), style: TextStyle(color: statusColor, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(isConnected ? '${locale.ipLabel}: ${vpn.connectedIp}' : locale.notProtected,
            style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
        ])),
        if (isConnected)
          Text(vpn.durationString, style: const TextStyle(color: Color(0xFF00FF88), fontSize: 14, fontWeight: FontWeight.w600)),
      ]),
    ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1, end: 0);
  }

  Widget _buildConnectButton(BuildContext context, VpnState vpn, LocaleService locale) {
    final isConnected = vpn.isConnected;
    final isConnecting = vpn.isConnecting;
    Color activeColor = isConnected ? const Color(0xFF00FF88) : isConnecting ? const Color(0xFFFFAA00) : const Color(0xFF0066FF);
    return GestureDetector(
      onTap: () => vpn.connect(),
      child: Stack(alignment: Alignment.center, children: [
        Container(width: 185, height: 185, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: activeColor.withOpacity(0.2), width: 1))),
        Container(width: 155, height: 155, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: activeColor.withOpacity(0.35), width: 1.5))),
        Container(
          width: 120, height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: isConnected ? [const Color(0xFF00CC70), const Color(0xFF00FF88)]
                : isConnecting ? [const Color(0xFFFF8800), const Color(0xFFFFAA00)]
                : [const Color(0xFF1E3A5F), const Color(0xFF0066FF)],
            ),
            boxShadow: [BoxShadow(color: activeColor.withOpacity(0.35), blurRadius: 30, spreadRadius: 5)],
          ),
          child: isConnecting
            ? const Center(child: CircularProgressIndicator(color: Colors.white, strokeWidth: 3))
            : Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.power_settings_new, color: Colors.white, size: 36),
                const SizedBox(height: 6),
                Text(isConnected ? locale.disconnect : locale.connect,
                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
              ]),
        ),
      ]),
    ).animate().scale(begin: const Offset(0.9, 0.9), end: const Offset(1.0, 1.0), duration: 500.ms, curve: Curves.elasticOut);
  }

  Widget _buildStatsRow(VpnState vpn, LocaleService locale) {
    return Row(children: [
      Expanded(child: _statCard(locale.download, '${vpn.downloadSpeed.toStringAsFixed(1)} MB/s', const Color(0xFF00D4FF))),
      const SizedBox(width: 12),
      Expanded(child: _statCard(locale.upload, '${vpn.uploadSpeed.toStringAsFixed(1)} MB/s', const Color(0xFF00FF88))),
    ]).animate().fadeIn(duration: 400.ms);
  }

  Widget _statCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1A2840),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
        const SizedBox(height: 6),
        Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.bold)),
      ]),
    );
  }

  Widget _buildSelectedServer(BuildContext context, VpnState vpn, LocaleService locale) {
    if (vpn.isLoadingServers) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: const Color(0xFF1A2840), borderRadius: BorderRadius.circular(20)),
        child: const Center(child: CircularProgressIndicator(color: Color(0xFF0066FF))),
      );
    }
    final server = vpn.selectedServer;
    if (server == null) return const SizedBox();
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ServerListScreen())),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1A2840),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.08)),
        ),
        child: Row(children: [
          Text(server.flag, style: const TextStyle(fontSize: 32)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(server.country, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Text(server.city.isNotEmpty ? '${server.city}  •  ${server.pingLabel}' : server.pingLabel,
              style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 13)),
          ])),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1B2A),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Row(children: [
              Text(locale.change, style: const TextStyle(color: Colors.white70, fontSize: 13)),
              const SizedBox(width: 4),
              const Icon(Icons.chevron_right, color: Colors.white38, size: 18),
            ]),
          ),
        ]),
      ),
    ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1, end: 0);
  }

  void _showLanguagePicker(BuildContext context, LocaleService locale) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1A2840),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(2))),
            const SizedBox(height: 20),
            Text(locale.selectLanguage, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
            const SizedBox(height: 20),
            ...LocaleService.languages.map((lang) {
              final isSelected = locale.lang == lang['code'];
              return GestureDetector(
                onTap: () { locale.setLang(lang['code']!); Navigator.pop(context); },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFF0D3060) : const Color(0xFF0D1B2A),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: isSelected ? const Color(0xFF0066FF) : Colors.white.withOpacity(0.07), width: isSelected ? 1.5 : 1),
                  ),
                  child: Row(children: [
                    Text(lang['flag']!, style: const TextStyle(fontSize: 28)),
                    const SizedBox(width: 16),
                    Text(lang['code'] == 'en' ? 'English' : lang['code'] == 'ru' ? 'Русский' : 'Türkçe',
                      style: TextStyle(color: isSelected ? Colors.white : Colors.white70, fontSize: 16, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                    const Spacer(),
                    Text(lang['name']!, style: TextStyle(color: isSelected ? const Color(0xFF0066FF) : Colors.white38, fontSize: 13, fontWeight: FontWeight.w600)),
                    if (isSelected) ...[const SizedBox(width: 8), const Icon(Icons.check_circle, color: Color(0xFF0066FF), size: 20)],
                  ]),
                ),
              );
            }),
          ]),
        );
      },
    );
  }
}
