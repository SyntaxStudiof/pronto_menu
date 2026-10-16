import 'package:flutter/material.dart';
import '/backend/schema/util/allergeni_data.dart';
import '/services/translation_service.dart';

class ModalFiltroAllergeniWidget extends StatefulWidget {
  const ModalFiltroAllergeniWidget({
    super.key,
    required this.allergeniIniziali,
    this.allergeniPresentiNelMenu,
    required this.onApplica,
    this.currentLang = 'it',
  });

  final Set<String> allergeniIniziali;
  final Set<String>? allergeniPresentiNelMenu;
  final ValueChanged<Set<String>> onApplica;
  final String currentLang;

  static Future<void> show({
    required BuildContext context,
    required Set<String> allergeniIniziali,
    Set<String>? allergeniPresentiNelMenu,
    required ValueChanged<Set<String>> onApplica,
    String currentLang = 'it',
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      builder: (context) => ModalFiltroAllergeniWidget(
        allergeniIniziali: allergeniIniziali,
        allergeniPresentiNelMenu: allergeniPresentiNelMenu,
        onApplica: onApplica,
        currentLang: currentLang,
      ),
    );
  }

  @override
  State<ModalFiltroAllergeniWidget> createState() =>
      _ModalFiltroAllergeniWidgetState();
}

