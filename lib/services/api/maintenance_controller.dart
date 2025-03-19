// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:pd/services/api/auth/auth_service.dart';

class MaintenanceRecordService {
  final String baseUrl;
  MaintenanceRecordService({required this.baseUrl});

  /// Fetches maintenance records for a given build.
  Future<List<dynamic>?> fetchMaintenanceRecords(
    BuildContext context, {
    required int buildId,
  }) async {
    final authService = RepositoryProvider.of<ApiAuthService>(context);
    final token = await authService.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not authenticated")),
      );
      return null;
    }
    final url = "$baseUrl/builds/$buildId/maintenance-records";
    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['records'] as List<dynamic>;
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? "An error occurred";
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $errorMessage")));
        return null;
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
      return null;
    }
  }

  /// Creates a new maintenance record.
  Future<bool> createMaintenanceRecord(
    BuildContext context, {
    required int buildId,
    DateTime? date,
    required String description,
    String? odometer,
    String? servicedBy,
    String? cost,
  }) async {
    final authService = RepositoryProvider.of<ApiAuthService>(context);
    final token = await authService.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not authenticated")));
      return false;
    }
    final url = "$baseUrl/builds/$buildId/maintenance-records";
    final body = {
      'date': date?.toIso8601String(),
      'description': description,
      'odometer': odometer,
      'serviced_by': servicedBy,
      'cost': cost,
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );
      if (response.statusCode == 201) {
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? "An error occurred";
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $errorMessage")));
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
      return false;
    }
  }

  Future<bool> updateMaintenanceRecord(
    BuildContext context, {
    required int buildId,
    required int recordId,
    DateTime? date,
    required String description,
    String? odometer,
    String? servicedBy,
    String? cost,
  }) async {
    final authService = RepositoryProvider.of<ApiAuthService>(context);
    final token = await authService.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not authenticated")));
      return false;
    }
    final url = "$baseUrl/builds/$buildId/maintenance-records/$recordId";

    // Convert empty or whitespace-only strings to null.
    final String? preparedOdometer =
        (odometer == null || odometer.trim().isEmpty) ? null : odometer;
    final String? preparedServicedBy =
        (servicedBy == null || servicedBy.trim().isEmpty) ? null : servicedBy;
    final double? costValue =
        (cost == null || cost.trim().isEmpty) ? null : double.tryParse(cost);

    final body = {
      'date': date?.toIso8601String(),
      'description': description,
      'odometer': preparedOdometer,
      'serviced_by': preparedServicedBy,
      'cost': costValue,
    };

    try {
      final response = await http.put(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(body),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        String errorMessage = "An error occurred";
        if (errorData.containsKey('errors')) {
          if (errorData['errors'].containsKey('cost')) {
            errorMessage = errorData['errors']['cost'][0];
          } else if (errorData['errors'].containsKey('description')) {
            errorMessage = errorData['errors']['description'][0];
          } else {
            errorMessage = errorData['message'] ?? response.body;
          }
        } else {
          errorMessage = errorData['message'] ?? response.body;
        }
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $errorMessage")));
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
      return false;
    }
  }

  Future<bool> deleteMaintenanceRecord(
    BuildContext context, {
    required int buildId,
    required int recordId,
  }) async {
    final authService = RepositoryProvider.of<ApiAuthService>(context);
    final token = await authService.getToken();
    if (token == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("User not authenticated")));
      return false;
    }
    final url = "$baseUrl/builds/$buildId/maintenance-records/$recordId";

    try {
      final response = await http.delete(
        Uri.parse(url),
        headers: {
          "Content-Type": "application/json",
          "Accept": "application/json",
          "Authorization": "Bearer $token",
        },
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        final errorData = jsonDecode(response.body);
        final errorMessage = errorData['message'] ?? "An error occurred";
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Error: $errorMessage")));
        return false;
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
      return false;
    }
  }
}
