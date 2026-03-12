import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/vpn_state.dart';
import '../services/locale_service.dart';
import '../services/premium_service.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});
  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  final _controller = TextEditingController();
  bool _loading = false;
  String? _error;
  bool _success = false;

  Future<void> _activate(LocaleService locale) async {
    final code = _controller.text.trim();
    if (code.isEmpty) { setState(() => _error = locale.enterCodeHint); return; }
    setState(() { _loading = true; _error = null; });
    final ok = await PremiumService.activateCode(code);
    setState(() => _loading = false);
    if (ok) {
      setState(() => _success = true);
      if (mounted) {
        context.read<VpnState>().setPremium(true);
        await Future.delayed(const Duration(milliseconds: 1200));
        if (mounted) Navigator.pop(context);
      }
    } else {
      setState(() => _error = locale.invalidCode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocaleService>(
      builder: (context, locale, _) {
        return Scaffold(
          backgroundColor: const Color(0xFF0D1B2A),
          appBar: AppBar(
            backgroundColor: const Color(0xFF0D1B2A),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(locale.vipTitle, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            centerTitle: true,
          ),
          body: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(children: [
              const SizedBox(height: 20),
              Container(
                width: 100, height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft, end: Alignment.bottomRight,
                    colors: [Color(0xFFFFCC00), Color(0xFFFF8800)],
                  ),
                  boxShadow: [BoxShadow(color: const Color(0xFFFFAA00).withOpacity(0.35), blurRadius: 35, spreadRadius: 5)],
                ),
                child: const Icon(Icons.workspace_premium, color: Colors.white, size: 52),
              ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
              const SizedBox(height: 28),
              Text(locale.vipTitle, style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold))
                .animate().fadeIn(delay: 100.ms),
              const SizedBox(height: 10),
              Text(locale.vipSubtitle, textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 14, height: 1.6))
                .animate().fadeIn(delay: 150.ms),
              const SizedBox(height: 32),
              ...[
                ('⚡', locale.fastServers),
                ('🌍', locale.allCountries),
                ('🔒', locale.advancedEncryption),
                ('♾️', locale.unlimited),
              ].asMap().entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(children: [
                  Container(
                    width: 42, height: 42,
                    decoration: BoxDecoration(color: const Color(0xFF1A2840), borderRadius: BorderRadius.circular(12)),
                    child: Center(child: Text(e.value.$1, style: const TextStyle(fontSize: 20))),
                  ),
                  const SizedBox(width: 14),
                  Text(e.value.$2, style: const TextStyle(color: Colors.white, fontSize: 14)),
                ]).animate().fadeIn(delay: ((e.key + 2) * 60).ms).slideX(begin: 0.1, end: 0),
              )),
              const SizedBox(height: 32),
              if (_success)
                Container(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: const Color(0xFF00FF88).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFF00FF88).withOpacity(0.4)),
                  ),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.check_circle_rounded, color: Color(0xFF00FF88), size: 28),
                    const SizedBox(width: 10),
                    Text(locale.vipActive, style: const TextStyle(color: Color(0xFF00FF88), fontWeight: FontWeight.bold, fontSize: 18)),
                  ]),
                ).animate().scale(duration: 400.ms, curve: Curves.elasticOut)
              else ...[
                TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  style: const TextStyle(color: Colors.white, fontSize: 22, letterSpacing: 4, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: '· · · · · · · · ·',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.2), fontSize: 20, letterSpacing: 4),
                    filled: true,
                    fillColor: const Color(0xFF1A2840),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: const BorderSide(color: Color(0xFFFFAA00), width: 2),
                    ),
                    errorText: _error,
                    errorStyle: const TextStyle(color: Color(0xFFFF4466), fontSize: 13),
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                  onSubmitted: (_) => _activate(locale),
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity, height: 56,
                  child: ElevatedButton(
                    onPressed: _loading ? null : () => _activate(locale),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFAA00),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _loading
                      ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                      : Text(locale.activate, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  ),
                ).animate().fadeIn(delay: 350.ms).slideY(begin: 0.2, end: 0),
              ],
            ]),
          ),
        );
      },
    );
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }
}
