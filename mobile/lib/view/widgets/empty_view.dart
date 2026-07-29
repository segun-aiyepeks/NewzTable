import 'package:flutter/material.dart';

class EmptyView extends StatelessWidget {
  final String title;
  final String message;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  const EmptyView({
    super.key,
    required this.title,
    required this.message,
    this.icon = Icons.inbox_outlined,
    this.actionLabel,
    this.onAction
  });

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
              decoration: BoxDecoration(color: colorScheme.primaryContainer, shape: BoxShape.circle),
              child: Icon(
                icon,
                size: 36,
                color: colorScheme.onPrimaryContainer
              ),
            ),
            SizedBox(height: 24),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              textAlign: TextAlign.center
            ),
            SizedBox(height: 8),
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(color: colorScheme.outline),
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis
            ),
            if (actionLabel != null && onAction != null) ...[
              SizedBox(height: 32),
              FilledButton(onPressed: onAction, child: Text(actionLabel!))
            ]
          ],
        ),  
      ),
    );
  }
}