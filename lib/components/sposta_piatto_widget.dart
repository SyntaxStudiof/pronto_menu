import '/auth/firebase_auth/auth_util.dart';
import '/backend/backend.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:provider/provider.dart';
import 'sposta_piatto_model.dart';
export 'sposta_piatto_model.dart';

class SpostaPiattoWidget extends StatefulWidget {
  const SpostaPiattoWidget({
    super.key,
    required this.piattoDaSpostare,
  });

  final DocumentReference? piattoDaSpostare;

  @override
  State<SpostaPiattoWidget> createState() => _SpostaPiattoWidgetState();
}

class _SpostaPiattoWidgetState extends State<SpostaPiattoWidget> {
  late SpostaPiattoModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => SpostaPiattoModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.maybeDispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<FFAppState>();
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.5,
      ),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20.0)),
      ),
      child: StreamBuilder<List<CategoriesRecord>>(
        stream: queryCategoriesRecord(
          queryBuilder: (categoriesRecord) => categoriesRecord.where(
            'proprietario',
            isEqualTo: currentUserReference,
          ),
        ),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: SizedBox(
                width: 36.0,
                height: 36.0,
                child: SpinKitPulse(
                  color: theme.colorScheme.primary,
                  size: 36.0,
                ),
              ),
            );
          }
          List<CategoriesRecord> listViewCategoriesRecordList = snapshot.data!;

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 12.0),
            shrinkWrap: true,
            scrollDirection: Axis.vertical,
            itemCount: listViewCategoriesRecordList.length,
            itemBuilder: (context, listViewIndex) {
              final listViewCategoriesRecord =
                  listViewCategoriesRecordList[listViewIndex];
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
                child: InkWell(
                  splashColor: Colors.transparent,
                  focusColor: Colors.transparent,
                  hoverColor: Colors.transparent,
                  highlightColor: Colors.transparent,
                  borderRadius: BorderRadius.circular(12.0),
                  onTap: () async {
                    await widget.piattoDaSpostare!
                        .update(createPiattiRecordData(
                      categoria: listViewCategoriesRecord.reference.id,
                    ));
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: double.infinity,
                    height: 48.0,
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(
                        color: theme.dividerColor.withValues(alpha: 0.15),
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      listViewCategoriesRecord.name,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
