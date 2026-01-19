import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/job.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class AddEditJobScreen extends StatefulWidget {
  final Job? job; // null for add, existing job for edit

  const AddEditJobScreen({super.key, this.job});

  @override
  State<AddEditJobScreen> createState() => _AddEditJobScreenState();
}

class _AddEditJobScreenState extends State<AddEditJobScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;

  late TextEditingController _titleController;
  late TextEditingController _companyController;
  late TextEditingController _locationController;
  late TextEditingController _descriptionController;
  late TextEditingController _salaryController;
  late TextEditingController _applyUrlController;
  late TextEditingController _companyLogoUrlController;
  late TextEditingController _skillsController;

  WorkLocation _selectedWorkLocation = WorkLocation.onsite;
  JobType _selectedJobType = JobType.fullTime;
  String _selectedExperienceLevel = 'Mid Level';

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final job = widget.job;

    _titleController = TextEditingController(text: job?.title ?? '');
    _companyController = TextEditingController(text: job?.company ?? '');
    _locationController = TextEditingController(text: job?.location ?? '');
    _descriptionController = TextEditingController(
      text: job?.description ?? '',
    );
    _salaryController = TextEditingController(text: job?.salaryRange ?? '');
    _applyUrlController = TextEditingController(text: job?.applyUrl ?? '');
    _companyLogoUrlController = TextEditingController(
      text: job?.companyLogoUrl ?? '',
    );
    _skillsController = TextEditingController(
      text: job?.skills.join(', ') ?? '',
    );

    if (job != null) {
      _selectedWorkLocation = job.workLocation;
      _selectedJobType = job.jobType;
      _selectedExperienceLevel = job.experienceLevel ?? 'Mid Level';
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _companyController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _salaryController.dispose();
    _applyUrlController.dispose();
    _companyLogoUrlController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  Future<void> _saveJob() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final skills = _skillsController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      final jobData = {
        'title': _titleController.text.trim(),
        'company': _companyController.text.trim(),
        'location': _locationController.text.trim(),
        'workLocation': _selectedWorkLocation.toString().split('.').last,
        'jobType': _selectedJobType.toString().split('.').last,
        'description': _descriptionController.text.trim(),
        'salaryRange': _salaryController.text.trim(),
        'experienceLevel': _selectedExperienceLevel,
        'skills': skills,
        'applyUrl': _applyUrlController.text.trim(),
        'companyLogoUrl': _companyLogoUrlController.text.trim(),
        'postedDate': DateTime.now().toIso8601String(),
        'isSaved': false,
        'isApplied': false,
        'responsibilities': [],
        'requirements': [],
        'benefits': [],
      };

      if (widget.job != null) {
        // Update existing job
        await _firestore.collection('jobs').doc(widget.job!.id).update(jobData);
      } else {
        // Add new job
        final docRef = await _firestore.collection('jobs').add(jobData);
        await docRef.update({'id': docRef.id});
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.job != null
                  ? 'Job updated successfully'
                  : 'Job added successfully',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.job != null ? 'Edit Job' : 'Add New Job'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            CustomTextField(
              controller: _titleController,
              label: 'Job Title *',
              hint: 'e.g., Flutter Developer',
              validator: (value) =>
                  value?.trim().isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _companyController,
              label: 'Company Name *',
              hint: 'e.g., Tech Corp',
              validator: (value) =>
                  value?.trim().isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _locationController,
              label: 'Location *',
              hint: 'e.g., Mumbai, India',
              validator: (value) =>
                  value?.trim().isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<WorkLocation>(
              value: _selectedWorkLocation,
              decoration: const InputDecoration(
                labelText: 'Work Location',
                border: OutlineInputBorder(),
              ),
              items: WorkLocation.values.map((location) {
                return DropdownMenuItem(
                  value: location,
                  child: Text(
                    location.toString().split('.').last.toUpperCase(),
                  ),
                );
              }).toList(),
              onChanged: (value) =>
                  setState(() => _selectedWorkLocation = value!),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<JobType>(
              value: _selectedJobType,
              decoration: const InputDecoration(
                labelText: 'Job Type',
                border: OutlineInputBorder(),
              ),
              items: JobType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.toString().split('.').last),
                );
              }).toList(),
              onChanged: (value) => setState(() => _selectedJobType = value!),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedExperienceLevel,
              decoration: const InputDecoration(
                labelText: 'Experience Level',
                border: OutlineInputBorder(),
              ),
              items:
                  ['Entry Level', 'Mid Level', 'Senior Level', 'Lead/Manager']
                      .map(
                        (level) =>
                            DropdownMenuItem(value: level, child: Text(level)),
                      )
                      .toList(),
              onChanged: (value) =>
                  setState(() => _selectedExperienceLevel = value!),
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _descriptionController,
              label: 'Job Description *',
              hint: 'Describe the role and responsibilities...',
              maxLines: 5,
              validator: (value) =>
                  value?.trim().isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _skillsController,
              label: 'Required Skills',
              hint: 'Flutter, Dart, Firebase (comma separated)',
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _salaryController,
              label: 'Salary Range',
              hint: 'e.g., ₹8-12 LPA',
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _applyUrlController,
              label: 'Application URL',
              hint: 'https://...',
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 16),

            CustomTextField(
              controller: _companyLogoUrlController,
              label: 'Company Logo URL',
              hint: 'https://...',
              keyboardType: TextInputType.url,
            ),
            const SizedBox(height: 32),

            CustomButton(
              text: widget.job != null ? 'Update Job' : 'Add Job',
              onPressed: _saveJob,
              isLoading: _isSaving,
            ),
          ],
        ),
      ),
    );
  }
}
