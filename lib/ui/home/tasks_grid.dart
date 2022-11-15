import 'dart:math';

import 'package:flutter/material.dart';
import 'package:habit_tracker_flutter/models/task.dart';
import 'package:habit_tracker_flutter/ui/animations/animation_controller_state.dart';
import 'package:habit_tracker_flutter/ui/animations/opacity_animated_widget.dart';
import 'package:habit_tracker_flutter/ui/animations/staggered_scale_animated_widget.dart';
import 'package:habit_tracker_flutter/ui/common_widgets/edit_task_button.dart';
import 'package:habit_tracker_flutter/ui/task/add_task_item.dart';
import 'package:habit_tracker_flutter/ui/task/task_with_name_loader.dart';

class TasksGrid extends StatefulWidget {
  const TasksGrid({Key? key, required this.tasks, this.onEditTask})
      : super(key: key);
  final List<Task> tasks;
  final VoidCallback? onEditTask;

  @override
  TasksGridState createState() =>
      TasksGridState(duration: Duration(milliseconds: 300));
}

class TasksGridState extends AnimationControllerState<TasksGrid> {
  TasksGridState({required Duration duration}) : super(duration);

  bool _isEditing = false;

  void enterEditMode() {
    animationController.forward();
    setState(() {
      _isEditing = true;
    });
  }

  void exitEditMode() {
    animationController.reverse();
    setState(() {
      _isEditing = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisSpacing = constraints.maxWidth * 0.05;
        final taskWidth = (constraints.maxWidth - crossAxisSpacing) / 2.0;
        const aspectRatio = 0.82;
        final taskHeight = taskWidth / aspectRatio;
        // Use max(x, 0.1) to prevent layout error when keyword is visible in modal page
        final mainAxisSpacing =
            max((constraints.maxHeight - taskHeight * 3) / 2.0, 0.1);
        final tasksLength = min(6, widget.tasks.length + 1);
        return GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing,
            childAspectRatio: aspectRatio,
          ),
          itemBuilder: (context, index) {
            if (index == widget.tasks.length) {
              return FadeTransition(
                opacity: CurvedAnimation(
                    parent: animationController, curve: Curves.easeInOutCubic),
                child: AddTaskItem(
                  onCompleted:
                      _isEditing ? () => print('new task added') : null,
                ),
              );
            }
            final task = widget.tasks[index];
            return TaskWithNameLoader(
              task: task,
              isEditing: _isEditing,
              editTaskButtonBuilder: (_) => StaggeredScaleAnimatedWidget(
                index: index,
                animation: animationController,
                child: EditTaskButton(
                  onPressed: () => print('Edit Item'),
                ),
              ),
            );
          },
          itemCount: tasksLength,
        );
      },
    );
  }
}
