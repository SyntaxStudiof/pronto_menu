import 'package:flutter/material.dart';
import '/backend/backend.dart';
import '/backend/api_requests/api_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_flow/flutter_flow_util.dart';
import 'flutter_flow/flutter_flow_theme.dart';

class FFAppState extends ChangeNotifier {
  static FFAppState _instance = FFAppState._internal();

  factory FFAppState() {
    return _instance;
  }

  FFAppState._internal();

  static void reset() {
    _instance = FFAppState._internal();
  }

  Future initializePersistedState() async {
    prefs = await SharedPreferences.getInstance();
    _safeInit(() {
      _Carrello = prefs
              .getStringList('ff_Carrello')
              ?.map((path) => path.ref)
              .toList() ??
          _Carrello;
    });
    _safeInit(() {
      _totaleCarrello = prefs.getDouble('ff_totaleCarrello') ?? _totaleCarrello;
    });
    _safeInit(() {
      _CarrelloNomi = prefs.getStringList('ff_CarrelloNomi') ?? _CarrelloNomi;
    });
    _safeInit(() {
      _CarrelloPrezzi = prefs
              .getStringList('ff_CarrelloPrezzi')
              ?.map((x) => double.tryParse(x) ?? 0.0)
              .toList() ??
          _CarrelloPrezzi;
    });
    _safeInit(() {
      _temaScelto = prefs.getString('ff_temaScelto') ?? _temaScelto;
    });
    _safeInit(() {
      _temaPrimary =
          _colorFromIntValue(prefs.getInt('ff_temaPrimary')) ?? _temaPrimary;
    });
    _safeInit(() {
      _temaSecondary = _colorFromIntValue(prefs.getInt('ff_temaSecondary')) ??
          _temaSecondary;
    });
    _safeInit(() {
      _temaTertiary =
          _colorFromIntValue(prefs.getInt('ff_temaTertiary')) ?? _temaTertiary;
    });
    _safeInit(() {
      _temaAlternate = _colorFromIntValue(prefs.getInt('ff_temaAlternate')) ??
          _temaAlternate;
    });
    _safeInit(() {
      _temaPrimaryBackground =
          _colorFromIntValue(prefs.getInt('ff_temaPrimaryBackground')) ??
              _temaPrimaryBackground;
    });
    _safeInit(() {
      _temaSecondaryBackground =
          _colorFromIntValue(prefs.getInt('ff_temaSecondaryBackground')) ??
              _temaSecondaryBackground;
    });
    _safeInit(() {
      _temaPrimaryText =
          _colorFromIntValue(prefs.getInt('ff_temaPrimaryText')) ??
              _temaPrimaryText;
    });
    _safeInit(() {
      _temaSecondaryText =
          _colorFromIntValue(prefs.getInt('ff_temaSecondaryText')) ??
              _temaSecondaryText;
    });
    _safeInit(() {
      _temaAccent1 =
          _colorFromIntValue(prefs.getInt('ff_temaAccent1')) ?? _temaAccent1;
    });
    _safeInit(() {
      _temaAccent2 =
          _colorFromIntValue(prefs.getInt('ff_temaAccent2')) ?? _temaAccent2;
    });
    _safeInit(() {
      _temaAccent3 =
          _colorFromIntValue(prefs.getInt('ff_temaAccent3')) ?? _temaAccent3;
    });
    _safeInit(() {
      _temaAccent4 =
          _colorFromIntValue(prefs.getInt('ff_temaAccent4')) ?? _temaAccent4;
    });
    _safeInit(() {
      _temaSuccess =
          _colorFromIntValue(prefs.getInt('ff_temaSuccess')) ?? _temaSuccess;
    });
    _safeInit(() {
      _temaError =
          _colorFromIntValue(prefs.getInt('ff_temaError')) ?? _temaError;
    });
    _safeInit(() {
      _temaWarning =
          _colorFromIntValue(prefs.getInt('ff_temaWarning')) ?? _temaWarning;
    });
    _safeInit(() {
      _temaInfo = _colorFromIntValue(prefs.getInt('ff_temaInfo')) ?? _temaInfo;
    });
    _safeInit(() {
      _ristoranteSalvato =
          prefs.getString('ff_ristoranteSalvato')?.ref ?? _ristoranteSalvato;
    });
    _safeInit(() {
      _numeroTavolo = prefs.getString('ff_numeroTavolo') ?? _numeroTavolo;
    });
  }

