import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class WhatsAppFAB extends StatelessWidget {
  final String phone;
  const WhatsAppFAB({required this.phone, super.key});

  Future<void> _openWhatsApp() async {
    final uri = Uri.parse('https://wa.me/${phone.replaceAll('+', '')}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: _openWhatsApp,
      backgroundColor: const Color(0xFF25D366),
      child: const Icon(Icons.chat, color: Colors.white),
    );
  }
}
