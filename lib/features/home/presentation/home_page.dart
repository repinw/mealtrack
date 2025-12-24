import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mealtrack/features/inventory/presentation/inventory_page.dart';
import 'package:mealtrack/features/scanner/presentation/receipt_edit_page.dart';
import 'package:mealtrack/features/scanner/service/firebase_ai_service.dart';

class HomePage extends StatefulWidget {
  final ImagePicker imagePicker;
  final FirebaseAiService firebaseAiService;

  const HomePage({
    super.key,
    required this.imagePicker,
    required this.firebaseAiService,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _isBusy = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _buildSpeedDial(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Center(
        child: _isBusy
            ? const CircularProgressIndicator()
            : const InventoryPage(title: 'Digitaler Kühlschrank'),
      ),
    );
  }

  Widget _buildSpeedDial() {
    if (_isBusy) return const SizedBox.shrink();

    return SpeedDial(
      icon: Icons.add,
      activeIcon: Icons.close,
      spacing: 3,
      childPadding: const EdgeInsets.all(5),
      spaceBetweenChildren: 4,
      children: [
        SpeedDialChild(
          child: const Icon(Icons.photo_library),
          label: 'Bild aus Galerie',
          onTap: _processImageFromGallery,
        ),
      ],
    );
  }

  Future<void> _processImageFromGallery() async {
    try {
      final XFile? image = await widget.imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1500,
        imageQuality: 80,
      );

      if (image == null) {
        return;
      }

      setState(() => _isBusy = true);

      final result = await widget.firebaseAiService.analyzeImageWithGemini(
        image,
      );

      if (!mounted) return;

      if (result.isEmpty) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Keine Produkte erkannt')));
        return;
      }

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => ReceiptEditPage(scannedItems: result),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Fehler bei der Texterkennung: $e');
      debugPrintStack(stackTrace: stackTrace);

      if (mounted) {
        _showErrorSnackBar(e);
      }
    } finally {
      if (mounted) {
        setState(() => _isBusy = false);
      }
    }
  }

  void _showErrorSnackBar(Object error) {
    String message = error.toString();
    if (message.contains('FormatException')) {
      message = 'Der Kassenbon konnte nicht gelesen werden (Format-Fehler).';
    } else {
      message = 'Ein Fehler ist aufgetreten.';
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}
