import 'package:flutter/material.dart';
import 'package:drgwallet/router.dart';
import 'package:auto_route/auto_route.dart';
@RoutePage(name: 'ToDeleteRoute')

class TestSliverAppbar extends StatelessWidget {
  const TestSliverAppbar({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          //i dont wanna that sliverappbar starts expanded
          pinned: true,
          expandedHeight: 200.0,
          flexibleSpace: FlexibleSpaceBar(
            title: Text('Sliver Example'),
          ),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
                (context, index) => ListTile(title: Text('Item #$index')),
            childCount: 20,
          ),
        ),
        SliverGrid(
          delegate: SliverChildBuilderDelegate(
                (context, index) => Container(
              color: index.isEven ? Colors.blue : Colors.green,
            ),
            childCount: 8,
          ),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
          ),
        ),
      ],
    );

  }
}
