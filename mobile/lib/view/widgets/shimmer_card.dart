import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Shimmer.fromColors(
      baseColor: colorScheme.surfaceContainerHighest, 
      highlightColor: colorScheme.surface,
      child: Card(
        margin: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: Padding(
          padding: EdgeInsets.all(12.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Container(
                      width: 80, 
                      height: 10,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                    ),
                    SizedBox(width: 8.0),
                    Container(
                      width: 50,
                      height: 10,
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                    )
                  ],),
                  SizedBox(height: 8.0),
                  Container(
                    width: double.infinity,
                    height: 12,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))
                  ),
                  SizedBox(height: 6.0),
                  Container(
                    width: double.infinity,
                    height: 12,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                  ),
                  SizedBox(height: 6),
                  Container(
                    width: 180,
                    height: 12,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4)),
                  ),
                  SizedBox(height: 10.0),
                  Container(
                    width: 70,
                    height: 20,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                  )
                ]
              ),),
              SizedBox(width: 12),
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
              )
            ],
          ),
        ),
      )
    );
  }
}

class ShimmerList extends StatelessWidget {
  final int itemCount;
  const ShimmerList({super.key, required this.itemCount});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: (context, index) => ShimmerCard(),
    );
  }
}