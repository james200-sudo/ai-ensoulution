@echo off
echo ========================================
echo NETTOYAGE COMPLET DU PROJET FLUTTER
echo ========================================
echo.

:: Se déplacer dans le répertoire du projet
cd /d "E:\projet\v2 TGM\Flutter\v2\ai-chatbot"
echo Repertoire actuel: %CD%
echo.

:: Étape 1: Arrêter tous les daemons Gradle
echo [1/8] Arret des daemons Gradle...
cd android
call gradlew --stop
cd ..
echo ✓ Daemons Gradle arretes
echo.

:: Étape 2: Nettoyage Flutter
echo [2/8] Nettoyage Flutter...
call flutter clean
echo ✓ Flutter clean termine
echo.

:: Étape 3: Supprimer le dossier build
echo [3/8] Suppression du dossier build...
if exist build (
    rd /s /q build
    echo ✓ Dossier build supprime
) else (
    echo - Dossier build inexistant
)
echo.

:: Étape 4: Supprimer .dart_tool
echo [4/8] Suppression de .dart_tool...
if exist .dart_tool (
    rd /s /q .dart_tool
    echo ✓ Dossier .dart_tool supprime
) else (
    echo - Dossier .dart_tool inexistant
)
echo.

:: Étape 5: Supprimer android\.gradle
echo [5/8] Suppression de android\.gradle...
if exist android\.gradle (
    rd /s /q android\.gradle
    echo ✓ Dossier android\.gradle supprime
) else (
    echo - Dossier android\.gradle inexistant
)
echo.

:: Étape 6: Supprimer android\app\build
echo [6/8] Suppression de android\app\build...
if exist android\app\build (
    rd /s /q android\app\build
    echo ✓ Dossier android\app\build supprime
) else (
    echo - Dossier android\app\build inexistant
)
echo.

:: Étape 7: Récupération des dépendances
echo [7/8] Recuperation des dependances Flutter...
call flutter pub get
echo ✓ Dependances recuperees
echo.

:: Étape 8: Build APK
echo [8/8] Construction de l'APK...
echo Cette etape peut prendre plusieurs minutes...
echo.
call flutter build apk --release

echo.
echo ========================================
echo PROCESSUS TERMINE
echo ========================================
echo.
echo Si le build a reussi, votre APK se trouve dans:
echo %CD%\build\app\outputs\flutter-apk\app-release.apk
echo.
pause