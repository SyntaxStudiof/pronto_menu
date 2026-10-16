# Linee Guida di Sviluppo & Design System - ProntoMenu

Questo documento definisce gli standard architetturali e grafici da seguire per ogni nuova pagina o modifica all'interno di questo progetto Flutter.

---

## 1. Standard per l'AppBar delle Pagine

Tutte le pagine secondarie / interne (con pulsante indietro) devono seguire rigorosamente questo pattern visuale uniforme:

### Proprietà dell'AppBar:
- `elevation: 0.0`
- `centerTitle: true`
- `automaticallyImplyLeading: false`

### Leading (Pulsante Indietro):
```dart
leading: FlutterFlowIconButton(
  borderColor: Colors.transparent,
  borderRadius: 24.0,
  borderWidth: 1.0,
  buttonSize: 40.0,
  icon: Icon(
    Icons.arrow_back_rounded,
    color: theme.colorScheme.onSurface,
    size: 24.0,
  ),
  onPressed: () async {
    context.safePop();
  },
),
```

### Title (Badge con Icona + Testo Centrato):
Il titolo deve essere racchiuso in una `Row(mainAxisSize: MainAxisSize.min)` per consentire il perfetto centraggio di icona e testo:
```dart
title: Row(
  mainAxisSize: MainAxisSize.min,
  children: [
    Container(
      width: 36.0,
      height: 36.0,
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(10.0),
      ),
      alignment: Alignment.center,
      child: Icon(
        <IconaDellaSchermata>, // es. Icons.settings_rounded, Icons.person_rounded, ecc.
        color: theme.colorScheme.primary,
        size: 20.0,
      ),
    ),
    const SizedBox(width: 10.0),
    Text(
      '<Nome Pagina>',
      style: theme.appBarTheme.titleTextStyle ??
          theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 19.0, // 18.0 - 20.0 in base alla lunghezza del testo
            letterSpacing: -0.4,
            color: theme.colorScheme.onSurface,
          ),
    ),
  ],
),
```

### Bilanciamento Simmetrico (Actions):
Poiché la barra ha un `leading` a sinistra (~48px), per garantire che il titolo sia perfettamente al centro geometrico dello schermo:
- Se la pagina **non** ha pulsanti di azione a destra:
  ```dart
  actions: const [
    SizedBox(width: 48.0),
  ],
  ```
- Se la pagina **ha** un pulsante a destra (es. aggiungi con `IconButton` ~48px): posizionarlo normalmente in `actions`, fungerà già da bilanciatore.

---

## 2. Pagine già allineate allo standard
- **Il mio Profilo**: `Icons.person_rounded`
- **Cestino**: `Icons.delete_outline_rounded`
- **QR Code Menu**: `Icons.qr_code_2_rounded`
- **Impostazioni**: `Icons.settings_rounded`
- **Personalizzazione**: `Icons.palette_rounded`
- **Ordina categorie**: `Icons.format_list_bulleted_rounded`
- **Gestione sottocategorie**: `Icons.account_tree_rounded`
- **Gestisci abbonamento**: `Icons.workspace_premium_rounded`
- **Informativa privacy**: `Icons.shield_rounded`
- **Supporto**: `Icons.help_outline_rounded`
- **Dashboard Admin**: `Icons.admin_panel_settings_rounded`
- **Supporto clienti (Ticket Admin)**: `Icons.support_agent_rounded`

---

## 3. Regole UI & Layout Ricorrenti
- **QR Code Menu**: Utilizza rendering vettoriale nativo tramite `QrImageView` (`qr_flutter`) puntando al link dinamico del ristorante:
  `https://prontomenu-6d485.web.app/loaderMenu?ristoranteRef=$currentUserUid`.
- **ParentDataWidget**: Non avvolgere i testi/etichette dentro `Flexible` o `Expanded` all'interno dei pulsanti `.icon` (`ElevatedButton.icon`, `OutlinedButton.icon`), poiché Flutter gestisce già internamente il wrapping del label.
- **Colori & Trasparenze**: Utilizzare sempre `color.withValues(alpha: ...)` conforme alle ultime versioni di Flutter invece del deprecato `.withOpacity()`.
