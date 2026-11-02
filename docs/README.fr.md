# Batocera Wii U GamePad — Documentation française

[English README](../README.md)

Transformez un téléphone ou une tablette Android en véritable second écran **Wii U GamePad pour Cemu sous Batocera 44**.

> **État :** v0.2.0. Le runtime Batocera et l’intégration Moonlight WiiU sont prêts pour Batocera 44 / Wayland / LabWC. La configuration de référence a été validée de bout en bout et le placement multi-écrans est également couvert par des tests automatisés.

## Démonstration

[▶ Voir la démo Wii U GamePad de 45 secondes](../media/gamepad-demo.mp4)

La vidéo a été enregistrée sur la configuration Batocera 44 validée et montre le fonctionnement réel avec l’écran TV et le GamePad Android.

## Fonctionnement

Le projet crée une sortie virtuelle dédiée `WIIU-GAMEPAD`, déplace la **GamePad View** de Cemu vers celle-ci, diffuse cet écran vers Android avec Sunshine/Moonlight, redirige le tactile Android uniquement vers cette sortie et sépare l’audio TV de l’audio GamePad.

```text
Cemu GamePad View
      │
      ▼
WIIU-GAMEPAD (854x480)
      │
      ▼
Sunshine (capture Wayland)
      │
      ▼
Moonlight WiiU sur Android

Audio TV Cemu ───────────────► TV / HDMI
Audio GamePad Cemu ──────────► WIIU_GAMEPAD_AUDIO ─► Moonlight
```

Les commandes physiques peuvent rester sur une manette locale connectée à Batocera. Le téléphone ou la tablette Android sert de second écran tactile. Un support téléphone/tablette fixé à la manette est facultatif.

## Installation rapide

1. Décompressez l’archive ZIP de la release sur la machine Batocera.
2. Lancez :

   ```bash
   bash install.sh
   ```

3. Installez l’APK **Moonlight WiiU** fourni sur le téléphone ou la tablette Android.
4. Placez l’appareil Android et la machine Batocera sur le même réseau local.
5. Lancez un jeu Wii U depuis EmulationStation.
6. Attendez le démarrage de Cemu. Sunshine NoCursor démarre automatiquement uniquement pendant la session Wii U.
7. Ouvrez Moonlight WiiU et sélectionnez l’hôte Batocera.
8. Si la détection automatique échoue, appuyez sur **+** dans Moonlight et saisissez uniquement l’adresse IPv4 locale de Batocera.
9. Moonlight affiche un code PIN à quatre chiffres.
10. Ouvrez l’interface Web de Sunshine :

    ```text
    https://<IP-BATOCERA>:47990
    ```

11. Lors d’une **nouvelle installation**, Sunshine demande de créer un identifiant et un mot de passe pour son interface Web. Aucun identifiant par défaut n’est fourni. Lors d’une mise à niveau, utilisez les identifiants déjà existants.
12. Ouvrez **PIN Pairing**, saisissez le code PIN de Moonlight puis validez.
13. Connectez Moonlight : l’appareil Android devient l’écran tactile du Wii U GamePad.

Une fois l’installation Batocera terminée **et l’APK Moonlight WiiU installé ou copié sur l’appareil Android**, le dossier de la release décompressée peut être supprimé. Le runtime installé se trouve dans `/userdata/system/wiiu-gamepad` et le hook Batocera dans `/userdata/system/scripts/wiiu-gamepad.sh`.

## Options Batocera / Cemu

Aucune modification manuelle des options de l’émulateur Wii U dans Batocera n’est nécessaire lorsque l’installateur est utilisé.

L’installation active automatiquement les deux paramètres requis dans `/userdata/system/batocera.conf` :

```text
wiiu.cemu_touchpad=1
wiiu.cemu_gamepad=true
```

Ces valeurs permettent d’activer l’intégration GamePad/tactile même sur une installation neuve de Batocera 44.

Si les identifiants de l’interface Web Sunshine sont oubliés, quittez d’abord la session Wii U puis réinitialisez-les avec :

```bash
/userdata/system/wiiu-gamepad/sunshine/Sunshine-NoCursor.AppImage \
  --creds NOUVEL_UTILISATEUR NOUVEAU_MOT_DE_PASSE
```

Voir également [docs/pairing.md](pairing.md) pour l’appairage complet et [docs/android.md](android.md) pour les réglages Moonlight.

## Réglages Moonlight recommandés

Le client applique automatiquement le profil Wii U normal :

- **854x480**
- **60 FPS**
- audio de l’hôte activé
- mode tactile type trackpad désactivé
- étirement de l’image désactivé
- débit automatique

Réglages facultatifs :

