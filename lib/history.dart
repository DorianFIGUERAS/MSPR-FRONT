import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HistoryPage extends StatefulWidget {
  final String userUID; // Variable pour userID

  const HistoryPage({Key? key, required this.userUID}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  bool isLoading = true; // Ajouté pour contrôler l'affichage de l'indicateur de chargement
  List<dynamic> historyData = []; // Une liste pour stocker plusieurs images et prédictions


  Future<void> sendJson() async {
    var url = Uri.parse('http://wildlens.ddns.net:5000/history');

    try {
      var response = await http.post(
        Uri.parse('http://wildlens.ddns.net:5000/history'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode({
          'uid': widget.userUID,
        }),
      );

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data is List && data.isNotEmpty) {
          setState(() {
            historyData = data.reversed.toList(); // Stockez toutes les données dans la liste
            isLoading = false;
          });
        }
      } else {
        print('Erreur avec la requête: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending JSON: $e');
    }
    setState(() => isLoading = false); // Assurez-vous de cacher l'indicateur de chargement
  }


  @override
  void initState() {
    super.initState();
    sendJson(); // Appelez sendJson dans initState pour charger les données au démarrage
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Historique', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Color(0xFF31c48d),
        toolbarHeight: 100,
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: sendJson, // La fonction appelée lors du "pull to refresh"
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : historyData.isNotEmpty
            ? ListView.builder(
          itemCount: historyData.length,
          itemBuilder: (context, index) {
            var item = historyData[index];
            return Card(
              margin: EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              color: Color(0x4031c48d), // Un blanc cassé
              child: ListTile(
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                leading: GestureDetector(
                  onTap: () => showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      content: Image.network(
                        item['url_image'],
                        width: 600,
                        fit: BoxFit.cover,
                      ),
                      actions: <Widget>[
                        TextButton(
                          child: Text('Fermer'),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ],
                    ),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item['url_image'],
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                title: Text(
                  'Prédiction : ${item['prediction']}',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            );
          },
        )
            : Center(child: Text('Aucune donnée disponible')),
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color(0xFF31c48d),
        child: IconTheme(
          data: IconThemeData(color: Theme.of(context).colorScheme.onPrimary),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[],
          ),
        ),
      ),
    );
  }
}
