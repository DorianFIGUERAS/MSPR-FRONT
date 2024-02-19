import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:wildlens/main.dart';
import 'package:firebase_auth_platform_interface/firebase_auth_platform_interface.dart';
import 'package:wildlens/register.dart';
import 'package:wildlens/ForgotPasswordPage.dart';
import 'package:shared_preferences/shared_preferences.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WildLens Auth',
      theme: ThemeData(
        primarySwatch: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.active) {
            User? user = snapshot.data;
            if (user == null) {
              return LoginPage(); // L'utilisateur n'est pas connecté, afficher la page de connexion
            }
            return MyHomePage(title: 'Page Principale'); // L'utilisateur est connecté, afficher la page principale
          }
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(), // Afficher un indicateur de chargement en attendant
            ),
          );
        },
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  void _signIn() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Si la connexion a réussi, redirigez l'utilisateur vers la page principale.
      if (userCredential.user != null) {
        print('Connexion réussie : ${userCredential.user!.email}');
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        TextInput.finishAutofillContext(shouldSave: true);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage(title: '',)),
        );
      }
    } on FirebaseAuthException catch (e) {
      print('Erreur de connexion : $e');
      // Afficher un message d'erreur à l'utilisateur
      // Vous pouvez utiliser ScaffoldMessenger pour afficher un SnackBar avec le message d'erreur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erreur de connexion : ${e.message}'),
        ),
      );
    }
  }

  void _register(email, password) async {
    try {
      UserCredential userCredential = await _auth
          .createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Si l'enregistrement a réussi, redirigez l'utilisateur vers la page principale.
      if (userCredential.user != null) {
        print('Inscription réussie : ${userCredential.user!.email}');
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MyHomePage(title: '',)),
        );
      }
    } on FirebaseAuthException catch (e) {
      print("Erreur d'inscription : $e");
      // Afficher un message d'erreur à l'utilisateur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur d'inscription : ${e.message}"),
        ),
      );
    }
  }

  void _resetPassword() async {
    try {
      await _auth.sendPasswordResetEmail(
        email: _emailController.text,
      );
      print('E-mail de réinitialisation du mot de passe envoyé.');
      // Afficher un message indiquant que l'e-mail a été envoyé
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('E-mail de réinitialisation du mot de passe envoyé.'),
        ),
      );
    } on FirebaseAuthException catch (e) {
      print('Erreur de réinitialisation du mot de passe : $e');
      // Afficher un message d'erreur à l'utilisateur
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              'Erreur de réinitialisation du mot de passe : ${e.message}'),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
      body: Center(
        child: SingleChildScrollView( // Permet de faire défiler si le clavier couvre le formulaire
          padding: const EdgeInsets.all(16.0),
          // Ajoute un peu d'espace autour du formulaire
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Adresse e-mail',
                      border: OutlineInputBorder(),
                    ),
                    autofillHints: [AutofillHints.email],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer une adresse e-mail valide.';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextFormField(
                    controller: _passwordController,
                    decoration: InputDecoration(
                      labelText: 'Mot de passe',
                      border: OutlineInputBorder(),
                    ),
                    obscureText: true,
                    autofillHints: [AutofillHints.password],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer un mot de passe valide.';
                      }
                      return null;
                    },
                  ),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Color(0xFF31c48d), // Couleur du bouton
                  ),
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _signIn();
                    }
                  },
                  child: Text('Se connecter'),
                ),
                SizedBox(height: 20), // Ajoute un espace vertical
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => RegisterPage()),
                    );
                  },
                  child: Text(
                    'Créer un compte',
                    style: TextStyle(color: Color(0xFF31c48d)),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ForgotPasswordPage()),
                    );
                  },
                  child: Text(
                    'Mot de passe oublié ?',
                    style: TextStyle(color: Color(0xFF31c48d)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
// Utilisez le même style de BottomAppBar que votre page principale
      bottomNavigationBar: BottomAppBar(
        color: Color(0xFF31c48d),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            // Ici, vous pouvez ajouter des icônes ou du texte si vous le souhaitez
          ],
        ),
      ),
    );
  }
} 