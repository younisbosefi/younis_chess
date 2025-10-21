import 'dart:async';

import 'package:chess/chess.dart' as Chess;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wp_chessboard/wp_chessboard.dart';
import 'package:younis_chess/ChessPiece.dart';
import 'package:younis_chess/helperMethods.dart';

class GameBoard extends StatefulWidget {
  final bool isFischer;
  final bool isKingHill;
  final bool isNoCastling;
  final bool isThreeCheck;
  final bool isTimed;
  const GameBoard({
    super.key,
    this.isFischer = false,
    this.isKingHill = false,
    this.isNoCastling = false,
    this.isThreeCheck = false,
    this.isTimed = false,
  });
  @override
  State<GameBoard> createState() => _GameBoardState();
}

class _GameBoardState extends State<GameBoard> with TickerProviderStateMixin {
  final controller = WPChessboardController();
  Chess.Chess chess = Chess.Chess();
  List<List<int>>? lastMove;
  List<String> moveHistory = [];
  List<String> capturedWhitePieces = [];
  List<String> capturedBlackPieces = [];
  bool isWhiteTurn = true;
  late AnimationController _checkAnimationController;
  late Animation<double> _checkAnimation;
  String? kingInCheckSquare;
  int whiteChecks = 0;
  int blackChecks = 0;
  int moveCount = 0;
  Timer? whiteTimer;
  Timer? blackTimer;
  int whiteTime = 600;
  int blackTime = 600;

  @override
  void initState() {
    super.initState();
    _initAnimation();
    restartGame();
  }

  @override
  void dispose() {
    _checkAnimationController.dispose();
    whiteTimer?.cancel();
    blackTimer?.cancel();
    super.dispose();
  }

