import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class UsersRecord extends FirestoreRecord {
  UsersRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "display_name" field.
  String? _displayName;
  String get displayName => _displayName ?? '';
  bool hasDisplayName() => _displayName != null;

  // "photo_url" field.
  String? _photoUrl;
  String get photoUrl => _photoUrl ?? '';
  bool hasPhotoUrl() => _photoUrl != null;

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "phone_number" field.
  String? _phoneNumber;
  String get phoneNumber => _phoneNumber ?? '';
  bool hasPhoneNumber() => _phoneNumber != null;

  // "nome" field.
  String? _nome;
  String get nome => _nome ?? '';
  bool hasNome() => _nome != null;

  // "cognome" field.
  String? _cognome;
  String get cognome => _cognome ?? '';
  bool hasCognome() => _cognome != null;

  // "data_nascita" field.
  DateTime? _dataNascita;
  DateTime? get dataNascita => _dataNascita;
  bool hasDataNascita() => _dataNascita != null;

  // "notifiche_ordini" field.
  bool? _notificheOrdini;
  bool get notificheOrdini => _notificheOrdini ?? false;
  bool hasNotificheOrdini() => _notificheOrdini != null;

  // "notifiche_promo" field.
  bool? _notifichePromo;
  bool get notifichePromo => _notifichePromo ?? false;
  bool hasNotifichePromo() => _notifichePromo != null;

  // "temaScelto" field.
  String? _temaScelto;
  String get temaScelto => _temaScelto ?? '';
  bool hasTemaScelto() => _temaScelto != null;

  // "ordine_preferito" field.
  String? _ordinePreferito;
  String get ordinePreferito => _ordinePreferito ?? '';
  bool hasOrdinePreferito() => _ordinePreferito != null;

  // "isAdmin" field.
  bool? _isAdmin;
  bool get isAdmin => _isAdmin ?? false;
  bool hasIsAdmin() => _isAdmin != null;

  // "isPremium" field.
  bool? _isPremium;
  bool get isPremium => _isPremium ?? false;
  bool hasIsPremium() => _isPremium != null;

  // "stripeId" field.
  String? _stripeId;
  String get stripeId => _stripeId ?? '';
  bool hasStripeId() => _stripeId != null;

  // "premium_expiry_date" field.
  DateTime? _premiumExpiryDate;
  DateTime? get premiumExpiryDate => _premiumExpiryDate;
  bool hasPremiumExpiryDate() => _premiumExpiryDate != null;

  // "ha_usato_prova" field.
  bool? _haUsatoProva;
  bool get haUsatoProva => _haUsatoProva ?? false;
  bool hasHaUsatoProva() => _haUsatoProva != null;

  void _initializeFields() {
    _email = snapshotData['email'] as String?;
    _displayName = snapshotData['display_name'] as String?;
    _photoUrl = snapshotData['photo_url'] as String?;
    _uid = snapshotData['uid'] as String?;
    _createdTime = snapshotData['created_time'] as DateTime?;
    _phoneNumber = snapshotData['phone_number'] as String?;
    _nome = snapshotData['nome'] as String?;
    _cognome = snapshotData['cognome'] as String?;
    _dataNascita = snapshotData['data_nascita'] as DateTime?;
    _notificheOrdini = snapshotData['notifiche_ordini'] as bool?;
    _notifichePromo = snapshotData['notifiche_promo'] as bool?;
    _temaScelto = snapshotData['temaScelto'] as String?;
    _ordinePreferito = snapshotData['ordine_preferito'] as String?;
    _isAdmin = snapshotData['isAdmin'] as bool?;
    _isPremium = snapshotData['isPremium'] as bool?;
    _stripeId = snapshotData['stripeId'] as String?;
    _premiumExpiryDate = snapshotData['premium_expiry_date'] as DateTime?;
    _haUsatoProva = snapshotData['ha_usato_prova'] as bool?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('users');

  static Stream<UsersRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => UsersRecord.fromSnapshot(s));

  static Future<UsersRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => UsersRecord.fromSnapshot(s));

  static UsersRecord fromSnapshot(DocumentSnapshot snapshot) => UsersRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static UsersRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      UsersRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'UsersRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is UsersRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createUsersRecordData({
  String? email,
  String? displayName,
  String? photoUrl,
  String? uid,
  DateTime? createdTime,
  String? phoneNumber,
  String? nome,
  String? cognome,
  DateTime? dataNascita,
  bool? notificheOrdini,
  bool? notifichePromo,
  String? temaScelto,
  String? ordinePreferito,
  bool? isAdmin,
  bool? isPremium,
  String? stripeId,
  DateTime? premiumExpiryDate,
  bool? haUsatoProva,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'uid': uid,
      'created_time': createdTime,
      'phone_number': phoneNumber,
      'nome': nome,
      'cognome': cognome,
      'data_nascita': dataNascita,
      'notifiche_ordini': notificheOrdini,
      'notifiche_promo': notifichePromo,
      'temaScelto': temaScelto,
      'ordine_preferito': ordinePreferito,
      'isAdmin': isAdmin,
      'isPremium': isPremium,
      'stripeId': stripeId,
      'premium_expiry_date': premiumExpiryDate,
      'ha_usato_prova': haUsatoProva,
    }.withoutNulls,
  );

  return firestoreData;
}

class UsersRecordDocumentEquality implements Equality<UsersRecord> {
  const UsersRecordDocumentEquality();

  @override
  bool equals(UsersRecord? e1, UsersRecord? e2) {
    return e1?.email == e2?.email &&
        e1?.displayName == e2?.displayName &&
        e1?.photoUrl == e2?.photoUrl &&
        e1?.uid == e2?.uid &&
        e1?.createdTime == e2?.createdTime &&
        e1?.phoneNumber == e2?.phoneNumber &&
        e1?.nome == e2?.nome &&
        e1?.cognome == e2?.cognome &&
        e1?.dataNascita == e2?.dataNascita &&
        e1?.notificheOrdini == e2?.notificheOrdini &&
        e1?.notifichePromo == e2?.notifichePromo &&
        e1?.temaScelto == e2?.temaScelto &&
        e1?.ordinePreferito == e2?.ordinePreferito &&
        e1?.isAdmin == e2?.isAdmin &&
        e1?.isPremium == e2?.isPremium &&
        e1?.stripeId == e2?.stripeId &&
        e1?.premiumExpiryDate == e2?.premiumExpiryDate &&
        e1?.haUsatoProva == e2?.haUsatoProva;
  }

  @override
  int hash(UsersRecord? e) => const ListEquality().hash([
        e?.email,
        e?.displayName,
        e?.photoUrl,
        e?.uid,
        e?.createdTime,
        e?.phoneNumber,
        e?.nome,
        e?.cognome,
        e?.dataNascita,
        e?.notificheOrdini,
        e?.notifichePromo,
        e?.temaScelto,
        e?.ordinePreferito,
        e?.isAdmin,
        e?.isPremium,
        e?.stripeId,
        e?.premiumExpiryDate,
        e?.haUsatoProva
      ]);

  @override
  bool isValidKey(Object? o) => o is UsersRecord;
}
