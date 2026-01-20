import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:share_plus/share_plus.dart';
import '../../../domain/entities/job.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../logic/job/job_bloc.dart';
import '../../../logic/job/job_event.dart';
import '../../../logic/job/job_state.dart';
import '../../../logic/saved_jobs/saved_jobs_bloc.dart';
import '../../../logic/saved_jobs/saved_jobs_event.dart';
import '../../../data/services/notification_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class JobDetailsScreen extends StatelessWidget {
  final Job job;

  const JobDetailsScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<JobBloc, JobState>(
      builder: (context, state) {
        // Find the current job from state to get updated save status
        final currentJob = state.jobs.firstWhere(
          (j) => j.id == job.id,
          orElse: () => job,
        );

        return Scaffold(
          appBar: AppBar(
            title: const Text('Job Details'),
            actions: [
              IconButton(
                icon: Icon(
                  currentJob.isSaved ? Icons.bookmark : Icons.bookmark_border,
                  color: currentJob.isSaved ? AppColors.primary : null,
                ),
                onPressed: () {
                  context.read<JobBloc>().add(ToggleSaveJob(currentJob.id));
                  if (currentJob.isSaved) {
                    context.read<SavedJobsBloc>().add(LoadSavedJobs());
                  } else {
                    // Send notification when job is saved
                    NotificationService().notifyJobSaved(currentJob.title);
                  }
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        currentJob.isSaved
                            ? 'Job removed from saved'
                            : 'Job saved!',
                      ),
                      duration: const Duration(seconds: 1),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  final shareText =
                      '''${currentJob.title} at ${currentJob.company}

Location: ${currentJob.location}
${currentJob.salaryRange != null ? 'Salary: ${currentJob.salaryRange}\n' : ''}
${currentJob.applyUrl ?? 'Contact company for application details'}''';

                  Share.share(
                    shareText,
                    subject: '${currentJob.title} - Job Opportunity',
                  );
                },
              ),
            ],
          ),
          body: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Company Info
                      Row(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: AppColors.grey100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: currentJob.companyLogoUrl != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.network(
                                      currentJob.companyLogoUrl!,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => Icon(
                                        Icons.business,
                                        size: 32,
                                        color: AppColors.grey400,
                                      ),
                                    ),
                                  )
                                : Icon(
                                    Icons.business,
                                    size: 32,
                                    color: AppColors.grey400,
                                  ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentJob.title,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  currentJob.company,
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: AppColors.grey600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Job Meta Info
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildChip(
                            Icons.location_on_outlined,
                            currentJob.location,
                          ),
                          _buildChip(
                            Icons.work_outline,
                            _getJobTypeText(currentJob.jobType),
                          ),
                          _buildChip(
                            Icons.schedule,
                            _getWorkLocationText(currentJob.workLocation),
                          ),
                          if (currentJob.salaryRange != null)
                            _buildChip(
                              Icons.attach_money,
                              currentJob.salaryRange!,
                            ),
                          if (currentJob.experienceLevel != null)
                            _buildChip(
                              Icons.star_outline,
                              currentJob.experienceLevel!,
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Posted ${DateFormatter.timeAgo(currentJob.postedDate)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.grey500,
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Description
                      _buildSection(
                        'Job Description',
                        Html(
                          data: currentJob.description,
                          style: {
                            "body": Style(
                              margin: Margins.zero,
                              padding: HtmlPaddings.zero,
                              fontSize: FontSize(15),
                              lineHeight: LineHeight(1.6),
                            ),
                            "p": Style(margin: Margins.only(bottom: 12)),
                            "ul": Style(
                              margin: Margins.only(left: 16, bottom: 12),
                            ),
                            "li": Style(margin: Margins.only(bottom: 8)),
                          },
                        ),
                      ),

                      // Responsibilities
                      if (currentJob.responsibilities.isNotEmpty)
                        _buildSection(
                          'Responsibilities',
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: currentJob.responsibilities
                                .map(
                                  (r) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          '• ',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        Expanded(child: Text(r)),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),

                      // Requirements
                      if (currentJob.requirements.isNotEmpty)
                        _buildSection(
                          'Requirements',
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: currentJob.requirements
                                .map(
                                  (r) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          '• ',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        Expanded(child: Text(r)),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),

                      // Benefits
                      if (currentJob.benefits.isNotEmpty)
                        _buildSection(
                          'Benefits',
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: currentJob.benefits
                                .map(
                                  (b) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          '• ',
                                          style: TextStyle(fontSize: 16),
                                        ),
                                        Expanded(child: Text(b)),
                                      ],
                                    ),
                                  ),
                                )
                                .toList(),
                          ),
                        ),

                      // Skills
                      if (currentJob.skills.isNotEmpty)
                        _buildSection(
                          'Required Skills',
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: currentJob.skills
                                .map(
                                  (skill) => Chip(
                                    label: Text(skill),
                                    backgroundColor: AppColors.primaryLight
                                        .withOpacity(0.2),
                                  ),
                                )
                                .toList(),
                          ),
                        ),

                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),

              // Apply Button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: CustomButton(
                      text: currentJob.isApplied
                          ? 'Already Applied'
                          : 'Apply Now',
                      onPressed: currentJob.isApplied
                          ? () {}
                          : () => _applyToJob(context, currentJob),
                      icon: currentJob.isApplied
                          ? Icons.check_circle
                          : Icons.send,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        content,
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildChip(IconData icon, String label) {
    return Chip(
      avatar: Icon(icon, size: 18, color: AppColors.primary),
      label: Text(label),
      backgroundColor: AppColors.grey100,
    );
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

  Future<void> _applyToJob(BuildContext context, Job currentJob) async {
    try {
      if (currentJob.applyUrl != null && currentJob.applyUrl!.isNotEmpty) {
        String url = currentJob.applyUrl!;

        // Ensure URL has a scheme
        if (!url.startsWith('http://') && !url.startsWith('https://')) {
          url = 'https://$url';
        }

        final uri = Uri.parse(url);

        // Try to launch directly without checking canLaunchUrl
        final launched = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );

        if (launched) {
          // Send notification when job application is opened
          NotificationService().notifyJobApplied(currentJob.title, currentJob.id);
        }

        if (!launched && context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Could not open application link'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No application link available for this job'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening link: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
