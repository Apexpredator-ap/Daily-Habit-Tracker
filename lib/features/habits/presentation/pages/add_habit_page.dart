import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:untitled3/core/theme/app_theme.dart';
import 'package:untitled3/features/authentication/presentation/bloc/auth_bloc.dart';
import 'package:untitled3/features/authentication/presentation/bloc/auth_state.dart';
import 'package:untitled3/features/habits/presentation/bloc/add_habit_bloc.dart';
import 'package:untitled3/features/habits/presentation/bloc/add_habit_state.dart';

class AddHabitPage extends StatefulWidget {
  const AddHabitPage({super.key});

  @override
  State<AddHabitPage> createState() => _AddHabitPageState();
}

class _AddHabitPageState extends State<AddHabitPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _pointsController = TextEditingController(text: '10');
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _pointsController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! Authenticated) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please wait, authenticating session...'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    final title = _titleController.text.trim();
    final points = int.tryParse(_pointsController.text.trim()) ?? 10;
    final description = _descriptionController.text.trim();

    context.read<AddHabitBloc>().add(
      AddHabitSubmitted(
        userId: authState.user.id,
        title: title,
        points: points,
        description: description.isNotEmpty ? description : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AddHabitBloc, AddHabitState>(
      listener: (context, state) {
        if (state is AddHabitSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Habit "${state.habit.title}" created successfully!',
              ),
              backgroundColor: AppColors.primary,
            ),
          );
          context.pop();
        } else if (state is AddHabitFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Create New Habit'),
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: () => context.pop(),
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'HABIT DETAILS',
                    style: TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: _titleController,
                    autofocus: true,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Habit Name',
                      hintText: 'e.g. Drink 2L water, Read 20 pages',
                      prefixIcon: Icon(Icons.bookmark_outline_rounded),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Habit name is required';
                      }
                      if (val.trim().length < 3) {
                        return 'Habit name must be at least 3 characters';
                      }
                      if (val.trim().length > 80) {
                        return 'Habit name cannot exceed 80 characters';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _pointsController,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Points per Completion',
                      hintText: 'e.g. 10',
                      prefixIcon: Icon(
                        Icons.stars_rounded,
                        color: AppColors.primary,
                      ),
                      helperText:
                          'Awarded once each day when completed (1 - 1000)',
                      helperStyle: TextStyle(color: AppColors.textMuted),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Points value is required';
                      }
                      final parsed = int.tryParse(val.trim());
                      if (parsed == null || parsed < 1 || parsed > 1000) {
                        return 'Enter a valid number between 1 and 1000';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  TextFormField(
                    controller: _descriptionController,
                    maxLines: 3,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: const InputDecoration(
                      labelText: 'Description (Optional)',
                      hintText:
                          'Add context, cues, or why this habit matters...',
                      alignLabelWithHint: true,
                      prefixIcon: Padding(
                        padding: EdgeInsets.only(bottom: 40),
                        child: Icon(Icons.notes_rounded),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  BlocBuilder<AddHabitBloc, AddHabitState>(
                    builder: (context, state) {
                      final isSubmitting = state is AddHabitSubmitting;

                      return Column(
                        children: [
                          ElevatedButton(
                            onPressed: isSubmitting ? null : _submit,
                            child: isSubmitting
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : const Text('Save Habit'),
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          TextButton(
                            onPressed: isSubmitting
                                ? null
                                : () => context.pop(),
                            child: const Text(
                              'Cancel',
                              style: TextStyle(color: AppColors.textSecondary),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
