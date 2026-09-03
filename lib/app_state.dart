import 'package:flutter/material.dart';
import '/backend/backend.dart';
import '/backend/api_requests/api_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'flutter_flow/flutter_flow_util.dart';

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

  String _fotoInMemoria = '';
  String get fotoInMemoria => _fotoInMemoria;
  set fotoInMemoria(String value) {
    _fotoInMemoria = value;
  }

  Color _temaPrimary = Color(4281097807);
  Color get temaPrimary => _temaPrimary;
  set temaPrimary(Color value) {
    _temaPrimary = value;
    prefs.setInt('ff_temaPrimary', value.value);
  }

  Color _temaSecondary = Color(4292397751);
  Color get temaSecondary => _temaSecondary;
  set temaSecondary(Color value) {
    _temaSecondary = value;
    prefs.setInt('ff_temaSecondary', value.value);
  }

  Color _temaTertiary = Color(4289082428);
  Color get temaTertiary => _temaTertiary;
  set temaTertiary(Color value) {
    _temaTertiary = value;
    prefs.setInt('ff_temaTertiary', value.value);
  }

  Color _temaAlternate = Color(4281545523);
  Color get temaAlternate => _temaAlternate;
  set temaAlternate(Color value) {
    _temaAlternate = value;
    prefs.setInt('ff_temaAlternate', value.value);
  }

  Color _temaPrimaryBackground = Color(4294966005);
  Color get temaPrimaryBackground => _temaPrimaryBackground;
  set temaPrimaryBackground(Color value) {
    _temaPrimaryBackground = value;
    prefs.setInt('ff_temaPrimaryBackground', value.value);
  }

  Color _temaSecondaryBackground = Color(4294043868);
  Color get temaSecondaryBackground => _temaSecondaryBackground;
  set temaSecondaryBackground(Color value) {
    _temaSecondaryBackground = value;
    prefs.setInt('ff_temaSecondaryBackground', value.value);
  }

  Color _temaPrimaryText = Color(4282466110);
  Color get temaPrimaryText => _temaPrimaryText;
  set temaPrimaryText(Color value) {
    _temaPrimaryText = value;
    prefs.setInt('ff_temaPrimaryText', value.value);
  }

  Color _temaSecondaryText = Color(4289043862);
  Color get temaSecondaryText => _temaSecondaryText;
  set temaSecondaryText(Color value) {
    _temaSecondaryText = value;
    prefs.setInt('ff_temaSecondaryText', value.value);
  }

  Color _temaAccent1 = Color(841768527);
  Color get temaAccent1 => _temaAccent1;
  set temaAccent1(Color value) {
    _temaAccent1 = value;
    prefs.setInt('ff_temaAccent1', value.value);
  }

  Color _temaAccent2 = Color(866530364);
  Color get temaAccent2 => _temaAccent2;
  set temaAccent2(Color value) {
    _temaAccent2 = value;
    prefs.setInt('ff_temaAccent2', value.value);
  }

  Color _temaAccent3 = Color(886622903);
  Color get temaAccent3 => _temaAccent3;
  set temaAccent3(Color value) {
    _temaAccent3 = value;
    prefs.setInt('ff_temaAccent3', value.value);
  }

  Color _temaAccent4 = Color(4283401696);
  Color get temaAccent4 => _temaAccent4;
  set temaAccent4(Color value) {
    _temaAccent4 = value;
    prefs.setInt('ff_temaAccent4', value.value);
  }

  Color _temaSuccess = Color(4278951796);
  Color get temaSuccess => _temaSuccess;
  set temaSuccess(Color value) {
    _temaSuccess = value;
    prefs.setInt('ff_temaSuccess', value.value);
  }

  Color _temaError = Color(4294461004);
  Color get temaError => _temaError;
  set temaError(Color value) {
    _temaError = value;
    prefs.setInt('ff_temaError', value.value);
  }

  Color _temaWarning = Color(4294945062);
  Color get temaWarning => _temaWarning;
  set temaWarning(Color value) {
    _temaWarning = value;
    prefs.setInt('ff_temaWarning', value.value);
  }

  Color _temaInfo = Color(4283401696);
  Color get temaInfo => _temaInfo;
  set temaInfo(Color value) {
    _temaInfo = value;
    prefs.setInt('ff_temaInfo', value.value);
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
