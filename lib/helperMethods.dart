import 'dart:ui';

import 'package:chess/chess.dart' as Chess;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wp_chessboard/wp_chessboard.dart';
import 'package:younis_chess/ChessPiece.dart';

void showGameOverDialog({
  required BuildContext context,
  required Chess.Chess chess,
  required List<String> moveHistory,
  required Function restartGame,
}) {
  final String title;
  final String message;
  final IconData icon;
  final Color accentColor;
  final List<Color> gradientColors;

  if (chess.in_checkmate) {
    final winner = chess.turn == Chess.Color.WHITE ? 'Black' : 'White';
    title = 'Checkmate!';
    message = '$winner reigns victorious.';
    icon = Icons.workspace_premium;
    accentColor = const Color(0xFFFFC107);
    gradientColors = [const Color(0xFF424242), const Color(0xFF212121)];
  } else if (chess.in_stalemate) {
    title = 'Stalemate';
    message = 'A hard-fought draw.';
    icon = Icons.handshake;
    accentColor = const Color(0xFF607D8B);
    gradientColors = [const Color(0xFF4A5A62), const Color(0xFF38444A)];
  } else if (chess.in_threefold_repetition) {
    title = 'Draw';
    message = 'By threefold repetition.';
    icon = Icons.repeat;
    accentColor = const Color(0xFF7E57C2);
    gradientColors = [const Color(0xFF53437D), const Color(0xFF403360)];
  } else if (chess.insufficient_material) {
    title = 'Draw';
    message = 'Due to insufficient material.';
    icon = Icons.balance;
    accentColor = const Color(0xFF26A69A);
    gradientColors = [const Color(0xFF2E7D75), const Color(0xFF215B55)];
  } else {
    title = 'Game Over';
    message = 'The game has ended.';
    icon = Icons.flag_rounded;
    accentColor = Colors.grey.shade600;
    gradientColors = [const Color(0xFF424242), const Color(0xFF212121)];
  }

  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'Game Over',
    transitionDuration: const Duration(milliseconds: 500),
    pageBuilder: (context, _, __) => const SizedBox.shrink(),
    transitionBuilder: (context, anim1, anim2, child) {
      return BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8 * anim1.value, sigmaY: 8 * anim1.value),
        child: ScaleTransition(
          scale: CurvedAnimation(parent: anim1, curve: Curves.elasticOut),
          child: Dialog(
            elevation: 0,
            backgroundColor: Colors.transparent,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: gradientColors,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.1)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: accentColor.withOpacity(0.15),
                      child: Icon(icon, color: accentColor, size: 36),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      title,
                      style: GoogleFonts.poppins(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: GoogleFonts.lato(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Divider(color: Colors.white.withOpacity(0.2)),
                    const SizedBox(height: 16),
                    Text(
                      'Total Moves: ${moveHistory.length}',
                      style: GoogleFonts.lato(
                        fontSize: 14,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              side: BorderSide(color: accentColor.withOpacity(0.5)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: Text(
                              'Close',
                              style: GoogleFonts.poppins(
                                color: Colors.white.withOpacity(0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).pop();
                              restartGame();
                            },
                            icon: const Icon(Icons.refresh, color: Colors.black, size: 20),
                            label: Text(
                              'New Game',
                              style: GoogleFonts.poppins(
                                color: Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: accentColor,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 5,
                              shadowColor: accentColor.withOpacity(0.5),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget buildKingInCheckSquare({required Color fieldColor, required SquareInfo info, required Animation<double> checkAnimation}) {
  return Container(
    decoration: BoxDecoration(
      color: fieldColor,
      border: Border.all(color: Colors.red, width: 4),
      boxShadow: [
        BoxShadow(
          color: Colors.red.withOpacity(0.6),
          blurRadius: 15,
          spreadRadius: 2,
        ),
      ],
    ),
    width: info.size,
    height: info.size,
    child: AnimatedBuilder(
      animation: checkAnimation,
      builder: (context, child) => Container(
        color: Colors.red.withOpacity(checkAnimation.value),
        width: info.size,
        height: info.size,
      ),
    ),
  );
}

Widget buildCapturedPieces({required List<String> pieces, required bool isWhite}) {
  if (pieces.isEmpty) return const SizedBox(height: 30);
  Map<String, int> pieceCounts = {};
  for (var piece in pieces) {
    pieceCounts[piece] = (pieceCounts[piece] ?? 0) + 1;
  }
  return Container(
    height: 30,
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Row(
      children: pieceCounts.entries.map((entry) {
        return Row(
          children: [
            SizedBox(
              width: 24,
              height: 24,
              child: Piece(
                path: "assets/chessPieces/${isWhite ? 'w' : 'b'}${entry.key.toUpperCase()}.svg",
              ),
            ),
            if (entry.value > 1)
              Text(
                'x${entry.value}',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
            const SizedBox(width: 4),
          ],
        );
      }).toList(),
    ),
  );
}

Widget buildControlButton({required IconData icon, required String label, required Color color, required VoidCallback onPressed}) {
  return ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 5,
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 24, color: Colors.white),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
      ],
    ),
  );
}

void showMoveHistory({required BuildContext context, required List<String> moveHistory}) {
  showDialog(
    context: context,
    builder: (_) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Row(children: [Icon(Icons.history, color: Colors.purple), SizedBox(width: 10), Text('Move History')]),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: moveHistory.isEmpty
            ? const Center(child: Text('No moves yet!'))
            : ListView.builder(
                itemCount: (moveHistory.length / 2).ceil(),
                itemBuilder: (_, index) {
                  int moveNumber = index + 1;
                  String whiteMove = moveHistory[index * 2];
                  String blackMove = index * 2 + 1 < moveHistory.length ? moveHistory[index * 2 + 1] : '';
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: CircleAvatar(backgroundColor: Colors.purple, child: Text('$moveNumber', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                      title: Row(
                        children: [
                          Expanded(child: Text(whiteMove, style: const TextStyle(fontWeight: FontWeight.bold))),
                          if (blackMove.isNotEmpty) Expanded(child: Text(blackMove, style: const TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.end)),
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
    ),
  );
}

String generateFischerRandomFEN() {
  List<String> pieces = ['R', 'N', 'B', 'Q', 'K', 'B', 'N', 'R'];

  // Shuffle bishops to opposite-colored squares
  List<int> darkSquares = [0, 2, 4, 6];
  List<int> lightSquares = [1, 3, 5, 7];
  int b1 = (darkSquares..shuffle()).first;
  int b2 = (lightSquares..shuffle()).first;
  pieces[b1] = 'B';
  pieces[b2] = 'B';

  // Place the queen in a random remaining square
  List<int> remaining = List.generate(8, (i) => i)..removeWhere((i) => i == b1 || i == b2);
  int q = (remaining..shuffle()).first;
  pieces[q] = 'Q';
  remaining.remove(q);

  // Place the knights randomly in remaining squares
  remaining.shuffle();
  pieces[remaining[0]] = 'N';
  pieces[remaining[1]] = 'N';
  remaining.removeRange(0, 2);

  // The remaining squares get rooks and king (R K R order)
  pieces[remaining[0]] = 'R';
  pieces[remaining[1]] = 'K';
  pieces[remaining[2]] = 'R';

  String backRank = pieces.join();
  String pawns = 'PPPPPPPP';
  String empty = '8';
  String blackBackRank = backRank.toLowerCase();

  // Build full FEN for Fischer Random
  return '$blackBackRank/pppppppp/8/8/8/8/PPPPPPPP/$backRank w KQkq - 0 1';
}
