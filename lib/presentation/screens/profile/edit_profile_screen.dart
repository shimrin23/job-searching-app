import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../logic/profile/profile_bloc.dart';
import '../../../logic/profile/profile_event.dart';
import '../../../logic/profile/profile_state.dart';
import '../../../domain/entities/user.dart';
import '../../../services/storage_service.dart';
import '../../../core/di/service_locator.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _storageService = getIt<StorageService>();
  final _imagePicker = ImagePicker();

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  late TextEditingController _skillsController;

  File? _selectedImage;
  bool _isUploadingImage = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<ProfileBloc>().state.user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _locationController = TextEditingController(text: user?.location ?? '');
    _skillsController = TextEditingController(
      text: user?.skills.join(', ') ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImage = File(image.path);
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Failed to pick image: $e')));
      }
    }
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      final currentUser = context.read<ProfileBloc>().state.user;
      if (currentUser == null) return;

      String? profileImageUrl = currentUser.profileImageUrl;

      // Upload new profile image if selected
      if (_selectedImage != null) {
        setState(() => _isUploadingImage = true);
        try {
          profileImageUrl = await _storageService.uploadProfileImage(
            _selectedImage!,
            currentUser.id,
          );
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Failed to upload image: $e')),
            );
          }
          setState(() => _isUploadingImage = false);
          return;
        }
        setState(() => _isUploadingImage = false);
      }

      // Parse skills from comma-separated string
      final skills = _skillsController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      final updatedUser = currentUser.copyWith(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim().isEmpty
            ? null
            : _phoneController.text.trim(),
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        skills: skills,
        profileImageUrl: profileImageUrl,
      );

      context.read<ProfileBloc>().add(UpdateProfile(updatedUser));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state.status == ProfileStatus.updated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile updated successfully'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop();
          } else if (state.status == ProfileStatus.error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message ?? 'Failed to update profile'),
                backgroundColor: AppColors.error,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading =
              state.status == ProfileStatus.updating || _isUploadingImage;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Profile Image Section
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: AppColors.grey200,
                          backgroundImage: _selectedImage != null
                              ? FileImage(_selectedImage!)
                              : (state.user?.profileImageUrl != null
                                        ? NetworkImage(
                                            state.user!.profileImageUrl!,
                                          )
                                        : null)
                                    as ImageProvider?,
                          child:
                              _selectedImage == null &&
                                  state.user?.profileImageUrl == null
                              ? const Icon(Icons.person, size: 60)
                              : null,
                        ),
                        if (_isUploadingImage)
                          Positioned.fill(
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.black54,
                              child: const CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: AppColors.primary,
                            child: IconButton(
                              icon: const Icon(Icons.camera_alt, size: 20),
                              color: Colors.white,
                              onPressed: _isUploadingImage ? null : _pickImage,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Name Field
                  CustomTextField(
                    controller: _nameController,
                    label: 'Full Name',
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Phone Field
                  CustomTextField(
                    controller: _phoneController,
                    label: 'Phone Number',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 16),

                  // Location Field
                  CustomTextField(
                    controller: _locationController,
                    label: 'Location',
                  ),
                  const SizedBox(height: 16),

                  // Skills Field
                  CustomTextField(
                    controller: _skillsController,
                    label: 'Skills (comma separated)',
                    hint: 'e.g., Flutter, Dart, Firebase',
                    maxLines: 3,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Separate multiple skills with commas',
                    style: TextStyle(fontSize: 12, color: AppColors.grey600),
                  ),
                  const SizedBox(height: 32),

                  // Save Button
                  CustomButton(
                    text: 'Save Changes',
                    onPressed: _saveProfile,
                    isLoading: isLoading,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
