import 'package:flutter/material.dart';

class PublisherBadge extends StatelessWidget {
  final String sourceName;
  final double size;

  const PublisherBadge({
    super.key,
    required this.sourceName,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    final lower = sourceName.toLowerCase();

    Color bgColor = const Color(0xFF1877F2);
    String initials = sourceName.isNotEmpty ? sourceName[0].toUpperCase() : 'N';

    if (lower.contains('bbc')) {
      bgColor = const Color(0xFFBB1919); // BBC red
      initials = 'BBC';
    } else if (lower.contains('cnn')) {
      bgColor = const Color(0xFFCC0000); // CNN red
      initials = 'CNN';
    } else if (lower.contains('usa today') || lower.contains('usa')) {
      bgColor = const Color(0xFF009BDE); // USA Today cyan
      initials = 'USA';
    } else if (lower.contains('guardian')) {
      bgColor = const Color(0xFF052962); // Guardian navy
      initials = 'G';
    } else if (lower.contains('verge')) {
      bgColor = const Color(0xFFE51253);
      initials = 'V';
    } else if (lower.contains('reuters')) {
      bgColor = const Color(0xFFFF8000);
      initials = 'R';
    }

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Text(
        initials,
        style: TextStyle(
          color: Colors.white,
          fontSize: size * 0.42,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
        ),
      ),
    );
  }
}
