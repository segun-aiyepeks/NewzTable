import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:newztable/model/article_model.dart';

class ArticleCard extends StatelessWidget {
  final ArticleModel article;
  final VoidCallback onTap;
  final VoidCallback? onBookMarkTap;
  final bool isBookmarked;

  const ArticleCard({
    super.key,
    required this.article,
    required this.onTap,
    this.onBookMarkTap,
    this.isBookmarked = false
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        article.sourceName,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600
                        ),
                      ),
                      SizedBox(width: 8.0,),
                      Text(
                        '.',
                        style: theme.textTheme.labelSmall?.copyWith(color: colorScheme.outline),
                      )
                    ],
                  ),
                  SizedBox(height: 6.0,),
                  Text(
                    article.title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      height: 1.3
                    ),
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis
                  ),
                  SizedBox(height: 8.0),
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: colorScheme.primaryContainer,
                          borderRadius: BorderRadius.circular(20)
                        ),
                        child: Text(
                          article.topic.toUpperCase(),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w600,
                            fontSize: 10
                          ),
                        ),
                      ),
                      Spacer(),
                      if(onBookMarkTap != null)
                        GestureDetector(
                          onTap: onBookMarkTap,
                          child: Icon(
                            isBookmarked? Icons.bookmark : Icons.bookmark_border,
                            size: 20,
                            color: isBookmarked? colorScheme.primary : colorScheme.outline,
                          ),
                        )
                    ]
                  )
                ]
              )),
              if(article.imageUrl != null) ...[
                SizedBox(width: 12.0),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: CachedNetworkImage(
                    imageUrl: article.imageUrl!,
                    width: 90,
                    height: 90,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      width: 90,
                      height: 90,
                      color: colorScheme.surfaceContainerHighest,
                    ),
                    errorWidget: (context, url, error) => Container(
                      width: 90,
                      height: 90,
                      color: colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: colorScheme.outline,
                      ),
                    ),
                  ),
                )
              ]
            ],
          ),
        ),
      ),
    );
  }
}