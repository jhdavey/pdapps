// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:pd/helpers/build_ownership_helper.dart';
import 'package:pd/helpers/route_arguments_helper.dart';
import 'package:pd/services/api/build/build_data_loader.dart';
import 'package:pd/widgets/builds/build_additional_images_section.dart';
import 'package:pd/widgets/builds/build_comment_section.dart';
import 'package:pd/widgets/builds/build_data_section.dart';
import 'package:pd/widgets/builds/build_modification_section.dart';
import 'package:pd/widgets/builds/build_note_section.dart';
import 'package:pd/widgets/builds/build_tag_section.dart';

class BuildView extends StatefulWidget {
  const BuildView({super.key});

  @override
  State<BuildView> createState() => _BuildViewState();
}

class _BuildViewState extends State<BuildView> {
  late Map<String, dynamic> _build;
  bool _initialized = false;
  String? _currentUserId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initialized) {
      _build = getRouteArguments(context);

      _loadBuildData();

      updateBuildOwnership(context, _build).then((userId) {
        _currentUserId = userId;
        setState(() {});
      });

      _initialized = true;
    }
  }

  Future<void> _loadBuildData() async {
    if (_build.isNotEmpty && _build.containsKey('id')) {
      final buildId = _build['id'].toString(); // Ensure it's a string
      final data = await loadBuildDataHelper(buildId, context);
      if (data != null) {
        setState(() {
          _build['modificationsByCategory'] = data['modificationsByCategory'];
          _build['notes'] = data['notes'];
          _build['comments'] = data['comments'];
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _build['user'] ?? {};
    final userName = user['name'] ?? 'Unknown User';
    final bool isOwner = _build['is_owner'] ?? false;

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/garage', arguments: user['id']);
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.center,
            children: [
              Text(
                "$userName's ${_build['build_category'] ?? ''} Build",
                style: const TextStyle(fontSize: 24),
              ),
              Text(
                'Click here to view profile',
                style: TextStyle(fontSize: 14, color: Colors.white70, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: isOwner
            ? [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    final updatedBuild = await Navigator.pushNamed(
                      context,
                      '/edit-build-view',
                      arguments: {'build': _build},
                    );
                    if (updatedBuild != null && mounted) {
                      setState(() {
                        _build = updatedBuild as Map<String, dynamic>;
                      });
                    }
                  },
                ),
              ]
            : null,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: _buildContent(isOwner),
      ),
    );
  }

  Widget _buildContent(bool isOwner) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "${_build['year'] ?? ''} ${_build['make'] ?? ''} ${_build['model'] ?? ''}"
          "${_build['trim'] != null ? ' ${_build['trim']}' : ''}",
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            _build['image'] ?? 'https://via.placeholder.com/780',
            fit: BoxFit.cover,
            width: double.infinity,
          ),
        ),
        buildAdditionalImagesSection(_build),
        const SizedBox(height: 8),
        BuildTags(buildData: _build),
        buildSection(
          title: 'Specs',
          dataPoints: [
            {'label': 'Horsepower', 'value': _build['hp']},
            {'label': 'Wheel HP', 'value': _build['whp']},
            {'label': 'Torque', 'value': _build['torque']},
            {'label': 'Weight', 'value': _build['weight']},
          ],
        ),
        buildSection(
          title: 'Performance',
          dataPoints: [
            {'label': '0-60 mph', 'value': _build['zeroSixty']},
            {'label': '0-100 mph', 'value': _build['zeroOneHundred']},
            {'label': 'Quarter Mile', 'value': _build['quarterMile']},
          ],
        ),
        buildSection(
          title: 'Platform',
          dataPoints: [
            {'label': 'Vehicle Layout', 'value': _build['vehicleLayout']},
            {'label': 'Transmission', 'value': _build['trans']},
            {'label': 'Engine Type', 'value': _build['engineType']},
            {'label': 'Engine Code', 'value': _build['engineCode']},
            {'label': 'Forced Induction', 'value': _build['forcedInduction']},
            {'label': 'Fuel Type', 'value': _build['fuel']},
            {'label': 'Suspension', 'value': _build['suspension']},
            {'label': 'Brakes', 'value': _build['brakes']},
          ],
        ),
        BuildModificationsSection(
          modificationsByCategory:
              _build['modificationsByCategory'] is Map<String, dynamic>
                  ? _build['modificationsByCategory'] as Map<String, dynamic>
                  : {},
          buildId: _build['id'],
          isOwner: isOwner,
          reloadBuildData: _loadBuildData,
        ),
        const SizedBox(height: 20),
        BuildNotesSection(
          notes: _build['notes'] as List<dynamic>? ?? [],
          buildId: _build['id'],
          isOwner: isOwner,
          reloadBuildData: _loadBuildData,
        ),
        const SizedBox(height: 20),
        BuildCommentsSection(
          comments: _build['comments'] as List<dynamic>? ?? [],
          buildId: _build['id'].toString(),
          currentUserId: _currentUserId,
          reloadBuildData: _loadBuildData,
        ),
      ],
    );
  }
}