  void update(VoidCallback callback) {
    callback();
    notifyListeners();
  }

  late SharedPreferences prefs;

  List<DocumentReference> _Carrello = [];
  List<DocumentReference> get Carrello => _Carrello;
  set Carrello(List<DocumentReference> value) {
    _Carrello = value;
    prefs.setStringList('ff_Carrello', value.map((x) => x.path).toList());
  }

  void addToCarrello(DocumentReference value) {
    Carrello.add(value);
    prefs.setStringList('ff_Carrello', _Carrello.map((x) => x.path).toList());
  }

  void removeFromCarrello(DocumentReference value) {
    Carrello.remove(value);
    prefs.setStringList('ff_Carrello', _Carrello.map((x) => x.path).toList());
  }

  void removeAtIndexFromCarrello(int index) {
    Carrello.removeAt(index);
    prefs.setStringList('ff_Carrello', _Carrello.map((x) => x.path).toList());
  }

  void updateCarrelloAtIndex(
    int index,
    DocumentReference Function(DocumentReference) updateFn,
  ) {
    Carrello[index] = updateFn(_Carrello[index]);
    prefs.setStringList('ff_Carrello', _Carrello.map((x) => x.path).toList());
  }

  void insertAtIndexInCarrello(int index, DocumentReference value) {
    Carrello.insert(index, value);
    prefs.setStringList('ff_Carrello', _Carrello.map((x) => x.path).toList());
  }

  double _totaleCarrello = 0.0;
  double get totaleCarrello => _totaleCarrello;
  set totaleCarrello(double value) {
    _totaleCarrello = value;
    prefs.setDouble('ff_totaleCarrello', value);
  }

  List<String> _CarrelloNomi = [];
  List<String> get CarrelloNomi => _CarrelloNomi;
  set CarrelloNomi(List<String> value) {
    _CarrelloNomi = value;
    prefs.setStringList('ff_CarrelloNomi', value);
  }

  void addToCarrelloNomi(String value) {
    CarrelloNomi.add(value);
    prefs.setStringList('ff_CarrelloNomi', _CarrelloNomi);
  }

  void removeFromCarrelloNomi(String value) {
    CarrelloNomi.remove(value);
    prefs.setStringList('ff_CarrelloNomi', _CarrelloNomi);
  }

  void removeAtIndexFromCarrelloNomi(int index) {
    CarrelloNomi.removeAt(index);
    prefs.setStringList('ff_CarrelloNomi', _CarrelloNomi);
  }

  void updateCarrelloNomiAtIndex(
    int index,
    String Function(String) updateFn,
  ) {
    CarrelloNomi[index] = updateFn(_CarrelloNomi[index]);
    prefs.setStringList('ff_CarrelloNomi', _CarrelloNomi);
  }

  void insertAtIndexInCarrelloNomi(int index, String value) {
    CarrelloNomi.insert(index, value);
    prefs.setStringList('ff_CarrelloNomi', _CarrelloNomi);
  }

  List<double> _CarrelloPrezzi = [];
  List<double> get CarrelloPrezzi => _CarrelloPrezzi;
  set CarrelloPrezzi(List<double> value) {
    _CarrelloPrezzi = value;
    prefs.setStringList(
        'ff_CarrelloPrezzi', value.map((x) => x.toString()).toList());
  }

  void addToCarrelloPrezzi(double value) {
    CarrelloPrezzi.add(value);
    prefs.setStringList(
        'ff_CarrelloPrezzi', _CarrelloPrezzi.map((x) => x.toString()).toList());
  }

  void removeFromCarrelloPrezzi(double value) {
    CarrelloPrezzi.remove(value);
    prefs.setStringList(
        'ff_CarrelloPrezzi', _CarrelloPrezzi.map((x) => x.toString()).toList());
  }

  void removeAtIndexFromCarrelloPrezzi(int index) {
    CarrelloPrezzi.removeAt(index);
    prefs.setStringList(
        'ff_CarrelloPrezzi', _CarrelloPrezzi.map((x) => x.toString()).toList());
  }

  void updateCarrelloPrezziAtIndex(
    int index,
    double Function(double) updateFn,
  ) {
    CarrelloPrezzi[index] = updateFn(_CarrelloPrezzi[index]);
    prefs.setStringList(
        'ff_CarrelloPrezzi', _CarrelloPrezzi.map((x) => x.toString()).toList());
  }

