import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';

class TrisGameModel extends FlutterFlowModel {
  // Tab Controller
  late TabController tabController;
  int currentTabIndex = 0;

  // Local Pass & Play Game State
  List<String> localBoard = List.filled(9, '');
  String localTurn = 'X';
  int scoreX = 0;
  int scoreO = 0;
  int draws = 0;
  String? localWinner;
  List<int>? winningLine;
  bool vsBot = false;

  // Online Multiplayer State
  String? currentMatchId;
  String? myTableNumber;
  TextEditingController? tableInputController;
  FocusNode? tableInputFocusNode;

  @override
  void initState(BuildContext context) {}

  @override
  void dispose() {
    tableInputController?.dispose();
    tableInputFocusNode?.dispose();
  }
}