  void _initAnimation() {
    _checkAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..repeat(reverse: true);
    _checkAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _checkAnimationController, curve: Curves.easeInOut),
    );
  }

  void _startTimers() {
    if (!widget.isTimed) return;
    whiteTimer?.cancel();
    blackTimer?.cancel();
    if (isWhiteTurn) {
      whiteTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        setState(() {
          whiteTime--;
          if (whiteTime <= 0) {
            t.cancel();
            showGameOverDialog(context: context, chess: chess, moveHistory: moveHistory, restartGame: restartGame);
          }
        });
      });
    } else {
      blackTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        setState(() {
          blackTime--;
          if (blackTime <= 0) {
            t.cancel();
            showGameOverDialog(context: context, chess: chess, moveHistory: moveHistory, restartGame: restartGame);
          }
        });
      });
    }
  }

  String generateFischerRandomFEN() {
    List<String> pieces = ['R', 'N', 'B', 'Q', 'K', 'B', 'N', 'R'];
    List<int> dark = [0, 2, 4, 6];
    List<int> light = [1, 3, 5, 7];
    int b1 = (dark..shuffle()).first;
    int b2 = (light..shuffle()).first;
    pieces[b1] = 'B';
    pieces[b2] = 'B';
    List<int> rem = List.generate(8, (i) => i)..removeWhere((i) => i == b1 || i == b2);
    int q = (rem..shuffle()).first;
    pieces[q] = 'Q';
    rem.remove(q);
    rem.shuffle();
    pieces[rem[0]] = 'N';
    pieces[rem[1]] = 'N';
    rem.removeRange(0, 2);
    pieces[rem[0]] = 'R';
    pieces[rem[1]] = 'K';
    pieces[rem[2]] = 'R';
    String back = pieces.join();
    String black = back.toLowerCase();
    return '$black/pppppppp/8/8/8/8/PPPPPPPP/$back w KQkq - 0 1';
  }

  void updateKingInCheckSquare() {
    kingInCheckSquare = chess.in_check ? _findKingInCheckSquare() : null;
  }

  String? _findKingInCheckSquare() {
    for (int r = 1; r <= 8; r++) {
      for (int f = 1; f <= 8; f++) {
        String sq = String.fromCharCode(96 + f) + r.toString();
        var piece = chess.get(sq);
        if (piece != null && piece.type == Chess.PieceType.KING && piece.color == chess.turn) {
          return sq;
        }
      }
    }
    return null;
  }

  Widget squareBuilder(SquareInfo info) {
    Color fieldColor = (info.index + info.rank) % 2 == 0 ? const Color(0xFFF0D9B5) : Colors.pink;
    Color overlayColor = Colors.transparent;
    bool isKingInCheck = kingInCheckSquare == info.toString();
    overlayColor = _getOverlayColor(info);
    return _buildSquare(fieldColor, overlayColor, info, isKingInCheck);
  }

  Color _getOverlayColor(SquareInfo info) {
    if (lastMove != null) {
      if (lastMove!.first.first == info.rank && lastMove!.first.last == info.file) {
        return const Color(0xFFCDD26A).withOpacity(0.6);
      } else if (lastMove!.last.first == info.rank && lastMove!.last.last == info.file) {
        return const Color(0xFFAAC34E).withOpacity(0.8);
      }
    }
    return Colors.transparent;
  }

  Widget _buildSquare(Color fieldColor, Color overlayColor, SquareInfo info, bool isKingInCheck) {
    if (isKingInCheck) {
      return buildKingInCheckSquare(checkAnimation: _checkAnimation, fieldColor: fieldColor, info: info);
    }
    return Container(color: fieldColor, width: info.size, height: info.size, child: overlayColor != Colors.transparent ? Container(color: overlayColor) : null);
  }

  void onPieceStartDrag(SquareInfo square, String piece) => showHintFields(square, piece);
  void onPieceTap(SquareInfo square, String piece) {
    if (controller.hints.key == square.index.toString()) {
      controller.setHints(HintMap());
      return;
    }
    showHintFields(square, piece);
  }

  void showHintFields(SquareInfo square, String piece) {
    final moves = chess.generate_moves({'square': square.toString()});
    final hintMap = HintMap(key: square.index.toString());
    for (var move in moves) {
      String to = move.toAlgebraic;
      int rank = to.codeUnitAt(1) - "1".codeUnitAt(0) + 1;
      int file = to.codeUnitAt(0) - "a".codeUnitAt(0) + 1;
      bool isCapture = move.captured != null;
      hintMap.set(rank, file, (size) => _buildHint(size, isCapture, move));
    }
    controller.setHints(hintMap);
  }

  Widget _buildHint(double size, bool isCapture, Chess.Move move) {
    return GestureDetector(
      onTap: () => doMove(move),
      child: Container(
        width: size,
        height: size,
        color: Colors.transparent,
        child: Center(
          child: Container(
            width: isCapture ? size * 0.75 : size * 0.25,
            height: isCapture ? size * 0.75 : size * 0.25,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCapture ? Colors.red.withOpacity(0.35) : Colors.black.withOpacity(0.2),
              border: isCapture ? Border.all(color: Colors.red.withOpacity(0.7), width: 2.5) : null,
            ),
          ),
        ),
      ),
    );
  }

  void onEmptyFieldTap(SquareInfo square) => controller.setHints(HintMap());
  void onPieceDrop(PieceDropEvent event) => _processMove(event.from.toString(), event.to.toString(), false);
  void doMove(Chess.Move move) => _processMove(move.fromAlgebraic, move.toAlgebraic, true);
  void _processMove(String from, String to, bool animate) {
    var targetPiece = chess.get(to);
    var result = chess.move({"from": from, "to": to, "promotion": "q"});
    if (result != null && result) {
      lastMove = [
        [_rank(from), _file(from)],
        [_rank(to), _file(to)]
      ];
      _updateMoveResult(from, to, targetPiece);
      update(animated: animate);
    }
  }

  int _rank(String pos) => pos.codeUnitAt(1) - 48;
  int _file(String pos) => pos.codeUnitAt(0) - 96;

  void _updateMoveResult(String from, String to, Chess.Piece? capturedPiece) {
    if (widget.isKingHill) {
      const center = ['d4', 'e4', 'd5', 'e5'];
      for (var sq in center) {
        var p = chess.get(sq);
        if (p != null && p.type == Chess.PieceType.KING) {
          Future.delayed(const Duration(milliseconds: 300), () => showGameOverDialog(context: context, chess: chess, moveHistory: moveHistory, restartGame: restartGame));
          return;
        }
      }
    }

    if (chess.in_check) {
      if (chess.turn == Chess.Color.WHITE)
        blackChecks++;
      else
        whiteChecks++;
      if (widget.isThreeCheck && (whiteChecks >= 3 || blackChecks >= 3)) {
        Future.delayed(const Duration(milliseconds: 300), () => showGameOverDialog(context: context, chess: chess, moveHistory: moveHistory, restartGame: restartGame));
        return;
      }
    }

    var history = chess.getHistory({'verbose': true});
    if (history.isNotEmpty) {
      var lastMove = history.last;
      String moveNotation = lastMove['san'] ?? '$from-$to';
      moveHistory.add(moveNotation);
    }

    if (capturedPiece != null) {
      String pieceType = capturedPiece.type.toString().split('.').last.toUpperCase();
      (capturedPiece.color == Chess.Color.WHITE ? capturedWhitePieces : capturedBlackPieces).add(pieceType);
    }

    moveCount++;
    isWhiteTurn = !isWhiteTurn;

    updateKingInCheckSquare();
    if (chess.game_over) {
      Future.delayed(const Duration(milliseconds: 300), () => showGameOverDialog(context: context, chess: chess, moveHistory: moveHistory, restartGame: restartGame));
    }
    _startTimers();
  }

  void restartGame() {
    setState(() {
      if (widget.isFischer) {
        chess = Chess.Chess.fromFEN(generateFischerRandomFEN());
      } else if (widget.isNoCastling) {
        chess = Chess.Chess.fromFEN('rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w - - 0 1');
      } else {
        chess = Chess.Chess();
      }
      lastMove = null;
      moveHistory.clear();
      capturedWhitePieces.clear();
      capturedBlackPieces.clear();
      isWhiteTurn = true;
      kingInCheckSquare = null;
      whiteChecks = 0;
      blackChecks = 0;
      moveCount = 0;
      whiteTime = 600;
      blackTime = 600;
    });
    controller.setHints(HintMap());
    update();
    _startTimers();
  }

  void undoMove() {
    if (chess.undo_move() != null) {
      setState(() {
        if (moveHistory.isNotEmpty) moveHistory.removeLast();
        isWhiteTurn = !isWhiteTurn;
        lastMove = null;
        updateKingInCheckSquare();
      });
      controller.setHints(HintMap());
      update();
    }
  }

  void update({bool animated = true}) {
    setState(() => controller.setFen(chess.fen, animation: animated));
  }

  BoardOrientation orientation = BoardOrientation.white;
  void flipBoard() {
    setState(() {
      orientation = orientation == BoardOrientation.white ? BoardOrientation.black : BoardOrientation.white;
    });
  }

  String formatTime(int timeInSeconds) {
    final minutes = (timeInSeconds ~/ 60).toString();
    final seconds = (timeInSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final double boardSize = MediaQuery.of(context).size.shortestSide * 0.9;
    final bool isWhiteBottom = orientation == BoardOrientation.white;

    Widget buildPlayerInfo({
      required String time,
      required List<String> captured,
      required bool isTurn,
    }) {
      return AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isTurn ? const Color(0xFF2B2927) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isTurn ? Colors.amber.withOpacity(0.7) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: buildCapturedPieces(pieces: captured, isWhite: !isWhiteBottom),
            ),
            const SizedBox(width: 12),
            if (widget.isTimed)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF262522),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  time,
                  style: GoogleFonts.robotoMono(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
          ],
        ),
      );
    }

    Widget buildControlButton({
      required IconData icon,
      required String title,
      required VoidCallback? onPressed,
    }) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: onPressed,
            icon: Icon(icon, color: Colors.white70, size: 26),
            style: IconButton.styleFrom(
              backgroundColor: const Color(0xFF3D3A36),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.all(14),
              side: BorderSide(color: Colors.white.withOpacity(0.1)),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withOpacity(0.6),
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      );
    }

    return MaterialApp(
      title: 'Chess',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.amber,
        scaffoldBackgroundColor: const Color(0xFF312E2B),
        textTheme: GoogleFonts.poppinsTextTheme(ThemeData.dark().textTheme),
      ),
      home: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                buildPlayerInfo(
                  time: formatTime(isWhiteBottom ? blackTime : whiteTime),
                  captured: isWhiteBottom ? capturedBlackPieces : capturedWhitePieces,
                  isTurn: isWhiteBottom ? !isWhiteTurn : isWhiteTurn,
                ),
                const Spacer(),
                Container(
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 25,
                        spreadRadius: 2,
                      ),
                    ],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: WPChessboard(
                      size: boardSize,
                      orientation: orientation,
                      squareBuilder: squareBuilder,
                      controller: controller,
                      onPieceDrop: onPieceDrop,
                      onPieceTap: onPieceTap,
                      onPieceStartDrag: onPieceStartDrag,
                      onEmptyFieldTap: onEmptyFieldTap,
                      turnTopPlayerPieces: false,
                      ghostOnDrag: true,
                      dropIndicator: DropIndicatorArgs(
                        size: boardSize / 4,
                        color: Colors.black.withOpacity(0.35),
                      ),
                      pieceMap: PieceMap(
                        K: (size) => Piece(path: "assets/chessPieces/wK.svg"),
                        Q: (size) => Piece(path: "assets/chessPieces/wQ.svg"),
                        B: (size) => Piece(path: "assets/chessPieces/wB.svg"),
                        N: (size) => Piece(path: "assets/chessPieces/wN.svg"),
                        R: (size) => Piece(path: "assets/chessPieces/wR.svg"),
                        P: (size) => Piece(path: "assets/chessPieces/wP.svg"),
                        k: (size) => Piece(path: "assets/chessPieces/bK.svg"),
                        q: (size) => Piece(path: "assets/chessPieces/bQ.svg"),
                        b: (size) => Piece(path: "assets/chessPieces/bB.svg"),
                        n: (size) => Piece(path: "assets/chessPieces/bN.svg"),
                        r: (size) => Piece(path: "assets/chessPieces/bR.svg"),
                        p: (size) => Piece(path: "assets/chessPieces/bP.svg"),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                buildPlayerInfo(
                  time: formatTime(isWhiteBottom ? whiteTime : blackTime),
                  captured: isWhiteBottom ? capturedWhitePieces : capturedBlackPieces,
                  isTurn: isWhiteBottom ? isWhiteTurn : !isWhiteTurn,
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    buildControlButton(icon: Icons.sync, onPressed: restartGame, title: "New"),
                    buildControlButton(icon: Icons.undo, onPressed: undoMove, title: "Undo"),
                    buildControlButton(icon: Icons.flip_camera_android, onPressed: flipBoard, title: "Flip"),
                    buildControlButton(
                      icon: Icons.history,
                      title: "History",
                      onPressed: () => showMoveHistory(context: context, moveHistory: moveHistory),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