  void insertAtIndexInCarrelloPrezzi(int index, double value) {
    CarrelloPrezzi.insert(index, value);
    prefs.setStringList(
        'ff_CarrelloPrezzi', _CarrelloPrezzi.map((x) => x.toString()).toList());
  }

  String _fotoInMemoria = '';
  String get fotoInMemoria => _fotoInMemoria;
  set fotoInMemoria(String value) {
    _fotoInMemoria = value;
  }

  String _temaScelto = 'ProntoMenulight';
  String get temaScelto => _temaScelto;
  set temaScelto(String value) {
    _temaScelto = value;
    prefs.setString('ff_temaScelto', value);
    notifyListeners();
  }

  void applyTheme(String themeKey, {BuildContext? context}) {
    _temaScelto = themeKey;
    prefs.setString('ff_temaScelto', themeKey);

    switch (themeKey) {
      case 'ProntoMenudark':
        _temaPrimary = const Color(0xFF21493D);
        _temaSecondary = const Color(0xFF8E7C6C);
        _temaTertiary = const Color(0xFF782329);
        _temaAlternate = const Color(0xFFF2ECE4);
        _temaPrimaryBackground = const Color(0xFF121212);
        _temaSecondaryBackground = const Color(0xFF1E1E1E);
        _temaPrimaryText = const Color(0xFFFDF6ED);
        _temaSecondaryText = const Color(0xFFC1B4AB);
        _temaAccent1 = const Color(0xFF367160);
        _temaAccent2 = const Color(0x33A6343C);
        _temaAccent3 = const Color(0xFFC03C46);
        _temaAccent4 = const Color(0xFF6F9CEF);
        _temaSuccess = const Color(0xFF11C694);
        _temaError = const Color(0xFFF75A60);
        _temaWarning = const Color(0xFFFFB84D);
        _temaInfo = const Color(0xFF6F9CEF);
        break;

      case 'AmethystSlatelight':
        _temaPrimary = const Color(0xFF4B0082);
        _temaSecondary = const Color(0xFF008080);
        _temaTertiary = const Color(0xFFFFD700);
        _temaAlternate = const Color(0xFF800080);
        _temaPrimaryBackground = const Color(0xFFE5E4E2);
        _temaSecondaryBackground = const Color(0xFFF5F5F5);
        _temaPrimaryText = const Color(0xFF1C1C1C);
        _temaSecondaryText = const Color(0xFF666666);
        _temaAccent1 = const Color(0x344B0082);
        _temaAccent2 = const Color(0xFFE0E0E0);
        _temaAccent3 = Colors.white;
        _temaAccent4 = const Color(0xFF310055);
        _temaSuccess = const Color(0xFF228B22);
        _temaError = const Color(0xFFB00020);
        _temaWarning = const Color(0xFFFF8C00);
        _temaInfo = const Color(0xFF4F85E0);
        break;

      case 'AmethystSlatedark':
        _temaPrimary = const Color(0xFFBB86FC);
        _temaSecondary = const Color(0xFF03DAC6);
        _temaTertiary = const Color(0xFFFFD700);
        _temaAlternate = const Color(0xFF9932CC);
        _temaPrimaryBackground = const Color(0xFF121212);
        _temaSecondaryBackground = const Color(0xFF1E1E1E);
        _temaPrimaryText = Colors.white;
        _temaSecondaryText = const Color(0xFFA0A0A0);
        _temaAccent1 = const Color(0x25BB86FC);
        _temaAccent2 = const Color(0xFFE0E0E0);
        _temaAccent3 = const Color(0xFF2C2C2C);
        _temaAccent4 = const Color(0xFFD1A3FF);
        _temaSuccess = const Color(0xFF81C784);
        _temaError = const Color(0xFFCF6679);
        _temaWarning = const Color(0xFFFFB84D);
        _temaInfo = const Color(0xFF64B5F6);
        break;

      case 'SunsetAmberlight':
        _temaPrimary = const Color(0xFFE0533C);
        _temaSecondary = const Color(0xFFE8985E);
        _temaTertiary = const Color(0xFF8B2635);
        _temaAlternate = const Color(0xFFE5DDD5);
        _temaPrimaryBackground = const Color(0xFFFDFBF7);
        _temaSecondaryBackground = const Color(0xFFF7F1E9);
        _temaPrimaryText = const Color(0xFF2C221E);
        _temaSecondaryText = const Color(0xFF87756D);
        _temaAccent1 = const Color(0x33E0533C);
        _temaAccent2 = const Color(0xFFEFE4DA);
        _temaAccent3 = Colors.white;
        _temaAccent4 = const Color(0xFFBF360C);
        _temaSuccess = const Color(0xFF10B981);
        _temaError = const Color(0xFFEF4444);
        _temaWarning = const Color(0xFFF59E0B);
        _temaInfo = const Color(0xFF3B82F6);
        break;

      case 'SunsetAmberdark':
        _temaPrimary = const Color(0xFFFF7A59);
        _temaSecondary = const Color(0xFFDCAE8A);
        _temaTertiary = const Color(0xFFE06D78);
        _temaAlternate = const Color(0xFF382E2B);
        _temaPrimaryBackground = const Color(0xFF141110);
        _temaSecondaryBackground = const Color(0xFF201B19);
        _temaPrimaryText = const Color(0xFFFFF6F0);
        _temaSecondaryText = const Color(0xFFB5A49D);
        _temaAccent1 = const Color(0x33FF7A59);
        _temaAccent2 = const Color(0xFF2E2422);
        _temaAccent3 = const Color(0xFF2C2220);
        _temaAccent4 = const Color(0xFFFF8E73);
        _temaSuccess = const Color(0xFF34D399);
        _temaError = const Color(0xFFF87171);
        _temaWarning = const Color(0xFFFBBF24);
        _temaInfo = const Color(0xFF60A5FA);
        break;

      case 'OceanSapphirelight':
        _temaPrimary = const Color(0xFF0F52BA);
        _temaSecondary = const Color(0xFF2A9D8F);
        _temaTertiary = const Color(0xFFE76F51);
        _temaAlternate = const Color(0xFFD9E3EC);
        _temaPrimaryBackground = const Color(0xFFF5F8FA);
        _temaSecondaryBackground = const Color(0xFFEAF0F6);
        _temaPrimaryText = const Color(0xFF102A43);
        _temaSecondaryText = const Color(0xFF627D98);
        _temaAccent1 = const Color(0x330F52BA);
        _temaAccent2 = const Color(0xFFDCE7F2);
        _temaAccent3 = Colors.white;
        _temaAccent4 = const Color(0xFF0A387E);
        _temaSuccess = const Color(0xFF0D9488);
        _temaError = const Color(0xFFE11D48);
        _temaWarning = const Color(0xFFF59E0B);
        _temaInfo = const Color(0xFF0284C7);
        break;

      case 'OceanSapphiredark':
        _temaPrimary = const Color(0xFF4D96FF);
        _temaSecondary = const Color(0xFF48CAE4);
        _temaTertiary = const Color(0xFFFF9E7D);
        _temaAlternate = const Color(0xFF203550);
        _temaPrimaryBackground = const Color(0xFF0B131F);
        _temaSecondaryBackground = const Color(0xFF152238);
        _temaPrimaryText = const Color(0xFFF0F6FC);
        _temaSecondaryText = const Color(0xFF8FA7C2);
        _temaAccent1 = const Color(0x334D96FF);
        _temaAccent2 = const Color(0xFF1D3252);
        _temaAccent3 = const Color(0xFF132034);
        _temaAccent4 = const Color(0xFF70A9FF);
        _temaSuccess = const Color(0xFF2DD4BF);
        _temaError = const Color(0xFFFB7185);
        _temaWarning = const Color(0xFFFBBF24);
        _temaInfo = const Color(0xFF38BDF8);
        break;

      case 'CyberLimelight':
        _temaPrimary = const Color(0xFF65A30D);
        _temaSecondary = const Color(0xFF0891B2);
        _temaTertiary = const Color(0xFFDB2777);
        _temaAlternate = const Color(0xFFE2E8F0);
        _temaPrimaryBackground = const Color(0xFFF8FAFC);
        _temaSecondaryBackground = const Color(0xFFEDF2F7);
        _temaPrimaryText = const Color(0xFF0F172A);
        _temaSecondaryText = const Color(0xFF64748B);
        _temaAccent1 = const Color(0x3384CC16);
        _temaAccent2 = const Color(0xFFE2E8F0);
        _temaAccent3 = Colors.white;
        _temaAccent4 = const Color(0xFF4D7C0F);
        _temaSuccess = const Color(0xFF16A34A);
        _temaError = const Color(0xFFDC2626);
        _temaWarning = const Color(0xFFF59E0B);
        _temaInfo = const Color(0xFF0284C7);
        break;

      case 'CyberLimedark':
        _temaPrimary = const Color(0xFFA3E635);
        _temaSecondary = const Color(0xFF22D3EE);
        _temaTertiary = const Color(0xFFF43F5E);
        _temaAlternate = const Color(0xFF27272A);
        _temaPrimaryBackground = const Color(0xFF09090B);
        _temaSecondaryBackground = const Color(0xFF18181B);
        _temaPrimaryText = const Color(0xFFF4F4F5);
        _temaSecondaryText = const Color(0xFFA1A1AA);
        _temaAccent1 = const Color(0x33A3E635);
        _temaAccent2 = const Color(0xFF27272A);
        _temaAccent3 = const Color(0xFF121214);
        _temaAccent4 = const Color(0xFFBEF264);
        _temaSuccess = const Color(0xFF4ADE80);
        _temaError = const Color(0xFFFB7185);
        _temaWarning = const Color(0xFFFACC15);
        _temaInfo = const Color(0xFF38BDF8);
        break;

      case 'BerryPoplight':
        _temaPrimary = const Color(0xFFE11D48);
        _temaSecondary = const Color(0xFF9333EA);
        _temaTertiary = const Color(0xFFF59E0B);
        _temaAlternate = const Color(0xFFFCE7F3);
        _temaPrimaryBackground = const Color(0xFFFFF5F7);
        _temaSecondaryBackground = const Color(0xFFFDE2E8);
        _temaPrimaryText = const Color(0xFF3B071E);
        _temaSecondaryText = const Color(0xFF9F1239);
        _temaAccent1 = const Color(0x33E11D48);
        _temaAccent2 = const Color(0xFFFCE7F3);
        _temaAccent3 = Colors.white;
        _temaAccent4 = const Color(0xFFBE123C);
        _temaSuccess = const Color(0xFF10B981);
        _temaError = const Color(0xFFE11D48);
        _temaWarning = const Color(0xFFF59E0B);
        _temaInfo = const Color(0xFF8B5CF6);
        break;

      case 'BerryPopdark':
        _temaPrimary = const Color(0xFFFB7185);
        _temaSecondary = const Color(0xFFC084FC);
        _temaTertiary = const Color(0xFFFDE047);
        _temaAlternate = const Color(0xFF3F1226);
        _temaPrimaryBackground = const Color(0xFF14050D);
        _temaSecondaryBackground = const Color(0xFF240A18);
        _temaPrimaryText = const Color(0xFFFFF1F2);
        _temaSecondaryText = const Color(0xFFFDA4AF);
        _temaAccent1 = const Color(0x33FB7185);
        _temaAccent2 = const Color(0xFF2F0C1E);
        _temaAccent3 = const Color(0xFF1A0510);
        _temaAccent4 = const Color(0xFFF43F5E);
        _temaSuccess = const Color(0xFF34D399);
        _temaError = const Color(0xFFFDA4AF);
        _temaWarning = const Color(0xFFFDE047);
        _temaInfo = const Color(0xFFA78BFA);
        break;

      case 'GoldLuxurylight':
        _temaPrimary = const Color(0xFFB48208);
        _temaSecondary = const Color(0xFF78350F);
        _temaTertiary = const Color(0xFF047857);
        _temaAlternate = const Color(0xFFE5D9C5);
        _temaPrimaryBackground = const Color(0xFFFAF7F2);
        _temaSecondaryBackground = const Color(0xFFF2EAD9);
        _temaPrimaryText = const Color(0xFF1C1917);
        _temaSecondaryText = const Color(0xFF78716C);
        _temaAccent1 = const Color(0x33B48208);
        _temaAccent2 = const Color(0xFFEAE0CD);
        _temaAccent3 = Colors.white;
        _temaAccent4 = const Color(0xFF92400E);
        _temaSuccess = const Color(0xFF059669);
        _temaError = const Color(0xFFDC2626);
        _temaWarning = const Color(0xFFD97706);
        _temaInfo = const Color(0xFF2563EB);
        break;

      case 'GoldLuxurydark':
        _temaPrimary = const Color(0xFFFACC15);
        _temaSecondary = const Color(0xFFFBBF24);
        _temaTertiary = const Color(0xFF10B981);
        _temaAlternate = const Color(0xFF292524);
        _temaPrimaryBackground = const Color(0xFF0C0A09);
        _temaSecondaryBackground = const Color(0xFF1C1917);
        _temaPrimaryText = const Color(0xFFFAFAF9);
        _temaSecondaryText = const Color(0xFFA8A29E);
        _temaAccent1 = const Color(0x33FACC15);
        _temaAccent2 = const Color(0xFF292524);
        _temaAccent3 = const Color(0xFF141210);
        _temaAccent4 = const Color(0xFFFDE047);
        _temaSuccess = const Color(0xFF34D399);
        _temaError = const Color(0xFFF87171);
        _temaWarning = const Color(0xFFFBBF24);
        _temaInfo = const Color(0xFF60A5FA);
        break;

      case 'ProntoMenulight':
      default:
        _temaScelto = 'ProntoMenulight';
        prefs.setString('ff_temaScelto', 'ProntoMenulight');
        _temaPrimary = const Color(0xFF2C5E4F);
        _temaSecondary = const Color(0xFFD8CAB7);
        _temaTertiary = const Color(0xFFA6343C);
        _temaAlternate = const Color(0xFF333333);
        _temaPrimaryBackground = const Color(0xFFFFFAF5);
        _temaSecondaryBackground = const Color(0xFFF1E8DC);
        _temaPrimaryText = const Color(0xFF413F3E);
        _temaSecondaryText = const Color(0xFFA59D96);
        _temaAccent1 = const Color(0x322C5E4F);
        _temaAccent2 = const Color(0xFFE0E0E0);
        _temaAccent3 = const Color(0x34D8CAB7);
        _temaAccent4 = const Color(0xFF310055);
        _temaSuccess = const Color(0xFF0B9F74);
        _temaError = const Color(0xFFF8464C);
        _temaWarning = const Color(0xFFFFA926);
        _temaInfo = const Color(0xFF4F85E0);
        break;
    }

    prefs.setInt('ff_temaPrimary', _temaPrimary.value);
    prefs.setInt('ff_temaSecondary', _temaSecondary.value);
    prefs.setInt('ff_temaTertiary', _temaTertiary.value);
    prefs.setInt('ff_temaAlternate', _temaAlternate.value);
    prefs.setInt('ff_temaPrimaryBackground', _temaPrimaryBackground.value);
    prefs.setInt('ff_temaSecondaryBackground', _temaSecondaryBackground.value);
    prefs.setInt('ff_temaPrimaryText', _temaPrimaryText.value);
    prefs.setInt('ff_temaSecondaryText', _temaSecondaryText.value);
    prefs.setInt('ff_temaAccent1', _temaAccent1.value);
    prefs.setInt('ff_temaAccent2', _temaAccent2.value);
    prefs.setInt('ff_temaAccent3', _temaAccent3.value);
    prefs.setInt('ff_temaAccent4', _temaAccent4.value);
    prefs.setInt('ff_temaSuccess', _temaSuccess.value);
    prefs.setInt('ff_temaError', _temaError.value);
    prefs.setInt('ff_temaWarning', _temaWarning.value);
    prefs.setInt('ff_temaInfo', _temaInfo.value);

    final isDark = themeKey.toLowerCase().contains('dark');
    FlutterFlowTheme.saveThemeMode(isDark ? ThemeMode.dark : ThemeMode.light);

    if (context != null) {
      setDarkModeSetting(context, isDark ? ThemeMode.dark : ThemeMode.light);
    }

    notifyListeners();
  }

