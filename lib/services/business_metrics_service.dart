import '/backend/backend.dart';

class RistoranteMetricRow {
  final String id;
  final DocumentReference reference;
  final String nome;
  final String email;
  final String photoUrl;
  final bool isPremium;
  final int ordiniOggi;
  final int ordiniTotali;
  final int piattiTotali;
  final int fotoCaricate;
  final bool attivoOggi;
  final DateTime? ultimoOrdine;

  RistoranteMetricRow({
    required this.id,
    required this.reference,
    required this.nome,
    required this.email,
    required this.photoUrl,
    required this.isPremium,
    required this.ordiniOggi,
    required this.ordiniTotali,
    required this.piattiTotali,
    required this.fotoCaricate,
    required this.attivoOggi,
    this.ultimoOrdine,
  });
}

class BusinessMetrics {
  final int ristorantiTotali;
  final int ristorantiAttiviOggi;
  final int ristorantiPremium;
  final int utentiTotali;
  final int ordiniTotali;
  final int ordiniOggi;
  final double fatturatoTotaleOrdini;
  final double fatturatoOrdiniOggi;
  final int piattiTotali;
  final int fotoTotali;
  final double megabyteFotoStimati;
  final double gigabyteFotoStimati;
  final double percentualeStorageGratuito; // % su 5 GB
  final double limiteStorageGb;
  final List<RistoranteMetricRow> ristoranti;
  final DateTime dataRilevamento;

  BusinessMetrics({
    required this.ristorantiTotali,
    required this.ristorantiAttiviOggi,
    required this.ristorantiPremium,
    required this.utentiTotali,
    required this.ordiniTotali,
    required this.ordiniOggi,
    required this.fatturatoTotaleOrdini,
    required this.fatturatoOrdiniOggi,
    required this.piattiTotali,
    required this.fotoTotali,
    required this.megabyteFotoStimati,
    required this.gigabyteFotoStimati,
    required this.percentualeStorageGratuito,
    required this.limiteStorageGb,
    required this.ristoranti,
    required this.dataRilevamento,
  });
}

class BusinessMetricsService {
  static const double firebaseFreeTierStorageGb = 5.0; // Firebase Storage Spark Free Tier: 5 GB
  static const double averageMbPerPhoto = 1.6; // Media stima compressione foto caricate (1.6 MB)

  static bool _isCustomPhoto(String? url) {
    if (url == null || url.trim().isEmpty) return false;
    final lower = url.toLowerCase();
    if (lower.contains('immagine_standard') ||
        lower.contains('img_8006') ||
        lower.contains('unsplash.com')) {
      return false;
    }
    return lower.contains('firebasestorage.googleapis.com') ||
        lower.contains('storage.googleapis.com');
  }

