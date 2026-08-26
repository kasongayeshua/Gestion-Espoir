import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('produits');
  await Hive.openBox('ventes');
  await Hive.openBox('caisse');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestion Espoir',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E3A8A),
          primary: const Color(0xFF1E3A8A),
          secondary: const Color(0xFF059669),
        ),
      ),
      home: const VenteScreen(),
    );
  }
}

class VenteScreen extends StatefulWidget {
  const VenteScreen({Key? key}) : super(key: key);

  @override
  State<VenteScreen> createState() => _VenteScreenState();
}

class _VenteScreenState extends State<VenteScreen> {
  final produitsBox = Hive.box('produits');
  final ventesBox = Hive.box('ventes');
  final caisseBox = Hive.box('caisse');

  Map<String, int> panier = {};
  String modePaiement = 'COMPTANT';

  @override
  Widget build(BuildContext context) {
    double totalPanier = 0;
    panier.forEach((nom, qte) {
      final produit = produitsBox.get(nom);
      if (produit != null) {
        totalPanier += (produit['prix'] ?? 0) * qte;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion Espoir - Caisse & Ventes', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E3A8A),
      ),
      body: Column(
        children: [
          Expanded(
            child: produitsBox.isEmpty
                const Center(child: Text('Aucun produit disponible. Ajoutez des produits.'))
                : ListView.builder(
                    itemCount: produitsBox.length,
                    itemBuilder: (context, index) {
                      final key = produitsBox.keyAt(index);
                      final produit = produitsBox.get(key);
                      final qtePanier = panier[key] ?? 0;

                      return ListTile(
                        title: Text(key, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text('Prix: ${produit['prix']} FC | Stock: ${produit['stock']}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove_circle, color: Colors.red),
                              onPressed: qtePanier > 0
                                  ? () {
                                      setState(() {
                                        panier[key] = qtePanier - 1;
                                        if (panier[key] == 0) panier.remove(key);
                                      });
                                    }
                                  : null,
                            ),
                            Text('$qtePanier', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.add_circle, color: Colors.green),
                              onPressed: () {
                                setState(() {
                                  panier[key] = qtePanier + 1;
                                });
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Column(
              children: [
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'COMPTANT', label: Text('Comptant')),
                    ButtonSegment(value: 'CREDIT', label: Text('Crédit')),
                  ],
                  selected: {modePaiement},
                  onSelectionChanged: (s) => setState(() => modePaiement = s.first),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: totalPanier > 0
                        ? () {
                            // Enregistrement de la vente
                            ventesBox.add({
                              'date': DateTime.now().toIso8601String(),
                              'total': totalPanier,
                              'mode': modePaiement,
                              'items': Map.from(panier),
                            });
                            setState(() {
                              panier.clear();
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Vente validée avec succès !')),
                            );
                          }
                        : null,
                    child: Text('VALIDER (${totalPanier.toStringAsFixed(0)} FC)', style: const TextStyle(fontSize: 18)),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