  Color _temaPrimary = Color(4281097807);
  Color get temaPrimary => _temaPrimary;
  set temaPrimary(Color value) {
    _temaPrimary = value;
    prefs.setInt('ff_temaPrimary', value.value);
    notifyListeners();
  }

  Color _temaSecondary = Color(4292397751);
  Color get temaSecondary => _temaSecondary;
  set temaSecondary(Color value) {
    _temaSecondary = value;
    prefs.setInt('ff_temaSecondary', value.value);
    notifyListeners();
  }

  Color _temaTertiary = Color(4289082428);
  Color get temaTertiary => _temaTertiary;
  set temaTertiary(Color value) {
    _temaTertiary = value;
    prefs.setInt('ff_temaTertiary', value.value);
    notifyListeners();
  }

  Color _temaAlternate = Color(4281545523);
  Color get temaAlternate => _temaAlternate;
  set temaAlternate(Color value) {
    _temaAlternate = value;
    prefs.setInt('ff_temaAlternate', value.value);
    notifyListeners();
  }

  Color _temaPrimaryBackground = Color(4294966005);
  Color get temaPrimaryBackground => _temaPrimaryBackground;
  set temaPrimaryBackground(Color value) {
    _temaPrimaryBackground = value;
    prefs.setInt('ff_temaPrimaryBackground', value.value);
    notifyListeners();
  }

