import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/auth_service.dart';
import '../../models/user.dart';
import '../../utils/message_utils.dart';
import '../../utils/validators.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile profile;

  const EditProfileScreen({
    Key? key,
    required this.profile,
  }) : super(key: key);

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _authService = AuthService();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  
  File? _avatarFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fullNameController.text = widget.profile.fullName;
    _phoneController.text = widget.profile.phoneNumber ?? '';
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 75,
      );

      if (image != null) {
        setState(() {
          _avatarFile = File(image.path);
        });
      }
    } catch (error) {
      if (mounted) {
        MessageUtils.showMessage(
          context,
          message: 'Failed to pick image. Please try again.',
          type: MessageType.error,
        );
      }
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final updatedProfile = await _authService.updateProfile(
        fullName: _fullNameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        avatarFile: _avatarFile,
      );

      if (mounted) {
        MessageUtils.showMessage(
          context,
          message: 'Profile updated successfully',
          type: MessageType.success,
        );
        Navigator.pop(context, updatedProfile);
      }
    } catch (error) {
      if (mounted) {
        MessageUtils.showMessage(
          context,
          message: 'Failed to update profile. Please try again.',
          type: MessageType.error,
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleDeleteAvatar() async {
    try {
      await _authService.deleteAvatar();
      if (mounted) {
        MessageUtils.showMessage(
          context,
          message: 'Avatar removed successfully',
          type: MessageType.success,
        );
        setState(() {
          _avatarFile = null;
        });
      }
    } catch (error) {
      if (mounted) {
        MessageUtils.showMessage(
          context,
          message: 'Failed to remove avatar. Please try again.',
          type: MessageType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editProfile),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Avatar Section
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                      backgroundImage: _avatarFile != null
                          ? FileImage(_avatarFile!)
                          : widget.profile.avatarUrl != null
                              ? NetworkImage(widget.profile.avatarUrl!)
                              : null,
                      child: widget.profile.avatarUrl == null && _avatarFile == null
                          ? Icon(
                              Icons.person,
                              size: 50,
                              color: theme.colorScheme.primary,
                            )
                          : null,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: CircleAvatar(
                        radius: 18,
                        backgroundColor: theme.colorScheme.primary,
                        child: IconButton(
                          icon: const Icon(
                            Icons.camera_alt,
                            size: 18,
                          ),
                          color: theme.colorScheme.onPrimary,
                          onPressed: _pickImage,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (widget.profile.avatarUrl != null || _avatarFile != null)
                TextButton.icon(
                  onPressed: _handleDeleteAvatar,
                  icon: const Icon(Icons.delete_outline),
                  label: Text(l10n.removePhoto),
                ),
              const SizedBox(height: 24),

              // Full Name Field
              TextFormField(
                controller: _fullNameController,
                decoration: InputDecoration(
                  labelText: l10n.fullName,
                  prefixIcon: const Icon(Icons.person_outline),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return l10n.fullNameRequired;
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Phone Number Field
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(
                  labelText: l10n.phoneNumber,
                  prefixIcon: const Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!Validators.isValidPhone(value)) {
                      return l10n.invalidPhoneNumber;
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _isLoading ? null : _handleSubmit,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(l10n.save),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 