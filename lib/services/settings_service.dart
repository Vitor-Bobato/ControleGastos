import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  late SharedPreferences _prefs;

  static const String _currencyKey = 'currency';
  static const String _dailyLimitKey = 'dailyLimit';

  // Inicializa a instância do SharedPreferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // Salva a moeda selecionada
  Future<void> saveCurrency(String currency) async {
    await _prefs.setString(_currencyKey, currency);
  }

  // Obtém a moeda salva, com um valor padrão
  String getCurrency() {
    return _prefs.getString(_currencyKey) ?? 'R\$'; // Padrão: Real
  }

  // Salva o limite diário de gastos
  Future<void> saveDailyLimit(double limit) async {
    await _prefs.setDouble(_dailyLimitKey, limit);
  }

  // Obtém o limite diário, com um valor padrão
  double getDailyLimit() {
    return _prefs.getDouble(_dailyLimitKey) ?? 0.0; // Padrão: 0.0
  }
}
