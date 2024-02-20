// ignore_for_file: prefer_const_constructors, use_build_context_synchronously

import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:wildlens/history.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const MyApp());

}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WildLens',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF31c48d),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false, //Permet de cacher la bannière "débug"
      home: MyHomePage(title: ''),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late File? _imageFile;
  final ImagePicker _picker = ImagePicker();
  String prediction = ''; // Variable pour stocker la prédiction
  bool _loading = false;

  Future<void> _takePhoto() async {
    setState(() {
      _loading = true;
    });
    final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera);
    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);

      // Création de la requête multipart pour envoyer la photo
      var request = http.MultipartRequest('POST', Uri.parse(
          'http://wildlens.ddns.net:5000/upload_photo')); // Remplacez l'URL par votre adresse IP et port

      // Ajout du fichier photo à la requête
      request.files.add(
          await http.MultipartFile.fromPath('photo', imageFile.path));

      // Envoi de la requête au serveur
      var response = await request.send();

      if (response.statusCode == 200) {
        // Récupération de la réponse JSON
        var jsonResponse = await response.stream.bytesToString();
        var data = json.decode(jsonResponse);
        String imageUrl = data['url '];
        // Affichage du message de succès
        setState(() {
          _loading = false; // Arrêter le chargement après avoir reçu la réponse
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Photo téléchargée avec succès',style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),),
                  SizedBox(height: 10),
                  Center(
                    child: Image.network(
                    imageUrl,
                    width: 200,
                      height: 200,
                    ),
                  ),
                  Text('\n${data['Informations ']}'), // Afficher tout le JSON
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Fermer'),
                ),
              ],
            );
          },
        );
      } else {
        // Gestion des erreurs de téléchargement
        setState(() {
          _loading = false; // Arrêter le chargement en cas d'erreur
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Erreur'),
              content: Text('Échec du téléchargement de la photo'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Fermer'),
                ),
              ],
            );
          },
        );
      }
    }
  }


  Future<void> _uploadPhoto() async {
    setState(() {
      _loading = true; // Déclencher le chargement avant l'appel de la requête
    });
    final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });

      // Création de la requête multipart pour envoyer la photo
      var request = http.MultipartRequest('POST', Uri.parse(
          'http://wildlens.ddns.net:5000/upload_photo')); // Remplacez l'URL par votre adresse IP et port

      // Ajout du fichier photo à la requête
      request.files.add(
          await http.MultipartFile.fromPath('photo', _imageFile!.path));

      // Envoi de la requête au serveur
      var response = await request.send();

      if (response.statusCode == 200) {
        // Récupération de la réponse JSON
        var jsonResponse = await response.stream.bytesToString();
        var data = json.decode(jsonResponse);
        setState(() {
          _loading =
          false; // Déclencher le chargement avant l'appel de la requête
        });
        // Affichage du message de succès
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Succès'),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Photo téléchargée avec succès'),
                  SizedBox(height: 10),
                  Text('${data['Informations ']}'), // Afficher tout le JSON
                ],
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Fermer'),
                ),
              ],
            );
          },
        );
      } else {
        // Gestion des erreurs de téléchargement
        setState(() {
          _loading =
          false; // Déclencher le chargement avant l'appel de la requête
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Erreur'),
              content: Text('Échec du téléchargement de la photo'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Fermer'),
                ),
              ],
            );
          },
        );
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80.0), // Adjust the height as needed
        child: AppBar(

          backgroundColor: Color(0xFF31c48d),
          title: Center( // Use Center to vertically align the image
            child: Image.asset(
              'images/wildaware.png', // Make sure this path is correct
              fit: BoxFit.cover,
              height: 100.0, // Adjust the height to fit within the AppBar
              // Width can be adjusted as well, or removed for the image to keep its aspect ratio

            ),
          ),
          centerTitle: true,
        ),

      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        // Aligner les widgets au début de la colonne
        children: <Widget>[
          SizedBox(height: 20), // Espace en haut
          Center( // Centre horizontalement le texte dans la Column
            child: Text(
              'Scannez une empreinte',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded( // Utilisé pour étendre les boutons dans l'espace disponible
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              // Centre les boutons verticalement dans l'espace étendu
              children: [
                Center( // Centre horizontalement le bouton dans la Column
                  child: ElevatedButton(
                    onPressed: _takePhoto,
                    child: Text('Prendre une photo'),
                  ),
                ),
                SizedBox(height: 16),
                // Espace entre les boutons
                Center( // Centre horizontalement le bouton dans la Column
                  child: ElevatedButton(
                    onPressed: _uploadPhoto,
                    child: Text('Charger une photo'),
                  ),
                ),
                if (_loading)
                  Center(child: CircularProgressIndicator()),
                // Indicateur de chargement centré
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        color: Color(0xFF31c48d),
        child: IconTheme(
          data: IconThemeData(color: Theme
              .of(context)
              .colorScheme
              .onPrimary),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              IconButton(
                tooltip: 'Open navigation menu',
                onPressed: () {},
                icon: const Icon(Icons.home),
              ),
              IconButton(
                tooltip: 'History',
                onPressed: () {
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => history()));
                },
                icon: const Icon(Icons.menu),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
