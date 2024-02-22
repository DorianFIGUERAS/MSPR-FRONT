# MSPR-FRONT
# Front-End de l'application Wildlens

## Overview
Cette documentation a pour but d'être simple et d'expliquer l'articulation de la partie Front-End de l'application Wildlens sur sa machine. Elle comprend l'installation du projet et des différents scripts flutter (en **Dart**).

## Requirements
Le projet nécéssite l'installation de **Fluter**, **Dart**, et **Android Studio**.
Installation de Flutter : 
*[Pour windows](https://docs.flutter.dev/get-started/install/windows/desktop)
*[Pour Linux](https://docs.flutter.dev/get-started/install/linux)
*[Pour mac](https://docs.flutter.dev/get-started/install/macos/desktop)

Installation de Dart : 
*[Pour tous les OS](https://dart.dev/get-dart)

Installation d'Android Studio : 
*[Android Studio](https://developer.android.com/studio/install)

Il faut ensuite mettre les PATHS de Dart et Flutter dans Android Studio :
![image](https://github.com/DorianFIGUERAS/MSPR-FRONT/assets/127091847/3b85e584-8e51-4fe8-8507-7568c16f2b11)
![image](https://github.com/DorianFIGUERAS/MSPR-FRONT/assets/127091847/6c677a08-eb17-42c3-aa5f-554a3580dffc)



## Composition du Repository (Scripts principaux)
**Scripts (Project>lib)** :
- **main.dart** : Ce script correspond à la page principale de l'application. Il permet l'articulation entre les différentes pages. 
- **history.dart** : Ce script permet de récupérer et d'afficher l'historique des images uploadées et des prédictions retournées à l'utilisateur.
- **authentification.dart** : Ce script permet de s'authentifier pour accéder à l'application. 
- **ForgotPasswordPage.dart** : Ce script permet de faire une demande de réinitialisation de mot de passe auprès de la BDD Firebase. 
- **register.dart** : Ce script permet de s'inscrire sur la BDD pour une première connexion à l'application. 

## Instructions
**Récuperer le repository et le cloner dans Android Studio.**

**Préparation pour lancer l'application sur un émulateur**
Il faut télécharger un SDK Android : 
![image](https://github.com/DorianFIGUERAS/MSPR-FRONT/assets/127091847/6cf5c154-266c-45b3-b099-120ebd0f9ac4)

Il faut ensuite démarrer l'émulateur :
![image](https://github.com/DorianFIGUERAS/MSPR-FRONT/assets/127091847/3738aa8c-90bf-4e1e-83ab-6880e44fbd1c)

Puis sélectionner l'émulateur : 
![image](https://github.com/DorianFIGUERAS/MSPR-FRONT/assets/127091847/6b3947ce-30c1-483b-be13-840d51d9acae)

## Description détaillée des scripts
* **main.dart** : Dans ce script, on importe les différentes bibliothèque et on initialise et configure la connexion à Firebase. La classe `MyApp`permet de verifier l'état de connexion de l'utilisateur à l'application et le redirige vers la page de connexion s'il n'est pas connecté. On enregistre les informations de connexion de l'utilisateur pour éviter de se connecter à chaque ouverture de l'application. `MyHomePage` représente la page principale de l'application et permet à l'utilisateur de prendre ou d'uploader une photo pour l'envoyer au serveur pour analyse par l'IA. Pour permettre à l'application d'intéragir avec la caméra et la galerie de l'utilisateur, le script utilise `ImagePicker`. Les méthodes `_takePhoto`et `_uploadPhoto`gèrent respectivement la prise et le chargement d'une image depuis la galerie. Pour l'envoi, on utilise ici des requêtes `http` avec une méthode `POST`. Ce script gère également la déconnexion de l'utilisateur à l'application et permet aussi de switcher de page vers **history.dart** en récupérent l'`UID`de l'utilisateur.

*  **history.dart** : Dans ce script, nous récupérons l'`UID`de l'utilisateur afin de l'envoyer au serveur pour permettre le requêtage de la BDD Firebase. Lorsque le serveur a requêté la BDD avec le paramètre `UID`, le serveur retourne à l'application un fichier json contenant les urls de toutes les photos uploadées par l'utilisateur ainsi que les prédictions associées. On utilise ensuite une fonction pour décripter le fichier json et afficher les images via la fonction `Image.network`.

*  **authentification.dart** : Dans ce script, on commence par initialiser la connexion à la base de données Firebase. On utilise ensuite `StreamBuilder`afin d'écouter les changements d'authentification. Si l'utilisateur est connecté alors on redirige vers le script **main.dart** et donc vers la page `MyHomePage`. Les informations de connexion de l'utilisateur sont ensuite conservées afin que l'utilisateur reste connecté.

*  **ForgotPasswordPage.dart** : Dans ce script, la classe `ForgotPasswordPage` contient la logique de l'interface utilisateur pour la réinitialisation du mot de passe. On utilise des instances Firebase comme `_auth`, `_formKey`, `_emailController`pour permettre la réinitisalisation du mot de passe de l'utilisateur dans la gestion des utilisateurs Firebase. 









