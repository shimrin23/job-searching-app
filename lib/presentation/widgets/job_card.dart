import 'package:flutter/material.dart';
import '../../domain/entities/job.dart';
import '../../core/utils/date_formatter.dart';
import '../theme/app_theme.dart';

class JobCard extends StatelessWidget {
  final Job job;
  final VoidCallback onTap;
  final VoidCallback onSave;

  const JobCard({
    super.key,
    required this.job,
    required this.onTap,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Company Logo
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.grey100,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: job.companyLogoUrl != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              job.companyLogoUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Icon(
                                Icons.business,
                                color: AppColors.grey400,
                              ),
                            ),
                          )
                        : Icon(Icons.business, color: AppColors.grey400),
                  ),
                  const SizedBox(width: 12),
                  // Job Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          job.company,
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.grey600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Save Button
                  IconButton(
                    icon: Icon(
                      job.isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: job.isSaved
                          ? AppColors.primary
                          : AppColors.grey400,
                    ),
                    onPressed: onSave,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Location & Work Type
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16,
                    color: AppColors.grey500,
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      job.location,
                      style: TextStyle(fontSize: 14, color: AppColors.grey600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: _getWorkLocationColor(
                        job.workLocation,
                      ).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      _getWorkLocationText(job.workLocation),
                      style: TextStyle(
                        fontSize: 12,
                        color: _getWorkLocationColor(job.workLocation),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Tags
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _buildTag(_getJobTypeText(job.jobType)),
                  if (job.salaryRange != null) _buildTag(job.salaryRange!),
                  if (job.experienceLevel != null)
                    _buildTag(job.experienceLevel!),
                ],
              ),
              const SizedBox(height: 12),
              // Posted Date & Applied Status
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Posted ${DateFormatter.timeAgo(job.postedDate)}',
                    style: TextStyle(fontSize: 12, color: AppColors.grey500),
                  ),
                  if (job.isApplied)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: AppColors.success,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Applied',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.success,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
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

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.grey100,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, color: AppColors.grey700),
      ),
    );
  }

  Color _getWorkLocationColor(WorkLocation workLocation) {
    switch (workLocation) {
      case WorkLocation.remote:
        return AppColors.secondary;
      case WorkLocation.hybrid:
        return AppColors.warning;
      case WorkLocation.onsite:
        return AppColors.info;
    }
  }

  String _getWorkLocationText(WorkLocation workLocation) {
    switch (workLocation) {
      case WorkLocation.remote:
        return 'Remote';
      case WorkLocation.hybrid:
        return 'Hybrid';
      case WorkLocation.onsite:
        return 'On-site';
    }
  }

  String _getJobTypeText(JobType jobType) {
    switch (jobType) {
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
}
