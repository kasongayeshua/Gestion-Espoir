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
