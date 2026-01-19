import 'package:flutter/material.dart';
import '../../../domain/entities/job.dart';
import '../../../domain/entities/job_filters.dart';
import '../theme/app_theme.dart';

class FilterBottomSheet extends StatefulWidget {
  final JobFilters? currentFilters;

  const FilterBottomSheet({super.key, this.currentFilters});

  @override
  State<FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<FilterBottomSheet> {
  List<JobType> _selectedJobTypes = [];
  List<WorkLocation> _selectedWorkLocations = [];
  String? _selectedExperienceLevel;
  String? _selectedLocation;

  @override
  void initState() {
    super.initState();
    final filters = widget.currentFilters;
    if (filters != null) {
      _selectedJobTypes = filters.jobTypes ?? [];
      _selectedWorkLocations = filters.workLocations ?? [];
      _selectedExperienceLevel = filters.experienceLevel;
      _selectedLocation = filters.location;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Filters',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _selectedJobTypes.clear();
                    _selectedWorkLocations.clear();
                    _selectedExperienceLevel = null;
                    _selectedLocation = null;
                  });
                },
                child: const Text('Clear All'),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Job Type Section
          const Text(
            'Job Type',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: JobType.values.map((type) {
              final isSelected = _selectedJobTypes.contains(type);
              return FilterChip(
                label: Text(_formatJobType(type)),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedJobTypes.add(type);
                    } else {
                      _selectedJobTypes.remove(type);
                    }
                  });
                },
                selectedColor: AppColors.primary.withOpacity(0.2),
                checkmarkColor: AppColors.primary,
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Work Location Section
          const Text(
            'Work Location',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: WorkLocation.values.map((location) {
              final isSelected = _selectedWorkLocations.contains(location);
              return FilterChip(
                label: Text(_formatWorkLocation(location)),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedWorkLocations.add(location);
                    } else {
                      _selectedWorkLocations.remove(location);
                    }
                  });
                },
                selectedColor: AppColors.primary.withOpacity(0.2),
                checkmarkColor: AppColors.primary,
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          // Experience Level Section
          const Text(
            'Experience Level',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children:
                [
                  'Entry Level',
                  'Mid Level',
                  'Senior Level',
                  'Lead/Manager',
                ].map((level) {
                  final isSelected = _selectedExperienceLevel == level;
                  return FilterChip(
                    label: Text(level),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedExperienceLevel = selected ? level : null;
                      });
                    },
                    selectedColor: AppColors.primary.withOpacity(0.2),
                    checkmarkColor: AppColors.primary,
                  );
                }).toList(),
          ),
          const SizedBox(height: 20),

          // Location Input
          const Text(
            'Location',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          TextField(
            decoration: InputDecoration(
              hintText: 'e.g., Mumbai, Remote',
              border: const OutlineInputBorder(),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
            ),
            onChanged: (value) {
              _selectedLocation = value.trim().isEmpty ? null : value.trim();
            },
            controller: TextEditingController(text: _selectedLocation ?? ''),
          ),
          const SizedBox(height: 24),

          // Apply Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final filters = JobFilters(
                  jobTypes: _selectedJobTypes.isEmpty
                      ? null
                      : _selectedJobTypes,
                  workLocations: _selectedWorkLocations.isEmpty
                      ? null
                      : _selectedWorkLocations,
                  experienceLevel: _selectedExperienceLevel,
                  location: _selectedLocation,
                );
                Navigator.pop(context, filters);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text(
                'Apply Filters',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatJobType(JobType type) {
    switch (type) {
      case JobType.fullTime:
        return 'Full-time';
      case JobType.partTime:
        return 'Part-time';
      case JobType.contract:
        return 'Contract';
      case JobType.internship:
        return 'Internship';
      case JobType.temporary:
        return 'Temporary';
    }
  }

  String _formatWorkLocation(WorkLocation location) {
    switch (location) {
      case WorkLocation.onsite:
        return 'On-site';
      case WorkLocation.remote:
        return 'Remote';
      case WorkLocation.hybrid:
        return 'Hybrid';
    }
  }
}
