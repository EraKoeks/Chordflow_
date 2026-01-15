import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// ------------------------------------------------------------
/// ChordFlow – SongViewer PREVIEW
/// ------------------------------------------------------------
/// ⚠️ This is a DEMO / PREVIEW file.
/// No storage, no services, no backend.
/// Shared for portfolio & showcase purposes only.
/// ------------------------------------------------------------

class SongViewerPreview extends StatefulWidget {
  const SongViewerPreview({super.key});

  @override
  State<SongViewerPreview> createState() => _SongViewerPreviewState();
}

class _SongViewerPreviewState extends State<SongViewerPreview> {
  // ---------------- DEMO SONG ----------------
  final String rawSong = '''
[Verse]
[C]Above all [G]powers
Above all [Am]kings
Above all the [F]created things

[Chorus]
[C]Crucified, laid be[G]hind the stone
[Am]You lived to die, re[F]jected and alone
''';

  int transpose = 0;
  double fontSize = 20;
  double scrollSpeed = 25;
  bool isScrolling = false;

  final ScrollController scrollController = ScrollController();
  Timer? scrollTimer;

  // ---------------- TRANSPOSE ENGINE (PREVIEW) ----------------
  static const _scale = ['C','C#','D','D#','E','F','F#','G','G#','A','A#','B'];

  String transposeText(String text, int steps) {
    return text.replaceAllMapped(
      RegExp(r'\[([A-G][#b]?m?)\]'),
      (m) {
        final chord = m.group(1)!;
        final isMinor = chord.endsWith('m');
        final base = isMinor ? chord.substring(0, chord.length - 1) : chord;

        final index = _scale.indexOf(base);
        if (index == -1) return m.group(0)!;

        final newIndex = (index + steps) % _scale.length;
        final newChord = _scale[newIndex < 0 ? newIndex + _scale.length : newIndex];
        return '[${newChord}${isMinor ? 'm' : ''}]';
      },
    );
  }

  // ---------------- AUTO SCROLL ----------------
  void startScroll() {
    if (isScrolling) return;
    isScrolling = true;

    scrollTimer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (!scrollController.hasClients) return;

      final next = scrollController.offset + (scrollSpeed / 10);
      if (next >= scrollController.position.maxScrollExtent) {
        stopScroll();
        return;
      }
      scrollController.jumpTo(next);
    });

    setState(() {});
  }

  void stopScroll() {
    scrollTimer?.cancel();
    isScrolling = false;
    setState(() {});
  }

  @override
  void dispose() {
    scrollTimer?.cancel();
    super.dispose();
  }

  // ---------------- UI ----------------
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF0D0F12) : Colors.white;
    final lyricColor = isDark ? Colors.white : Colors.black;
    final chordColor = isDark ? const Color(0xFF4FE1FF) : Colors.blueAccent;

    final display = transposeText(rawSong, transpose);
    final lines = display.split('\n');

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        title: const Text('ChordFlow Preview'),
        centerTitle: true,
      ),

      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton.small(
            heroTag: 'up',
            onPressed: () => setState(() => transpose++),
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'down',
            onPressed: () => setState(() => transpose--),
            child: const Icon(Icons.remove),
          ),
          const SizedBox(height: 8),
          FloatingActionButton.small(
            heroTag: 'scroll',
            backgroundColor: isScrolling ? Colors.red : Colors.green,
            onPressed: isScrolling ? stopScroll : startScroll,
            child: Icon(isScrolling ? Icons.stop : Icons.play_arrow),
          ),
        ],
      ),

      body: Column(
        children: [
          _slider('Font Size', fontSize, 14, 30,
              (v) => setState(() => fontSize = v)),
          _slider('Scroll Speed', scrollSpeed, 10, 60,
              (v) => setState(() => scrollSpeed = v)),

          Expanded(
            child: ListView.builder(
              controller: scrollController,
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 40),
              itemCount: lines.length,
              itemBuilder: (_, i) =>
                  _renderLine(lines[i], chordColor, lyricColor),
            ),
          ),
        ],
      ),
    );
  }

  Widget _slider(
    String label,
    double value,
    double min,
    double max,
    ValueChanged<double> onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          Text(label),
          Slider(
            min: min,
            max: max,
            value: value,
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }

  // ---------------- RENDER ENGINE (PREVIEW) ----------------
  Widget _renderLine(String line, Color chordColor, Color lyricColor) {
    final chordRegex = RegExp(r'\[([^\]]+)\]');

    if (!chordRegex.hasMatch(line)) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Text(
          line,
          style: TextStyle(
            fontSize: fontSize,
            color: lyricColor,
          ),
        ),
      );
    }

    final chordLine = line.replaceAllMapped(
      chordRegex,
      (m) => m.group(1)!.padRight(m.group(0)!.length),
    );

    final lyricLine = line.replaceAll(chordRegex, '');

    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            chordLine,
            style: GoogleFonts.robotoMono(
              fontSize: fontSize + 3,
              color: chordColor,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(color: chordColor.withOpacity(.6), blurRadius: 8),
                Shadow(color: chordColor.withOpacity(.3), blurRadius: 16),
              ],
            ),
          ),
          const SizedBox(height: 3),
          Text(
            lyricLine,
            style: TextStyle(
              fontSize: fontSize,
              color: lyricColor,
            ),
          ),
        ],
      ),
    );
  }
}