class _ModalFiltroAllergeniWidgetState
    extends State<ModalFiltroAllergeniWidget>
    with SingleTickerProviderStateMixin {
  late Set<String> _selezionati;
  late AnimationController _animController;
  late Animation<double> _scaleAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _selezionati = Set<String>.from(widget.allergeniIniziali);

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 380),
    );

    _scaleAnimation = Tween<double>(begin: 0.94, end: 1.0).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.15),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _toggleAllergene(String id) {
    setState(() {
      if (_selezionati.contains(id)) {
        _selezionati.remove(id);
      } else {
        _selezionati.add(id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return SlideTransition(
      position: _slideAnimation,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.85,
            maxWidth: 620.0,
          ),
          margin: EdgeInsets.only(
            top: MediaQuery.paddingOf(context).top + 20.0,
          ),
          decoration: BoxDecoration(
            color: theme.cardColor,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(28.0),
              topRight: Radius.circular(28.0),
            ),
            boxShadow: [
              BoxShadow(
                blurRadius: 30.0,
                color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.15),
                offset: const Offset(0, -6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle per il drag
              Center(
                child: Container(
                  width: 44.0,
                  height: 4.5,
                  margin: const EdgeInsets.only(top: 12.0, bottom: 8.0),
                  decoration: BoxDecoration(
                    color: theme.dividerColor.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                ),
              ),

              // Header del modale
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 6.0, 16.0, 10.0),
                child: Row(
                  children: [
                    Container(
                      width: 40.0,
                      height: 40.0,
                      decoration: BoxDecoration(
                        color: Colors.deepOrange.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.shield_outlined,
                        color: Colors.deepOrange,
                        size: 22.0,
                      ),
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            TranslationService.getUi(
                                'escludi_allergeni', widget.currentLang),
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 18.0,
                            ),
                          ),
                          Text(
                            TranslationService.getUi(
                                'nascondi_piatti_allergeni',
                                widget.currentLang),
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.hintColor,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (_selezionati.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _selezionati.clear();
                          });
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        ),
                        child: Text(
                          TranslationService.getUi(
                              'azzera', widget.currentLang),
                          style: const TextStyle(
                            fontSize: 13.0,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    IconButton(
                      icon: const Icon(Icons.close_rounded, size: 22.0),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),

              Divider(
                height: 1.0,
                thickness: 1.0,
                color: theme.dividerColor.withValues(alpha: 0.2),
              ),

              // Banner informativo
              Container(
                margin: const EdgeInsets.fromLTRB(18.0, 12.0, 18.0, 8.0),
                padding: const EdgeInsets.symmetric(
                    horizontal: 12.0, vertical: 8.0),
                decoration: BoxDecoration(
                  color: Colors.orange.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(
                    color: Colors.orange.withValues(alpha: 0.3),
                    width: 1.0,
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline,
                        color: Colors.orange, size: 18.0),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: Text(
                        (widget.allergeniPresentiNelMenu != null &&
                                widget.allergeniPresentiNelMenu!.isNotEmpty)
                            ? TranslationService.getUi(
                                'allergeni_presenti_menu',
                                widget.currentLang)
                            : TranslationService.getUi(
                                'allergeni_alimentari',
                                widget.currentLang),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: isDark ? Colors.orange.shade200 : Colors.orange.shade900,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Lista degli allergeni scrollabile
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16.0, 8.0, 16.0, 16.0),
                  child: Wrap(
                    spacing: 8.0,
                    runSpacing: 8.0,
                    children: ((widget.allergeniPresentiNelMenu != null &&
                                widget.allergeniPresentiNelMenu!.isNotEmpty)
                            ? AllergeniData.allergeniObbligatori.where((all) =>
                                widget.allergeniPresentiNelMenu!.contains(all.id) ||
                                widget.allergeniPresentiNelMenu!.any((p) =>
                                    p == all.id ||
                                    p.contains(all.id) ||
                                    all.id.contains(p))).toList()
                            : AllergeniData.allergeniObbligatori)
                        .map((allergene) {
                      final isSelected = _selezionati.contains(allergene.id);
                      return InkWell(
                        onTap: () => _toggleAllergene(allergene.id),
                        borderRadius: BorderRadius.circular(14.0),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 220),
                          curve: Curves.easeOutCubic,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12.0, vertical: 10.0),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? Colors.deepOrange.withValues(alpha: 0.14)
                                : theme.scaffoldBackgroundColor,
                            borderRadius: BorderRadius.circular(14.0),
                            border: Border.all(
                              color: isSelected
                                  ? Colors.deepOrange
                                  : theme.dividerColor.withValues(alpha: 0.3),
                              width: isSelected ? 1.8 : 1.0,
                            ),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: Colors.deepOrange
                                          .withValues(alpha: 0.15),
                                      blurRadius: 8.0,
                                      offset: const Offset(0, 2),
                                    ),
                                  ]
                                : [],
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                allergene.emoji,
                                style: const TextStyle(fontSize: 16.0),
                              ),
                              const SizedBox(width: 8.0),
                              Text(
                                TranslationService.getAllergeneLabel(
                                    allergene.id, widget.currentLang),
                                style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? Colors.deepOrange
                                      : theme.textTheme.bodyMedium?.color,
                                  fontSize: 13.0,
                                ),
                              ),
                              const SizedBox(width: 6.0),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 200),
                                transitionBuilder: (child, anim) =>
                                    ScaleTransition(scale: anim, child: child),
                                child: isSelected
                                    ? Container(
                                        key: const ValueKey('selected'),
                                        padding: const EdgeInsets.all(2.0),
                                        decoration: const BoxDecoration(
                                          color: Colors.deepOrange,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.close_rounded,
                                          size: 13.0,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Container(
                                        key: const ValueKey('unselected'),
                                        width: 17.0,
                                        height: 17.0,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: theme.dividerColor,
                                            width: 1.5,
                                          ),
                                        ),
                                      ),
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),

              Divider(
                height: 1.0,
                thickness: 1.0,
                color: theme.dividerColor.withValues(alpha: 0.2),
              ),

              // Barra inferiore con tasto Applica
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 14.0, 20.0, 20.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selezionati.isEmpty
                            ? TranslationService.getUi(
                                'nessun_allergene_dichiarato',
                                widget.currentLang)
                            : '${_selezionati.length} ${TranslationService.getUi('allergeni_badge', widget.currentLang)} ${TranslationService.getUi('esclusi', widget.currentLang)}',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: _selezionati.isEmpty
                              ? theme.hintColor
                              : Colors.deepOrange,
                        ),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        widget.onApplica(_selezionati);
                        Navigator.of(context).pop();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 22.0, vertical: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14.0),
                        ),
                        elevation: 2.0,
                      ),
                      child: Text(
                        TranslationService.getUi(
                            'applica_filtri', widget.currentLang),
                        style: const TextStyle(
                          fontSize: 14.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
