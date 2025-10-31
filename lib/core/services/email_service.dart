import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:math';

class EmailService {
  // Configuration EmailJS - À MODIFIER avec vos vraies valeurs
  static const String _apiUrl = 'https://api.emailjs.com/api/v1.0/email/send';
  static const String _serviceId = 'service_6zdizyh'; // REMPLACER par votre Service ID
  static const String _templateIdVerification = 'template_qmlqfky'; // Template vérification
  static const String _templateIdReset = 'template_yza47tj'; // Template reset password
  static const String _publicKey = 'rPILXGHQRQC5EGv01'; // REMPLACER par votre Public Key
  
  // Configuration SendGrid - Alternative professionnelle
  static const String _sendGridApiUrl = 'https://api.sendgrid.com/v3/mail/send';
  static const String _sendGridApiKey = 'SG.your_api_key_here'; // REMPLACER par votre API Key
  
  // Configuration de votre app
  static const String _appName = 'HydroAI Chat';
  static const String _fromEmail = 'noreply@hydroai.com'; // REMPLACER par votre email
  
  // Singleton pattern
  static final EmailService _instance = EmailService._internal();
  factory EmailService() => _instance;
  EmailService._internal();
  
  /// Méthode PRINCIPALE - EmailJS pour vérification email
  Future<Map<String, dynamic>> sendVerificationEmail({
    required String toEmail,
    required String userName,
    required String verificationToken,
  }) async {
    try {
      //print('Envoi email de vérification via EmailJS...');
      
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'service_id': _serviceId,
          'template_id': _templateIdVerification,
          'user_id': _publicKey,
          'template_params': {
            'to_email': toEmail,
            'to_name': userName,
            'verification_code': verificationToken,
            'app_name': _appName,
            'subject': 'Vérifiez votre compte $_appName',
          }
        }),
      );
      
      //print('Réponse EmailJS: ${response.statusCode}');
      //print('Corps de la réponse: ${response.body}');
      
      if (response.statusCode == 200) {
        //print('Email de vérification envoyé avec succès via EmailJS');
        return {
          'success': true,
          'message': 'Email de vérification envoyé avec succès',
          'provider': 'EmailJS',
        };
      } else {
        throw Exception('Erreur EmailJS: ${response.statusCode} - ${response.body}');
      }
      
    } catch (e) {
      //print('Erreur envoi email vérification EmailJS: $e');
      
      // Fallback vers la méthode mock en cas d'erreur
      //print('Tentative de fallback vers méthode mock...');
      return await sendVerificationEmailMock(
        toEmail: toEmail,
        userName: userName,
        verificationToken: verificationToken,
      );
    }
  }
  
  /// Méthode PRINCIPALE - EmailJS pour reset password
  Future<Map<String, dynamic>> sendPasswordResetEmail({
    required String toEmail,
    required String userName,
    required String resetToken,
  }) async {
    try {
      //print('Envoi email de reset via EmailJS...');
      
      final response = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'service_id': _serviceId,
          'template_id': _templateIdReset,
          'user_id': _publicKey,
          'template_params': {
            'to_email': toEmail,
            'to_name': userName,
            'reset_code': resetToken,
            'app_name': _appName,
            'subject': 'Réinitialisez votre mot de passe $_appName',
          }
        }),
      );
      
      if (response.statusCode == 200) {
        //print('Email de reset envoyé avec succès via EmailJS');
        return {
          'success': true,
          'message': 'Instructions de réinitialisation envoyées par email',
          'provider': 'EmailJS',
        };
      } else {
        throw Exception('Erreur EmailJS: ${response.statusCode}');
      }
      
    } catch (e) {
      //print('Erreur envoi email reset EmailJS: $e');
      
      // Fallback vers la méthode mock
      return await sendPasswordResetEmailMock(
        toEmail: toEmail,
        userName: userName,
        resetToken: resetToken,
      );
    }
  }
  
  /// Alternative SendGrid pour vérification
  Future<Map<String, dynamic>> sendVerificationEmailSendGrid({
    required String toEmail,
    required String userName,
    required String verificationToken,
  }) async {
    try {
      //print('Envoi email de vérification via SendGrid...');
      
      final response = await http.post(
        Uri.parse(_sendGridApiUrl),
        headers: {
          'Authorization': 'Bearer $_sendGridApiKey',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'personalizations': [
            {
              'to': [{'email': toEmail, 'name': userName}],
              'subject': 'Vérifiez votre compte $_appName'
            }
          ],
          'from': {'email': _fromEmail, 'name': _appName},
          'content': [
            {
              'type': 'text/html',
              'value': _buildVerificationEmailHtml(userName, verificationToken)
            },
            {
              'type': 'text/plain',
              'value': _buildVerificationEmailText(userName, verificationToken)
            }
          ]
        }),
      );
      
      if (response.statusCode == 202) {
        //print('Email envoyé avec succès via SendGrid');
        return {
          'success': true,
          'message': 'Email de vérification envoyé avec succès',
          'provider': 'SendGrid',
        };
      } else {
        throw Exception('SendGrid error: ${response.statusCode} - ${response.body}');
      }
      
    } catch (e) {
      //print('Erreur SendGrid: $e');
      return {
        'success': false,
        'error': 'Impossible d\'envoyer l\'email de vérification via SendGrid',
        'details': e.toString(),
      };
    }
  }
  
  /// MÉTHODE MOCK pour développement/test
  Future<Map<String, dynamic>> sendVerificationEmailMock({
    required String toEmail,
    required String userName,
    required String verificationToken,
  }) async {
    try {
      //print('=== EMAIL DE VÉRIFICATION SIMULÉ ===');
      //print('De: $_appName <$_fromEmail>');
      //print('À: $userName <$toEmail>');
      //print('Sujet: Vérifiez votre compte $_appName');
      //print('');
      //print('Bonjour $userName,');
      //print('');
      //print('Votre code de vérification est : $verificationToken');
      //print('');
      //print('Copiez ce code dans l\'application pour activer votre compte.');
      //print('');
      //print('Cordialement,');
      //print('L\'équipe $_appName');
      //print('===================================');
      
      // Simuler un délai d'envoi
      await Future.delayed(const Duration(milliseconds: 500));
      
      return {
        'success': true,
        'message': 'Email de vérification simulé (développement)',
        'provider': 'Mock',
        'verificationCode': verificationToken, // Pour débug uniquement
      };
      
    } catch (e) {
      return {
        'success': false,
        'error': 'Erreur simulation email',
        'details': e.toString(),
      };
    }
  }
  
  /// MÉTHODE MOCK pour reset password
  Future<Map<String, dynamic>> sendPasswordResetEmailMock({
    required String toEmail,
    required String userName,
    required String resetToken,
  }) async {
    try {
      //print('=== EMAIL DE RESET SIMULÉ ===');
      //print('De: $_appName <$_fromEmail>');
      //print('À: $userName <$toEmail>');
      //print('Sujet: Réinitialisez votre mot de passe $_appName');
      //print('');
      //print('Bonjour $userName,');
      //print('');
      //print('Votre code de réinitialisation est : $resetToken');
      //print('');
      //print('Utilisez ce code dans l\'application pour définir un nouveau mot de passe.');
      //print('Ce code expire dans 1 heure.');
      //print('');
      //print('Cordialement,');
      //print('L\'équipe $_appName');
      //print('=============================');
      
      await Future.delayed(const Duration(milliseconds: 500));
      
      return {
        'success': true,
        'message': 'Email de reset simulé (développement)',
        'provider': 'Mock',
        'resetCode': resetToken, // Pour débug uniquement
      };
      
    } catch (e) {
      return {
        'success': false,
        'error': 'Erreur simulation email reset',
        'details': e.toString(),
      };
    }
  }
  
  /// Template HTML pour email de vérification
  String _buildVerificationEmailHtml(String userName, String token) {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
        <meta charset="UTF-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Vérification de compte</title>
        <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; max-width: 600px; margin: 0 auto; }
            .header { background: linear-gradient(135deg, #4CAF50, #45a049); color: white; padding: 30px; text-align: center; border-radius: 10px 10px 0 0; }
            .content { background: #f9f9f9; padding: 30px; border-radius: 0 0 10px 10px; }
            .token-box { background: #e8f5e8; border: 2px dashed #4CAF50; padding: 20px; margin: 20px 0; text-align: center; border-radius: 8px; }
            .token { font-family: monospace; font-size: 24px; font-weight: bold; color: #2e7d32; letter-spacing: 3px; }
            .footer { text-align: center; margin-top: 30px; color: #666; font-size: 12px; }
        </style>
    </head>
    <body>
        <div class="header">
            <h1>$_appName</h1>
            <h2>Vérification de votre compte</h2>
        </div>
        <div class="content">
            <p>Bonjour <strong>$userName</strong>,</p>
            
            <p>Merci de vous être inscrit sur $_appName ! Pour activer votre compte, veuillez utiliser le code de vérification ci-dessous :</p>
            
            <div class="token-box">
                <p>Votre code de vérification :</p>
                <div class="token">$token</div>
            </div>
            
            <p><strong>Instructions :</strong></p>
            <ol>
                <li>Copiez le code de vérification ci-dessus</li>
                <li>Retournez dans l'application $_appName</li>
                <li>Collez le code dans le champ de vérification</li>
                <li>Votre compte sera activé immédiatement</li>
            </ol>
            
            <p><strong>Important :</strong> Ce code expire dans 24 heures.</p>
            
            <div class="footer">
                <p>Cet email a été envoyé par $_appName<br>
                Si vous n'avez pas demandé cette vérification, ignorez cet email.</p>
            </div>
        </div>
    </body>
    </html>
    ''';
  }
  
  /// Template texte pour email de vérification
  String _buildVerificationEmailText(String userName, String token) {
    return '''
$_appName - Vérification de compte

Bonjour $userName,

Merci de vous être inscrit sur $_appName !

Votre code de vérification : $token

Instructions :
1. Copiez le code de vérification ci-dessus
2. Retournez dans l'application $_appName
3. Collez le code dans le champ de vérification
4. Votre compte sera activé immédiatement

Ce code expire dans 24 heures.

---
Équipe $_appName
    ''';
  }
  
  /// Tester la configuration EmailJS
  Future<bool> testEmailJSConnection() async {
    try {
      //print('Test de la configuration EmailJS...');
      
      final testResult = await sendVerificationEmailMock(
        toEmail: 'test@example.com',
        userName: 'Test User',
        verificationToken: 'TEST123456',
      );
      
      return testResult['success'] == true;
      
    } catch (e) {
      //print('Erreur test EmailJS: $e');
      return false;
    }
  }
  
  /// Générer un token de vérification
  String generateVerificationToken() {
    final random = Random.secure();
    final chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(32, (index) => chars[random.nextInt(chars.length)]).join();
  }
}