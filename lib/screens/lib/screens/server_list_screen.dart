import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/vpn_state.dart';
import '../models/vpn_server.dart';
import '../services/locale_service.dart';
import 'premium_screen.dart';

class ServerListScreen extends StatelessWidget {
  const ServerListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<VpnState, LocaleService>(
      builder: (context, vpn, locale, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF0D1B2A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0D1B2A),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(locale.servers, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
            centerTitle: true,
            actions: [
              IconButton(icon: const Icon(Icons.refresh, color: Colors.white54), onPressed: () => vpn.loadServers()),
            ],
          ),
          body: vpn.isLoadingServers
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF0066FF)))
            : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                children: [
                  _buildAutoServer(context, vpn, locale),
                  const SizedBox(height: 24),
                  if (vpn.freeServers.isNotEmpty) ...[
                    _sectionTitle(locale.freeServers, vpn.freeServers.length),
                    const SizedBox(height: 10),
                    ...vpn.freeServers.asMap().entries.map((e) =>
                      _buildTile(context, vpn, e.value)
                        .animate().fadeIn(delay: (e.key * 50).ms).slideX(begin: 0.1, end: 0)),
                    const SizedBox(height: 24),
                  ],
                  if (vpn.premiumServers.isNotEmpty) ...[
                    _buildVipHeader(context, vpn, locale),
                    const SizedBox(height: 10),
                    ...vpn.premiumServers.asMap().entries.map((e) =>
                      _buildTile(context, vpn, e.value, locked: !vpn.isPremium)
                        .animate().fadeIn(delay: (e.key * 50).ms).slideX(begin: 0.1, end: 0)),
                  ],
                  const SizedBox(height: 30),
                ],
              ),
        );
      },
    );
  }

  Widget _sectionTitle(String title, int count) {
    return Row(children: [
      Text(title, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Text('$count', style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ),
    ]);
  }

  Widget _buildVipHeader(BuildContext context, VpnState vpn, LocaleService locale) {
    return Row(children: [
      Text(locale.vipServers, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
      const SizedBox(width: 8),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
        decoration: BoxDecoration(color: Colors.white.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
        child: Text('${vpn.premiumServers.length}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
      ),
      const Spacer(),
      if (!vpn.isPremium)
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen())),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFFFFAA00), Color(0xFFFF6600)]),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(locale.enterCode, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        )
      else
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: const Color(0xFF00FF88).withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.3)),
          ),
          child: const Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.check_circle, color: Color(0xFF00FF88), size: 14),
            SizedBox(width: 4),
            Text('VIP', style: TextStyle(color: Color(0xFF00FF88), fontSize: 12, fontWeight: FontWeight.bold)),
          ]),
        ),
    ]);
  }

  Widget _buildAutoServer(BuildContext context, VpnState vpn, LocaleService locale) {
    return GestureDetector(
      onTap: () {
        final free = vpn.freeServers;
        if (free.isNotEmpty) {
          final best = free.reduce((a, b) =>
            (a.ping > 0 ? a.ping : 9999) < (b.ping > 0 ? b.ping : 9999) ? a : b);
          vpn.selectServer(best);
          Navigator.pop(context);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [Color(0xFF0044CC), Color(0xFF0066FF)]),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(children: [
          const Text('⚡', style: TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(locale.autoSelect, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(locale.autoSelectSub, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ])),
          const Icon(Icons.auto_fix_high, color: Colors.white70),
        ]),
      ),
    );
  }

  Widget _buildTile(BuildContext context, VpnState vpn, VpnServer server, {bool locked = false}) {
    final isSelected = vpn.selectedServer?.id == server.id;
    return GestureDetector(
      onTap: () {
        if (locked) {
          Navigator.push(context, MaterialPageRoute(builder: (_) => const PremiumScreen()));
          return;
        }
        vpn.selectServer(server);
        Navigator.pop(context);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF0D3060) : const Color(0xFF1A2840),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? const Color(0xFF0066FF) : Colors.white.withOpacity(0.07),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          locked
            ? Stack(children: [
                Text(server.flag, style: TextStyle(fontSize: 28, color: Colors.white.withOpacity(0.3))),
                const Positioned(right: 0, bottom: 0, child: Icon(Icons.lock, color: Color(0xFFFFAA00), size: 14)),
              ])
            : Text(server.flag, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(server.country, style: TextStyle(color: locked ? Colors.white38 : Colors.white, fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 4),
            Row(children: [
              Container(
                width: 6, height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: locked ? Colors.grey.withOpacity(0.3)
                    : server.ping < 80 ? const Color(0xFF00FF88)
                    : server.ping < 150 ? const Color(0xFFFFAA00)
                    : const Color(0xFFFF4466),
                ),
              ),
              const SizedBox(width: 6),
              Text(server.city.isNotEmpty ? '${server.city}  •  ${server.pingLabel}' : server.pingLabel,
                style: TextStyle(color: locked ? Colors.white24 : Colors.white.withOpacity(0.5), fontSize: 12)),
            ]),
          ])),
          if (locked)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFFFFAA00).withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: const Color(0xFFFFAA00).withOpacity(0.3)),
              ),
              child: const Text('VIP', style: TextStyle(color: Color(0xFFFFAA00), fontSize: 11, fontWeight: FontWeight.bold)),
            )
          else if (isSelected)
            const Icon(Icons.check_circle, color: Color(0xFF0066FF), size: 22),
        ]),
      ),
    );
