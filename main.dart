import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:intl/intl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('produits');
  await Hive.openBox('ventes');
  await Hive.openBox('caisse');
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
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
      home: VenteScreen(),
    );
  }
}

class VenteScreen extends StatefulWidget {
  @override
  _VenteScreenState createState() => _VenteScreenState();
}

class _VenteScreenState extends State<VenteScreen> {
  final produitsBox = Hive.box('produits');
  final ventesBox = Hive.box('ventes');
  final caisseBox = Hive.box('caisse');

  Map<String, int> panier = {};
  String modePaiement = 'COMPTANT';
  double totalPanier = 0.0;

  @override
  void initState() {
    super.initState();
    if (produitsBox.isEmpty) {
      produitsBox.putAll({
        '1': {'id': '1', 'nom': 'Eau Minérale', 'prix': 5.0, 'stock': 50},
        '2': {'id': '2', 'nom': 'Jus de Fruit', 'prix': 15.0, 'stock': 25},
      });
    }
  }

  void ajouterAuPanier(String id, double prix) {
    setState(() {
      panier[id] = (panier[id] ?? 0) + 1;
      totalPanier += prix;
    });
  }

  Future<void> validerVente() async {
    double soldeCaisse = caisseBox.get('solde', defaultValue: 0.0);
    
    // Si la vente est au comptant, on l'ajoute directement dans la caisse
    if (modePaiement == 'COMPTANT') {
      caisseBox.put('solde', soldeCaisse + totalPanier);
    }

    // Enregistrement de la vente dans la boîte Hive "ventes"
    var venteData = {
      'date': DateFormat('dd/MM/yyyy HH:mm').format(DateTime.now()),
      'total': totalPanier,
      'mode': modePaiement,
      'articles': panier.entries.map((e) {
        var prod = produitsBox.get(e.key);
        return '${prod != null ? prod['nom'] : 'Produit'} (x${e.value})';
      }).toList(),
    };
    ventesBox.add(venteData);
    
    setState(() {
      panier.clear();
      totalPanier = 0.0;
    });
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Vente validée avec succès !'), backgroundColor: const Color(0xFF059669))
    );
  }

  // Fonction pour afficher l'historique des ventes
  void afficherHistorique(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: EdgeInsets.all(16),
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('📜 Historique des Ventes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                IconButton(icon: Icon(Icons.close), onPressed: () => Navigator.pop(ctx)),
              ],
            ),
            Divider(),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: ventesBox.listenable(),
                builder: (context, Box box, _) {
                  if (box.isEmpty) {
                    return Center(child: Text('Aucune vente enregistrée pour le moment.', style: TextStyle(color: Colors.grey)));
                  }
                  var ventes = box.values.toList().reversed.toList();
                  return ListView.builder(
                    itemCount: ventes.length,
                    itemBuilder: (context, index) {
                      var v = ventes[index];
                      return Card(
                        margin: EdgeInsets.symmetric(vertical: 6),
                        child: ListTile(
                          title: Text('Total : ${v['total']} \$ (${v['mode']})', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                          subtitle: Text('Date : ${v['date']}\nArticles : ${v['articles'].join(', ')}'),
                          isThreeLine: true,
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double soldeCaisse = caisseBox.get('solde', defaultValue: 0.0);
    
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start, 
          children: [
            Row(
              children: [
                Text('🛒 Gestion Espoir', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                SizedBox(width: 8),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2), 
                  decoration: BoxDecoration(color: const Color(0xFF059669), borderRadius: BorderRadius.circular(4)), 
                  child: Text('Pro / Vérifié', style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.bold))
                ),
              ],
            ),
            Text('Caisse: $soldeCaisse \$', style: TextStyle(fontSize: 13, color: Colors.white70)),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () => afficherHistorique(context),
            tooltip: 'Historique des ventes',
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4, 
            child: ValueListenableBuilder(
              valueListenable: produitsBox.listenable(), 
              builder: (context, box, _) {
                var produits = box.values.toList();
                return GridView.builder(
                  padding: EdgeInsets.all(8), 
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2, childAspectRatio: 2.5), 
                  itemCount: produits.length, 
                  itemBuilder: (context, index) {
                    final p = produits[index];
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
                      onPressed: () => ajouterAuPanier(p['id'], p['prix']),
                      child: Text('${p['nom']} \n${p['prix']} \$', textAlign: TextAlign.center),
                    );
                  },
                );
              },
            ),
          ),
          Expanded(
            flex: 2, 
            child: ListView.builder(
              itemCount: panier.length, 
              itemBuilder: (context, index) {
                String id = panier.keys.elementAt(index);
                var prod = produitsBox.get(id);
                return ListTile(
                  dense: true,
                  title: Text(prod != null ? prod['nom'] : 'Produit'), 
                  trailing: Text('Qté: ${panier[id]}', style: TextStyle(fontWeight: FontWeight.bold))
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(12), 
            color: Colors.white,
            child: Column(
              children: [
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'COMPTANT', label: Text('Comptant')), 
                    ButtonSegment(value: 'CREDIT', label: Text('Crédit'))
                  ],
                  selected: {modePaiement},
                  onSelectionChanged: (s) => setState(() => modePaiement = s.first),
                ),
                SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF059669),
                      foregroundColor: Colors.white,
                    ),
                    onPressed: totalPanier > 0 ? validerVente : null,
                    child: Text('VALIDER $totalPanier \$', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                )
              ],
            ),
          )
        ],
      ),
    );
  }
}
