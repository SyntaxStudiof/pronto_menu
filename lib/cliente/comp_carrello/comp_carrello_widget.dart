import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'comp_carrello_model.dart';
export 'comp_carrello_model.dart';

class CompCarrelloWidget extends StatefulWidget {
  const CompCarrelloWidget({super.key});

  @override
  State<CompCarrelloWidget> createState() => _CompCarrelloWidgetState();
}

class _CompCarrelloWidgetState extends State<CompCarrelloWidget> {
  late CompCarrelloModel _model;

  @override
  void setState(VoidCallback callback) {
    super.setState(callback);
    _model.onUpdate();
  }

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => CompCarrelloModel());

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

    return Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 15.0, 0.0),
      child: badges.Badge(
        badgeContent: Text(
          FFAppState().Carrello.length.toString(),
          style: FlutterFlowTheme.of(context).titleSmall.override(
                font: GoogleFonts.outfit(
                  fontWeight:
                      FlutterFlowTheme.of(context).titleSmall.fontWeight,
                  fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
                ),
                color: FFAppState().temaPrimaryText,
                letterSpacing: 0.0,
                fontWeight: FlutterFlowTheme.of(context).titleSmall.fontWeight,
                fontStyle: FlutterFlowTheme.of(context).titleSmall.fontStyle,
              ),
        ),
        showBadge: true,
        shape: badges.BadgeShape.circle,
        badgeColor: FFAppState().temaTertiary,
        elevation: 4.0,
        padding: EdgeInsetsDirectional.fromSTEB(8.0, 8.0, 8.0, 8.0),
        position: badges.BadgePosition.topEnd(),
        animationType: badges.BadgeAnimationType.scale,
        toAnimate: true,
        child: Padding(
          padding: EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 5.0, 0.0),
          child: Icon(
            Icons.shopping_cart_outlined,
            color: FFAppState().temaPrimary,
            size: 24.0,
          ),
        ),
      ),
    );
  }
}
