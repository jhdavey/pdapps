import 'package:flutter/material.dart';
import 'package:pd/services/auth/auth_service.dart';

class BuildDetailView extends StatelessWidget {
  const BuildDetailView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Extract all the arguments
    final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
    final buildId = args['buildId'] as int;
    final buildUserId = args['userId'] as int; 
    final displayName = args['displayName'] as String;
    final year = args['year'] as int;
    final make = args['make'] as String;
    final model = args['model'] as String;

    final currentUserId = AuthService.instance.currentUser?.id ?? 0;
    final isOwner = (buildUserId == currentUserId);

    return Scaffold(
      appBar: AppBar(
        title: Text("$displayName's build $year $make $model"),
        actions: [
          if (isOwner)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () {
                Navigator.of(context).pushNamed(
                  '/create-build',
                  arguments: {
                    'isEdit': true,
                    'buildId': buildId,
                  },
                );
              },
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const SizedBox(height: 16),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  image: const DecorationImage(
                    image: NetworkImage('https://picsum.photos/600/300'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
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
