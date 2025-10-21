import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'GameBoard.dart';

class ChessIntroScreen extends StatelessWidget {
  const ChessIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> buttons = [
      {
        'label': 'Classic',
        'icon': Icons.people_alt_rounded,
        'color': Colors.deepOrangeAccent,
        'flags': const {},
        'description': 'It\'s just normal chess bro',
      },
      {
        'label': 'Fischer Random',
        'icon': Icons.shuffle_rounded,
        'color': Colors.blueGrey,
        'flags': const {'isFischer': true},
        'description': 'The initial position of the pieces on the first and eighth ranks is randomized, with 960 possible starting layouts.',
      },
      {
        'label': 'King of the Hill',
        'icon': Icons.terrain_rounded,
        'color': Colors.teal,
        'flags': const {'isKingHill': true},
        'description': 'Standard rules but you can win by moving your King to any of the four center squares (d4, e4, d5, e5).',
      },
      {
        'label': 'No Castling',
        'icon': Icons.block,
        'color': Colors.redAccent,
        'flags': const {'isNoCastling': true},
        'description': 'The game follows all standard rules except that the castling move is not allowed.',
      },
      {
        'label': 'Three Check',
        'icon': Icons.looks_3_rounded,
        'color': Colors.indigo,
        'flags': const {'isThreeCheck': true},
        'description': 'The first player to deliver a check to the opponent\'s King a total of three times wins the game.',
      },
      {
        'label': 'Timed (10 min)',
        'icon': Icons.timer_rounded,
        'color': Colors.pink,
        'flags': const {'isTimed': true},
        'description': 'Normal chess but 10 Minutes for each side.',
      },
    ];

    return SafeArea(
      child: Scaffold(
        backgroundColor: const Color(0xFF1E1E1E),
        body: Stack(
          children: [
            Positioned.fill(
              child: Opacity(
                opacity: 0.1,
                child: Image.asset('assets/chess_bg.jpg', fit: BoxFit.cover),
              ),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    ShaderMask(
                      shaderCallback: (r) => const LinearGradient(
                        colors: [Color(0xFFFFB300), Color(0xFFE65100)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ).createShader(r),
                      child: Text(
                        "♟️ YOUNIS CHESS",
                        textAlign: TextAlign.center,
                        style: GoogleFonts.playfairDisplay(
                          fontSize: 40,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 2.0,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      "Choose your variant and challenge the game!",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        color: Colors.white54,
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(height: 40),
                    Expanded(
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        itemCount: buttons.length,
                        itemBuilder: (context, i) {
                          final btn = buttons[i];
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: _VariantButton(
                              label: btn['label'] as String,
                              icon: btn['icon'] as IconData,
                              color: btn['color'] as Color,
                              description: btn['description'] as String, // Pass description
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => GameBoard(
                                    isFischer: btn['flags']['isFischer'] ?? false,
                                    isKingHill: btn['flags']['isKingHill'] ?? false,
                                    isNoCastling: btn['flags']['isNoCastling'] ?? false,
                                    isThreeCheck: btn['flags']['isThreeCheck'] ?? false,
                                    isTimed: btn['flags']['isTimed'] ?? false,
                                  ),
                                ));
                              },
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      "© 2025 Younis Chess",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(color: Colors.grey.shade700, fontSize: 13),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VariantButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final String description; // New field for description
  final VoidCallback onTap;

  const _VariantButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.description, // Required in constructor
    required this.onTap,
  });

  // Helper method to show the detailed explanation
  void _showDescription(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return SafeArea(
          child: Container(
            decoration: const BoxDecoration(
              color: Color(0xFF282828),
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Icon(icon, color: color, size: 32),
                    const SizedBox(width: 16),
                    Text(
                      label,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.white12, height: 28),
                Text(
                  description,
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: Colors.white70,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: onTap,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      'START GAME',
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () => _showDescription(context),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.5), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const Icon(Icons.info_outline, color: Colors.white38, size: 16), // Hint for long press
          ],
        ),
      ),
    );
  }
}
