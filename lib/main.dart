// ignore_for_file: unused_import, unused_field, unused_local_variable, non_constant_identifier_names, prefer_typing_uninitialized_variables, prefer_const_constructors, use_super_parameters, prefer_const_constructors_in_immutables, avoid_print, use_build_context_synchronously, sort_child_properties_last

import 'dart:developer';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:wildlens/history.dart';
import 'package:wildlens/authentification.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';


var data_user;

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Assurez-vous que Flutter est initialisé avant d'initialiser Firebase
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: "AIzaSyCYC66QcwqPc0bQ0d6VFMF6rh_MUENWvLI", // Remplacez par vos propres clés
      appId: "1:550985568949:web:21a75354bb80e34c76e4fc",
      messagingSenderId: "550985568949",
      projectId: "footprints-8e343",
      // Ajoutez d'autres options nécessaires pour votre projet
    ),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key);

  // Cette méthode vérifie l'état de connexion
  Future<bool> _checkLoginStatus() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

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
      debugShowCheckedModeBanner: false,
      home: FutureBuilder<bool>(
        future: _checkLoginStatus(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.data == true) {
              return MyHomePage(title: 'Page Principale'); // Modifier selon le nom réel de votre page d'accueil
            } else {
              return LoginPage(); // La page de connexion si l'utilisateur n'est pas connecté
            }
          } else {
            // Afficher un écran de chargement pendant la vérification
            return Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
        },
      ),
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
  String? userUID;

  @override
  void initState() {
    super.initState();
    getCurrentUserUID();
  }

  Future<void> getCurrentUserUID() async {
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      setState(() {
        userUID = user.uid; // Récupération de l'UID de l'utilisateur
        // Mettre à jour data_user ici pour garantir qu'il a la valeur correcte
        data_user = {
          'uid': userUID,
        };
      });
    } else {
      print("Aucun utilisateur connecté.");
    }
  }

  Future<void> _takePhoto() async {
    setState(() {
      _loading = true;
    });

    try{
    final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.camera);
    if (pickedFile == null) {
      // Si l'utilisateur annule la prise de photo, arrêtez l'indicateur de chargement et sortez de la fonction.
      setState(() {
        _loading = false;
      });
      return; // Sortez de la fonction car aucune photo n'a été prise.
    }
      File imageFile = File(pickedFile.path);

      await getCurrentUserUID();
      print("userUID: $userUID");

      var response2 = await http.post(
        Uri.parse('http://wildlens.ddns.net:5000/userid'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(data_user),
      );

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
        String image_Url = data['url '];
        // Affichage du message de succès
        setState(() {
          _loading = false; // Arrêter le chargement après avoir reçu la réponse
        });
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: SingleChildScrollView( // Ajouter le SingleChildScrollView ici
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Photo téléchargée avec succès',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                    ),
                    Text(
                      'Prédiction juste à ${data['pourcentage ']} %',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Center(
                      child: Image.network(
                        image_Url,
                        width: 200,
                        height: 200,
                      ),
                    ),
                    Text('\n${data['Informations ']}'),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Fermer',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
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
              title: Text('Erreur', style: TextStyle(fontWeight: FontWeight.bold),),
              content: Text('Échec du téléchargement de la photo', style: TextStyle(fontWeight: FontWeight.bold),),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Fermer', style: TextStyle(fontWeight: FontWeight.bold),),
                ),
              ],
            );
          },
        );
      }
    }catch (e) {
      // Gérer les exceptions ici si nécessaire
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Erreur', style: TextStyle(fontWeight: FontWeight.bold),),
            content: Text("Quelque chose s'est mal passé...", style: TextStyle(fontWeight: FontWeight.bold),),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Fermer', style: TextStyle(fontWeight: FontWeight.bold),),
              ),
            ],
          );
        },
      );
    } finally {
      // S'assurer que l'indicateur de chargement s'arrête dans tous les cas
      setState(() {
        _loading = false;
      });
    }
  }

  void _signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()));
  }

  Future<void> _uploadPhoto() async {
    setState(() {
      _loading = true; // Déclencher le chargement avant l'appel de la requête
    });
    try{
    final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery);
    if (pickedFile == null) {
      // Si l'utilisateur annule la prise de photo, arrêtez l'indicateur de chargement et sortez de la fonction.
      setState(() {
        _loading = false;
      });
      return; // Sortez de la fonction car aucune photo n'a été prise.
    }

      File imageFile = File(pickedFile.path);
      await getCurrentUserUID();
      print("userUID: $userUID");

      var response2 = await http.post(
        Uri.parse('http://wildlens.ddns.net:5000/userid'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: json.encode(data_user),
      );

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
        String image_Url = data['url '];
        setState(() {
          _loading =
          false; // Déclencher le chargement avant l'appel de la requête
        });
        // Affichage du message de succès
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              content: SingleChildScrollView( // Ajouter le SingleChildScrollView ici
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Photo téléchargée avec succès',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 25),
                    ),
                    Text(
                      'Prédiction juste à ${data['pourcentage ']} %',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Center(
                      child: Image.network(
                        image_Url,
                        width: 200,
                        height: 200,
                      ),
                    ),
                    Text('\n${data['Informations ']}'),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(
                    'Fermer',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
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
              title: Text('Erreur', style: TextStyle(fontWeight: FontWeight.bold),),
              content: Text('Échec du téléchargement de la photo', style: TextStyle(fontWeight: FontWeight.bold),),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Fermer', style: TextStyle(fontWeight: FontWeight.bold),),
                ),
              ],
            );
          },
        );
      }
    }catch (e) {
      // Gérer les exceptions ici si nécessaire
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Erreur', style: TextStyle(fontWeight: FontWeight.bold),),
            content: Text("Quelque chose s'est mal passé...", style: TextStyle(fontWeight: FontWeight.bold),),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Fermer', style: TextStyle(fontWeight: FontWeight.bold),),
              ),
            ],
          );
        },
      );
    } finally {
      // S'assurer que l'indicateur de chargement s'arrête dans tous les cas
      setState(() {
        _loading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF31c48d),
        toolbarHeight: 100.0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween, // Répartit l'espace uniformément
          children: [
            IconButton(
              icon: Icon(Icons.logout, color: Color(0xFF31c48d)), // Icône transparente pour équilibrer l'icône de déconnexion
              onPressed: null, // Désactive l'icône pour qu'elle ne soit pas cliquable
            ),
            // Centre le logo
            Image.asset(
              'images/wildaware.png', // Assurez-vous que ce chemin est correct
              fit: BoxFit.cover,
              height: 150.0, // Ajustez selon vos besoins
            ),
            IconButton(
              icon: Icon(Icons.logout),
              onPressed: () {
                _signOut(context);
              },
            ),
          ],
        ),
        centerTitle: true, // Cela ne fonctionnera pas comme prévu avec Row
        elevation: 0, // Supprime l'ombre sous l'AppBar
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, // Centre horizontalement dans la Row
              children: [
                ElevatedButton(
                  onPressed: _takePhoto,
                  child: Icon(Icons.camera_alt), // Icône pour "Prendre une photo"
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), // Carré
                    fixedSize: Size(150, 150), // Taille du bouton carré
                    backgroundColor: Color(0x8031c48d), // Couleur de fond du bouton
                  ),
                ),
                SizedBox(width: 30), // Espacement entre les boutons
                ElevatedButton(
                  onPressed: _uploadPhoto,
                  child: Icon(Icons.photo_library), // Icône pour "Charger une photo"
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), // Carré
                    fixedSize: Size(150, 150), // Taille du bouton carré
                    backgroundColor: Color(0x8031c48d), // Couleur de fond du bouton
                  ),
                ),
              ],
            ),
          ),
          if (_loading)
            Center(child: CircularProgressIndicator()), // Indicateur de chargement centré
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
                  if (userUID != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => HistoryPage(userUID: userUID!),
                      ),
                    );
                  } else {
                    // Utilisation d'une fonction auto-invoquée async pour utiliser await
                    () async {
                      await getCurrentUserUID(); // Assurez-vous que cette fonction est définie pour récupérer userUID de manière asynchrone
                      print("userUID: $userUID");
                      if (userUID != null) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => HistoryPage(userUID: userUID!),
                          ),
                        );
                      } else {
                        // Gérer le cas où userUID est toujours null après la tentative de récupération
                        print("User UID is still null after attempting to fetch.");
                        // Ici, vous pouvez montrer une alerte ou effectuer une autre action appropriée
                      }
                    }(); // Notez les parenthèses pour invoquer immédiatement la fonction
                  }
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
