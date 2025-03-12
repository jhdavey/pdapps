import 'package:flutter/material.dart';
import 'package:pd/widgets/builds/build_card.dart';

Widget buildHorizontalList(List<dynamic> builds) {
  return SizedBox(
    height: 380,
    child: ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: builds.length,
      itemBuilder: (context, index) {
        final build = builds[index];
        return GestureDetector(
          onTap: () {
            Navigator.of(context).pushNamed('/build-view', arguments: build);
          },
          // Add any onLongPress logic if needed.
          child: SizedBox(
            width: 300,  // Constrain each card's width
            child: BuildCard(buildData: build),
          ),
        );
      },
    ),
  );
}
