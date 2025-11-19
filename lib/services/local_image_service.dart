import 'dart:io';
import 'package:path_provider/path_provider.dart';

class LocalImageService {

  /// Salva immagine localmente e restituisce SOLO il nome del file
  static Future<String> saveAgentImage(File image, String agentId) async {
    final directory = await getApplicationDocumentsDirectory();
    final imageDir = Directory('${directory.path}/agent_images');

    if (!await imageDir.exists()) {
      await imageDir.create(recursive: true);
    }

    // Creiamo un nome file univoco
    final String fileName = '$agentId.jpg';
    final String fullPath = '${imageDir.path}/$fileName';

    // Copiamo l'immagine
    await image.copy(fullPath);

    // IMPORTANTE: Restituiamo solo il nome del file, non tutto il percorso!
    return fileName;
  }

  /// Carica immagine ricostruendo il percorso dinamico
  static Future<File?> getAgentImage(String? fileName) async {
    if (fileName == null || fileName.isEmpty) return null;

    try {
      final directory = await getApplicationDocumentsDirectory();
      // Ricostruiamo il percorso completo usando la directory CORRENTE
      final String fullPath = '${directory.path}/agent_images/$fileName';

      final file = File(fullPath);

      if (await file.exists()) {
        return file;
      } else {
        // Fallback per vecchie versioni (se avevi salvato percorsi assoluti)
        // Se il file non esiste nel nuovo percorso, proviamo a vedere se la stringa
        // era un vecchio percorso assoluto che per miracolo funziona ancora
        final oldFile = File(fileName);
        if (await oldFile.exists()) return oldFile;

        return null;
      }
    } catch (e) {
      print('Errore caricamento immagine locale: $e');
      return null;
    }
  }

  /// Cancella immagine locale
  static Future<void> deleteAgentImage(String fileName) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final String fullPath = '${directory.path}/agent_images/$fileName';

      final file = File(fullPath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Errore cancellazione immagine locale: $e');
    }
  }
}