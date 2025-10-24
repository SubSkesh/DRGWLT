import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LocalImageService {
  /// Salva immagine localmente
  static Future<String> saveAgentImage(File image, String agentId) async {
    final directory = await getApplicationDocumentsDirectory();
    final imageDir = Directory('${directory.path}/agent_images');

    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }

    final String imagePath = '${imageDir.path}/$agentId.jpg';
    final File savedImage = await image.copy(imagePath);

    return savedImage.path;
  }

  /// Carica immagine da storage locale
  static Future<File?> getAgentImage(String? localImagePath) async {
    if (localImagePath == null) return null;

    try {
      return File(localImagePath);
    } catch (e) {
      print('Errore caricamento immagine locale: $e');
      return null;
    }
  }

  /// Cancella immagine locale
  static Future<void> deleteAgentImage(String localImagePath) async {
    try {
      final file = File(localImagePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Errore cancellazione immagine locale: $e');
    }
  }
}