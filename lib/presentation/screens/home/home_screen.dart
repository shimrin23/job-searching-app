import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../logic/job/job_bloc.dart';
import '../../../logic/job/job_event.dart';
import '../../../logic/job/job_state.dart';
import '../../../logic/saved_jobs/saved_jobs_bloc.dart';
import '../../../logic/saved_jobs/saved_jobs_event.dart';
import '../../../domain/entities/job_filters.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../../widgets/job_card.dart';
import '../../widgets/filter_bottom_sheet.dart';
import '../notifications/notifications_screen.dart';
import '../../../data/services/notification_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();
  final _searchController = TextEditingController();
  final _notificationService = NotificationService();
  JobFilters? _currentFilters;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    context.read<JobBloc>().add(const LoadJobs());
    _notificationService.initializeNotifications();
    _notificationService.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _notificationService.removeListener(() {});
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom) {
      context.read<JobBloc>().add(LoadNextPage());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  void _handleSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      context.read<JobBloc>().add(SearchJobs(query));
    } else {
      context.read<JobBloc>().add(const LoadJobs(refresh: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Jobs'),
        actions: [
          IconButton(
            icon: Stack(
              children: [
                const Icon(Icons.notifications_outlined),
                if (_notificationService.unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${_notificationService.unreadCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationsScreen(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () async {
              final filters = await showModalBottomSheet<JobFilters>(
                context: context,
                isScrollControlled: true,
                builder: (context) =>
                    FilterBottomSheet(currentFilters: _currentFilters),
              );

              if (filters != null) {
                setState(() => _currentFilters = filters);
                context.read<JobBloc>().add(
                  LoadJobs(refresh: true, filters: filters),
                );
              }
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search jobs, companies...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          context.read<JobBloc>().add(
                            const LoadJobs(refresh: true),
                          );
                        },
                      )
                    : null,
              ),
              onSubmitted: (_) => _handleSearch(),
              onChanged: (value) => setState(() {}),
            ),
          ),

          // Job List
          Expanded(
            child: BlocConsumer<JobBloc, JobState>(
              listener: (context, state) {
                if (state.message != null) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message!)));
                }
              },
              builder: (context, state) {
                if (state.status == JobStatus.loading) {
                  return const LoadingIndicator();
                }

                if (state.status == JobStatus.error) {
                  return ErrorView(
                    message: state.message ?? 'Failed to load jobs',
                    onRetry: () {
                      context.read<JobBloc>().add(const LoadJobs());
                    },
                  );
                }

                if (state.jobs.isEmpty) {
                  return const EmptyView(
                    message:
                        'No jobs found\nTry adjusting your search or filters',
                    icon: Icons.work_off_outlined,
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    context.read<JobBloc>().add(const LoadJobs(refresh: true));
                  },
                  child: ListView.builder(
                    controller: _scrollController,
                    itemCount:
                        state.jobs.length + (state.isFetchingMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index >= state.jobs.length) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      final job = state.jobs[index];
                      return JobCard(
                        job: job,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/job-details',
                            arguments: job,
                          );
                        },
                        onSave: () {
                          context.read<JobBloc>().add(ToggleSaveJob(job.id));
                          // Refresh saved jobs list
                          context.read<SavedJobsBloc>().add(LoadSavedJobs());
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