- **Plein écran :** peut être activé dans Moonlight et a été validé pendant le développement.
- **Débit :** peut être augmenté avec une bonne connexion pour améliorer l’image, ou diminué si le Wi-Fi provoque des saccades ou de la latence.
- Conservez **854x480 / 60 FPS** sauf besoin particulier : une résolution de streaming supérieure n’ajoute pas de détails réels au GamePad.

Moonlight WiiU conserve une petite bordure anti-gestes autour de la vidéo :

- 16 dp à gauche et à droite
- 24 dp en haut et en bas

Cela réduit les gestes Android accidentels sur les bords sans perdre trop d’espace d’affichage.

## Configuration validée

La configuration de référence a été validée avec :

- Batocera 44, x86_64, Wayland + LabWC
- Cemu Linux
- sortie GamePad virtuelle en 854x480
- tactile Android limité à la sortie GamePad
- routage audio TV / GamePad séparé
- commandes locales avec DualSense
- capture Sunshine sans curseur sur le flux GamePad
- streaming Moonlight à environ 60 FPS
- démarrage et arrêt automatiques via les hooks de jeu Wii U de Batocera
- nettoyage automatique au retour dans EmulationStation
- ajout manuel de l’hôte Moonlight si la découverte réseau échoue
- appairage via l’interface Web Sunshine depuis Android
- plein écran Moonlight avec bordure anti-gestes fixe
- pipeline Android de production avec vérification du certificat

## Correctif audio DRC de Cemu

Pendant le développement avec **ZombiU**, un bug audio DRC de Cemu a été identifié puis corrigé en amont :

- PR Cemu : https://github.com/cemu-project/Cemu/pull/2099
- Correctif : `sndcore: Fix DRC device mix mask indexing`

Ce correctif restaure l’audio DRC/GamePad qui pouvait disparaître, notamment la voix du Prepper ainsi que les sons sonar/ping de ZombiU.

Batocera 44 embarquait initialement une révision de Cemu datée du 10 septembre 2026, antérieure à ce correctif. Une version suffisamment récente de Cemu est donc recommandée.

## Structure du dépôt

```text
files/bin/             Scripts runtime Batocera
files/hook/            Hook gameStart/gameStop Batocera
files/sunshine/        Modèle de configuration Sunshine
install.sh             Installateur utilisé par les releases ZIP
uninstall.sh           Désinstallateur conservateur
tools/audit.sh         Collecteur de diagnostic sans risque
docs/architecture.md   Architecture du runtime
docs/pairing.md        Premier appairage Sunshine/Moonlight
docs/android.md        Réglages Android/Moonlight
docs/troubleshooting.md
media/gamepad-demo.mp4 Démonstration sur matériel réel
```

## Comportement de l’installateur

L’installateur est conçu pour :

- sauvegarder les fichiers avant toute modification ;
- ne modifier que les options Wii U nécessaires dans `batocera.conf` ;
- n’injecter que les règles LabWC requises ;
- configurer les sorties audio TV/GamePad de Cemu sans remplacer toute sa configuration ;
- détecter automatiquement la sortie audio TV actuelle et la disposition physique des écrans ;
- placer le GamePad virtuel après l’écran actif situé le plus à droite, y compris avec plusieurs écrans, rotations ou mises à l’échelle ;
- renseigner automatiquement dans Sunshine les origines CSRF locales à partir des adresses IPv4 actives ;
- conserver l’appairage, les certificats et les identifiants Sunshine lors des mises à niveau ;
- ne jamais utiliser `/userdata/workspace` sur une installation utilisateur.

## Vie privée et fichiers propriétaires

Ce projet ne distribue pas :

- l’état d’appairage ou les identifiants Sunshine ;
- les certificats ou clés privées ;
- le fichier `apps.json` du profil Sunshine d’un utilisateur ;
- les bibliothèques système Wii U (`*.rpl`) ni d’autres fichiers propriétaires Wii U.

N’ajoutez pas ces fichiers aux issues, commits ou archives de release.

## Client Android

Une version dédiée de Moonlight Android nommée **Moonlight WiiU** fournit le tactile direct et applique automatiquement un profil Wii U. Le flux est envoyé en 854x480/60 natif puis mis à l’échelle localement sur le téléphone ou la tablette.

Une bordure fixe de 16 dp à gauche/droite et 24 dp en haut/bas limite les gestes Android involontaires. Le patch source correspondant ainsi que le processus de build reproductible sont inclus dans ce dépôt.

## Licence

Le code d’intégration du projet est publié sous licence GPL-3.0. Les projets tiers comme Sunshine et Moonlight conservent leurs propres mentions de copyright et licences GPL.