  static Future<BusinessMetrics> calcolaMetriche() async {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    // 1. Carica tutti gli utenti / ristoranti
    final usersSnapshot = await FirebaseFirestore.instance.collection('users').get();
    final List<UsersRecord> allUsers =
        usersSnapshot.docs.map((doc) => UsersRecord.fromSnapshot(doc)).toList();

    final List<UsersRecord> ristorantiUsers =
        allUsers.where((u) => !u.isAdmin).toList();

    // 2. Carica tutti gli ordini
    final ordersSnapshot = await FirebaseFirestore.instance.collection('orders').get();
    final List<OrdersRecord> allOrders =
        ordersSnapshot.docs.map((doc) => OrdersRecord.fromSnapshot(doc)).toList();

    // 3. Carica tutti i piatti
    final piattiSnapshot = await FirebaseFirestore.instance.collection('Piatti').get();
    final List<PiattiRecord> allPiatti =
        piattiSnapshot.docs.map((doc) => PiattiRecord.fromSnapshot(doc)).toList();

    // Raggruppa ordini per ristorante
    final Map<String, List<OrdersRecord>> ordiniPerRistorante = {};
    for (final order in allOrders) {
      final refId = order.ristoranteRef?.id;
      if (refId != null) {
        ordiniPerRistorante.putIfAbsent(refId, () => []).add(order);
      }
    }

    // Raggruppa piatti per ristorante
    final Map<String, List<PiattiRecord>> piattiPerRistorante = {};
    for (final piatto in allPiatti) {
      final propId = piatto.proprietario?.id;
      if (propId != null) {
        piattiPerRistorante.putIfAbsent(propId, () => []).add(piatto);
      }
    }

    // Calcolo ordini di oggi e fatturati
    int ordiniOggiCount = 0;
    double fatturatoOggi = 0.0;
    double fatturatoTotale = 0.0;

    for (final order in allOrders) {
      fatturatoTotale += order.totale;
      if (order.dataCreazione != null && order.dataCreazione!.isAfter(todayStart)) {
        ordiniOggiCount++;
        fatturatoOggi += order.totale;
      }
    }

    // Calcolo foto personalizzate caricate
    int customPhotosCount = 0;

    for (final piatto in allPiatti) {
      if (_isCustomPhoto(piatto.foto)) {
        customPhotosCount++;
      }
    }

    for (final user in allUsers) {
      if (_isCustomPhoto(user.photoUrl)) {
        customPhotosCount++;
      }
    }

    // Costruisci dettaglio ristoranti
    final List<RistoranteMetricRow> rows = [];
    int ristorantiAttiviOggiCount = 0;

    for (final rest in ristorantiUsers) {
      final restId = rest.reference.id;
      final restOrders = ordiniPerRistorante[restId] ?? [];
      final restPiatti = piattiPerRistorante[restId] ?? [];

      int restOrdiniOggi = 0;
      DateTime? ultimoOrdine;

      for (final o in restOrders) {
        if (ultimoOrdine == null ||
            (o.dataCreazione != null && o.dataCreazione!.isAfter(ultimoOrdine))) {
          ultimoOrdine = o.dataCreazione;
        }
        if (o.dataCreazione != null && o.dataCreazione!.isAfter(todayStart)) {
          restOrdiniOggi++;
        }
      }

      int restFoto = 0;
      if (_isCustomPhoto(rest.photoUrl)) restFoto++;
      for (final p in restPiatti) {
        if (_isCustomPhoto(p.foto)) restFoto++;
      }

      final bool isCreatoOggi =
          rest.createdTime != null && rest.createdTime!.isAfter(todayStart);
      final bool attivoOggi = restOrdiniOggi > 0 || isCreatoOggi;

      if (attivoOggi) {
        ristorantiAttiviOggiCount++;
      }

      rows.add(
        RistoranteMetricRow(
          id: restId,
          reference: rest.reference,
          nome: rest.displayName.isNotEmpty ? rest.displayName : 'Ristorante senza nome',
          email: rest.email,
          photoUrl: rest.photoUrl,
          isPremium: rest.isPremium,
          ordiniOggi: restOrdiniOggi,
          ordiniTotali: restOrders.length,
          piattiTotali: restPiatti.length,
          fotoCaricate: restFoto,
          attivoOggi: attivoOggi,
          ultimoOrdine: ultimoOrdine,
        ),
      );
    }

    // Ordina: prima i ristoranti attivi oggi, poi per ordini totali decrescenti
    rows.sort((a, b) {
      if (a.attivoOggi && !b.attivoOggi) return -1;
      if (!a.attivoOggi && b.attivoOggi) return 1;
      return b.ordiniTotali.compareTo(a.ordiniTotali);
    });

    final double megabytesTotali = customPhotosCount * averageMbPerPhoto;
    final double gigabytesTotali = megabytesTotali / 1024.0;
    final double percentualeStorage =
        (gigabytesTotali / firebaseFreeTierStorageGb * 100).clamp(0.0, 100.0);

    return BusinessMetrics(
      ristorantiTotali: ristorantiUsers.length,
      ristorantiAttiviOggi: ristorantiAttiviOggiCount,
      ristorantiPremium: ristorantiUsers.where((r) => r.isPremium).length,
      utentiTotali: allUsers.length,
      ordiniTotali: allOrders.length,
      ordiniOggi: ordiniOggiCount,
      fatturatoTotaleOrdini: fatturatoTotale,
      fatturatoOrdiniOggi: fatturatoOggi,
      piattiTotali: allPiatti.length,
      fotoTotali: customPhotosCount,
      megabyteFotoStimati: megabytesTotali,
      gigabyteFotoStimati: gigabytesTotali,
      percentualeStorageGratuito: percentualeStorage,
      limiteStorageGb: firebaseFreeTierStorageGb,
      ristoranti: rows,
      dataRilevamento: now,
    );
  }
}