  Color _temaSecondaryBackground = Color(4294043868);
  Color get temaSecondaryBackground => _temaSecondaryBackground;
  set temaSecondaryBackground(Color value) {
    _temaSecondaryBackground = value;
    prefs.setInt('ff_temaSecondaryBackground', value.value);
    notifyListeners();
  }

  Color _temaPrimaryText = Color(4282466110);
  Color get temaPrimaryText => _temaPrimaryText;
  set temaPrimaryText(Color value) {
    _temaPrimaryText = value;
    prefs.setInt('ff_temaPrimaryText', value.value);
    notifyListeners();
  }

  Color _temaSecondaryText = Color(4289043862);
  Color get temaSecondaryText => _temaSecondaryText;
  set temaSecondaryText(Color value) {
    _temaSecondaryText = value;
    prefs.setInt('ff_temaSecondaryText', value.value);
    notifyListeners();
  }

  Color _temaAccent1 = Color(841768527);
  Color get temaAccent1 => _temaAccent1;
  set temaAccent1(Color value) {
    _temaAccent1 = value;
    prefs.setInt('ff_temaAccent1', value.value);
    notifyListeners();
  }

  Color _temaAccent2 = Color(866530364);
  Color get temaAccent2 => _temaAccent2;
  set temaAccent2(Color value) {
    _temaAccent2 = value;
    prefs.setInt('ff_temaAccent2', value.value);
    notifyListeners();
  }

