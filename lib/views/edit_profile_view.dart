// ignore_for_file: library_private_types_in_public_api, use_build_context_synchronously

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pd/services/api/update_profile_controller.dart';
import 'package:pd/utilities/dialogs/delete_dialog.dart';

class EditProfileView extends StatefulWidget {
  final Map<String, dynamic> user;

  const EditProfileView({super.key, required this.user});

  @override
  _EditProfileViewState createState() => _EditProfileViewState();
}

class _EditProfileViewState extends State<EditProfileView> {
  final _formKey = GlobalKey<FormState>();
  late String _name;
  late String _email;
  late String _bio;
  late String _instagram;
  late String _facebook;
  late String _tiktok;
  late String _youtube;
  File? _profileImage;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _name = widget.user['name'] ?? '';
    _email = widget.user['email'] ?? '';
    _bio = widget.user['bio'] ?? '';
    _instagram = widget.user['instagram'] ?? '';
    _facebook = widget.user['facebook'] ?? '';
    _tiktok = widget.user['tiktok'] ?? '';
    _youtube = widget.user['youtube'] ?? '';
  }

  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitProfile() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();

    setState(() {
      _isSubmitting = true;
    });

    final success = await updateProfile(
      context: context,
      name: _name,
      email: _email,
      bio: _bio,
      instagram: _instagram,
      facebook: _facebook,
      tiktok: _tiktok,
      youtube: _youtube,
      profileImage: _profileImage,
    );

    if (success) {
      Navigator.pop(context, true);
    }

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  Future<void> _deleteProfile() async {
    final confirmDelete = await showDeleteDialog(context, 'account');
    if (!confirmDelete) return;

    setState(() {
      _isSubmitting = true;
    });

    final success = await deleteProfile(context);

    if (success) {
      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
    }

    if (mounted) {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: _deleteProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[800],
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!)
                      : (widget.user['profile_image'] != null &&
                              widget.user['profile_image'].isNotEmpty
                          ? NetworkImage(widget.user['profile_image'])
                              as ImageProvider
                          : AssetImage('assets/images/profile_placeholder.png')),
                  child: _profileImage == null
                      ? const Icon(Icons.camera_alt, color: Colors.white70)
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              _buildTextField('Name*', _name, (value) => _name = value),
              const SizedBox(height: 16),
              _buildTextField('Email*', _email, (value) => _email = value, keyboardType: TextInputType.emailAddress),
              const SizedBox(height: 16),
              _buildTextField('Bio', _bio, (value) => _bio = value, maxLines: 3),
              const SizedBox(height: 16),
              _buildTextField('Instagram', _instagram, (value) => _instagram = value),
              const SizedBox(height: 16),
              _buildTextField('Facebook', _facebook, (value) => _facebook = value),
              const SizedBox(height: 16),
              _buildTextField('TikTok', _tiktok, (value) => _tiktok = value),
              const SizedBox(height: 16),
              _buildTextField('YouTube', _youtube, (value) => _youtube = value),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _isSubmitting ? null : _submitProfile,
                child: _isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    String initialValue,
    Function(String) onSaved, {
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      initialValue: initialValue,
      maxLines: maxLines,
      keyboardType: keyboardType,
      onSaved: (value) => onSaved(value ?? ''),
      validator: (value) {
        if (label == 'Name' && (value == null || value.isEmpty)) {
          return 'Please enter your name';
        }
        if (label == 'Email' && (value == null || value.isEmpty)) {
          return 'Please enter your email';
        }
        return null;
      },
    );
  }
}
