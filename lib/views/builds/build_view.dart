import 'package:flutter/material.dart';

class BuildDetailView extends StatelessWidget {
  const BuildDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Pull the arguments from the route
    final args =
        ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final displayName = args['displayName'] as String;
    final year = args['year'] as int;
    final make = args['make'] as String;
    final model = args['model'] as String;

    return Scaffold(
      appBar: AppBar(
        title: Text("$displayName's $year $make $model"),
      ),
      // Wrap the body in a Padding so the content isn't flush with the screen edges
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              // Large featured image
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.red, // Temporary color for debugging
                  borderRadius: BorderRadius.circular(8),
                  image: const DecorationImage(
                    image: NetworkImage('https://picsum.photos/600/300'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Grid of placeholders
              GridView.count(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  for (int i = 0; i < 6; i++)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.blue, // Another debug color
                        borderRadius: BorderRadius.circular(8),
                        image: const DecorationImage(
                          image: NetworkImage('https://picsum.photos/150'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