  Color _temaAccent3 = Color(886622903);
  Color get temaAccent3 => _temaAccent3;
  set temaAccent3(Color value) {
    _temaAccent3 = value;
    prefs.setInt('ff_temaAccent3', value.value);
    notifyListeners();
  }

  Color _temaAccent4 = Color(4283401696);
  Color get temaAccent4 => _temaAccent4;
  set temaAccent4(Color value) {
    _temaAccent4 = value;
    prefs.setInt('ff_temaAccent4', value.value);
    notifyListeners();
  }

  Color _temaSuccess = Color(4278951796);
  Color get temaSuccess => _temaSuccess;
  set temaSuccess(Color value) {
    _temaSuccess = value;
    prefs.setInt('ff_temaSuccess', value.value);
    notifyListeners();
  }

  Color _temaError = Color(4294461004);
  Color get temaError => _temaError;
  set temaError(Color value) {
    _temaError = value;
    prefs.setInt('ff_temaError', value.value);
    notifyListeners();
  }

  Color _temaWarning = Color(4294945062);
  Color get temaWarning => _temaWarning;
  set temaWarning(Color value) {
    _temaWarning = value;
    prefs.setInt('ff_temaWarning', value.value);
    notifyListeners();
  }

  Color _temaInfo = Color(4283401696);
  Color get temaInfo => _temaInfo;
  set temaInfo(Color value) {
    _temaInfo = value;
    prefs.setInt('ff_temaInfo', value.value);
    notifyListeners();
  }

  DocumentReference? _ristoranteSalvato;
  DocumentReference? get ristoranteSalvato => _ristoranteSalvato;
  set ristoranteSalvato(DocumentReference? value) {
    _ristoranteSalvato = value;
    value != null
        ? prefs.setString('ff_ristoranteSalvato', value.path)
        : prefs.remove('ff_ristoranteSalvato');
  }

  String _loginProvider = '';
  String get loginProvider => _loginProvider;
  set loginProvider(String value) {
    _loginProvider = value;
  }

  String _numeroTavolo = '';
  String get numeroTavolo => _numeroTavolo;
  set numeroTavolo(String value) {
    _numeroTavolo = value;
    prefs.setString('ff_numeroTavolo', value);
  }
}

void _safeInit(Function() initializeField) {
  try {
    initializeField();
  } catch (_) {}
}

Future _safeInitAsync(Function() initializeField) async {
  try {
    await initializeField();
  } catch (_) {}
}

Color? _colorFromIntValue(int? val) {
  if (val == null) {
    return null;
  }
  return Color(val);
}
