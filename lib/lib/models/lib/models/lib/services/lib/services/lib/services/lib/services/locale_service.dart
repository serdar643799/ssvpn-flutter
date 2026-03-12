import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocaleService extends ChangeNotifier {
  static const String _key = 'language';
  String _lang = 'en';

  String get lang => _lang;
  bool get isEnglish => _lang == 'en';
  bool get isRussian => _lang == 'ru';
  bool get isTurkish => _lang == 'tr';

  static const List<Map<String, String>> languages = [
    {'code': 'en', 'flag': '🇬🇧', 'name': 'EN'},
    {'code': 'ru', 'flag': '🇷🇺', 'name': 'RU'},
    {'code': 'tr', 'flag': '🇹🇷', 'name': 'TR'},
  ];

  LocaleService() { _load(); }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    _lang = prefs.getString(_key) ?? 'en';
    notifyListeners();
  }

  Future<void> setLang(String lang) async {
    _lang = lang;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, lang);
    notifyListeners();
  }

  String get currentFlag =>
      languages.firstWhere((l) => l['code'] == _lang)['flag']!;

  String get currentName =>
      languages.firstWhere((l) => l['code'] == _lang)['name']!;

  String get appName => 'S.S VPN';

  String get connect {
    if (isEnglish) return 'CONNECT';
    if (isRussian) return 'ПОДКЛЮЧИТЬ';
    return 'BAĞLAN';
  }

  String get disconnect {
    if (isEnglish) return 'DISCONNECT';
    if (isRussian) return 'ОТКЛЮЧИТЬ';
    return 'KES';
  }

  String get connecting {
    if (isEnglish) return 'Connecting...';
    if (isRussian) return 'Подключение...';
    return 'Bağlanıyor...';
  }

  String get disconnecting {
    if (isEnglish) return 'Disconnecting...';
    if (isRussian) return 'Отключение...';
    return 'Kesiliyor...';
  }

  String get connected {
    if (isEnglish) return 'Connected';
    if (isRussian) return 'Подключено';
    return 'Bağlandı';
  }

  String get notConnected {
    if (isEnglish) return 'Not Connected';
    if (isRussian) return 'Не подключено';
    return 'Bağlı Değil';
  }

  String get notProtected {
    if (isEnglish) return 'Your connection is unprotected';
    if (isRussian) return 'Соединение не защищено';
    return 'Bağlantınız korunmuyor';
  }

  String get servers {
    if (isEnglish) return 'Servers';
    if (isRussian) return 'Серверы';
    return 'Sunucular';
  }

  String get autoSelect {
    if (isEnglish) return 'Auto Select';
    if (isRussian) return 'Авто выбор';
    return 'Otomatik Seç';
  }

  String get autoSelectSub {
    if (isEnglish) return 'Connect to fastest server';
    if (isRussian) return 'Подключиться к быстрому серверу';
    return 'En hızlı sunucuya bağlan';
  }

  String get freeServers {
    if (isEnglish) return '🆓 Free';
    if (isRussian) return '🆓 Бесплатно';
    return '🆓 Ücretsiz';
  }

  String get vipServers => '👑 VIP';

  String get change {
    if (isEnglish) return 'Change';
    if (isRussian) return 'Изменить';
    return 'Değiştir';
  }

  String get download {
    if (isEnglish) return '↓ Download';
    if (isRussian) return '↓ Загрузка';
    return '↓ İndirme';
  }

  String get upload {
    if (isEnglish) return '↑ Upload';
    if (isRussian) return '↑ Отдача';
    return '↑ Yükleme';
  }

  String get vipTitle {
    if (isEnglish) return 'VIP Membership';
    if (isRussian) return 'VIP Членство';
    return 'VIP Üyelik';
  }

  String get vipSubtitle {
    if (isEnglish) return 'Enter your VIP code to access\nall servers without limits.';
    if (isRussian) return 'Введите VIP-код для доступа\nко всем серверам без ограничений.';
    return 'VIP kodunuzu girerek tüm\nsunuculara sınırsız erişin.';
  }

  String get enterCode {
    if (isEnglish) return 'Enter Code';
    if (isRussian) return 'Ввести код';
    return 'Kodu Gir';
  }

  String get activate {
    if (isEnglish) return 'Activate';
    if (isRussian) return 'Активировать';
    return 'Aktive Et';
  }

  String get vipActive {
    if (isEnglish) return 'VIP Active! 🎉';
    if (isRussian) return 'VIP Активен! 🎉';
    return 'VIP Aktif! 🎉';
  }

  String get invalidCode {
    if (isEnglish) return 'Invalid code!';
    if (isRussian) return 'Неверный код!';
    return 'Geçersiz kod!';
  }

  String get enterCodeHint {
    if (isEnglish) return 'Please enter the code';
    if (isRussian) return 'Пожалуйста, введите код';
    return 'Lütfen kodu girin';
  }

  String get fastServers {
    if (isEnglish) return 'High-speed VIP servers';
    if (isRussian) return 'Высокоскоростные VIP серверы';
    return 'Yüksek hızlı VIP sunucular';
  }

  String get allCountries {
    if (isEnglish) return 'Access to all countries';
    if (isRussian) return 'Доступ ко всем странам';
    return 'Tüm ülkelere erişim';
  }

  String get advancedEncryption {
    if (isEnglish) return 'Advanced encryption';
    if (isRussian) return 'Расширенное шифрование';
    return 'Gelişmiş şifreleme';
  }

  String get unlimited {
    if (isEnglish) return 'Unlimited bandwidth';
    if (isRussian) return 'Безлимитный трафик';
    return 'Sınırsız bant genişliği';
  }

  String get ipLabel => 'IP';

  String get selectLanguage {
    if (isEnglish) return 'Select Language';
    if (isRussian) return 'Выберите язык';
    return 'Dil Seçin';
  }
}
