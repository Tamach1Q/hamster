import 'package:flutter/material.dart';
import 'dart:math';

void main() => runApp(const MaterialApp(home: TextbookGacha()));

// レア度ごとの設定。weight を変えると出現確率が変わる（合計100にすると%で読める）
enum Rarity {
  ur('UR', 3, Color(0xFFE040FB)),
  ssr('SSR', 12, Color(0xFFFFB300)),
  sr('SR', 20, Color(0xFF42A5F5)),
  r('R', 30, Color(0xFF66BB6A)),
  n('N', 35, Color(0xFF9E9E9E));

  const Rarity(this.label, this.weight, this.color);
  final String label;
  final int weight;
  final Color color;
}

class GachaCard {
  const GachaCard(this.name, this.image, this.rarity);
  final String name, image;
  final Rarity rarity;
}

class TextbookGacha extends StatefulWidget {
  const TextbookGacha({super.key});
  @override
  State<TextbookGacha> createState() => _TextbookGachaState();
}

class _TextbookGachaState extends State<TextbookGacha> {
  GachaCard? card;
  int e = 0;
  bool loading = false;

  final emojis = ['📚', '📖', '✏️', '✨'];
  // 同じレア度に複数あるときは、そのレア度の確率を等分する
  final cards = const [
    GachaCard('エーミール', 'images/エーミール.png', Rarity.ur),
    GachaCard('スイミー（黒）', 'images/スイミー黒.png', Rarity.ssr),
    GachaCard('くじらぐも', 'images/くじらぐも.jpg', Rarity.ssr),
    GachaCard('メロス', 'images/メロス.png', Rarity.sr),
    GachaCard('ごんぎつね', 'images/ごんぎつね.png', Rarity.r),
    GachaCard('スイミー（赤）', 'images/スイミーの赤.png', Rarity.n),
  ];

  GachaCard draw() {
    final rarities = Rarity.values
        .where((r) => cards.any((c) => c.rarity == r))
        .toList();
    final total = rarities.fold(0, (sum, r) => sum + r.weight);
    var roll = Random().nextInt(total);
    for (final r in rarities) {
      if (roll < r.weight) {
        final pool = cards.where((c) => c.rarity == r).toList();
        return pool[Random().nextInt(pool.length)];
      }
      roll -= r.weight;
    }
    return cards.last;
  }

  Future<void> gacha() async {
    setState(() => loading = true);
    for (int i = 0; i < 10; i++) {
      await Future.delayed(const Duration(milliseconds: 100));
      setState(() => e = (e + 1) % emojis.length);
    }

    setState(() {
      card = draw();
      loading = false;
    });
  }

  Widget result(GachaCard c) => Column(
    children: [
      Text(
        c.rarity.label,
        style: TextStyle(
          fontSize: 40,
          fontWeight: FontWeight.bold,
          color: c.rarity.color,
        ),
      ),
      Container(
        width: 300,
        height: 300,
        decoration: BoxDecoration(
          border: Border.all(color: c.rarity.color, width: 6),
        ),
        child: Image.network(Uri.encodeFull(c.image), fit: BoxFit.cover),
      ),
      const SizedBox(height: 8),
      Text(c.name, style: const TextStyle(fontSize: 28)),
    ],
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('📚 教科書ガチャ')),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 420,
            child: Center(
              child: loading
                  ? Text(emojis[e], style: const TextStyle(fontSize: 100))
                  : card == null
                  ? const Text('❓', style: TextStyle(fontSize: 100))
                  : result(card!),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: loading ? null : gacha,
            child: const Text('ガチャを回す！'),
          ),
        ],
      ),
    ),
  );
}
