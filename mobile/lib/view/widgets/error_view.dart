import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final IconData icon;
  const ErrorView({super.key, required this.message, required this.onRetry, this.icon = Icons.wifi_off_rounded});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(color: colorScheme.errorContainer, shape: BoxShape.circle),
              child: Icon(icon, size: 36, color: colorScheme.onErrorContainer)
            ),
            SizedBox(height: 24),
            Text(
              'Something went wrong',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center  
            ),
            SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 32),
            FilledButton.icon(
              onPressed: onRetry, 
              icon: Icon(Icons.refresh_rounded),
              label: Text('Try Again')
            )
          ],
        ),
      ),
    );
  }
}