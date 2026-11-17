import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../app/app_state.dart';
import '../app/strings.dart';
import '../app/theme.dart';
import '../content/lessons.dart';
import '../ui/widgets.dart';

class LessonScreen extends StatelessWidget {
  const LessonScreen({super.key, required this.lesson});
  final Lesson lesson;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final idx = lessons.indexOf(lesson) + 1;
    return Scaffold(
      backgroundColor: C.paper,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                Space.page,
                Space.s,
                Space.page,
                Space.xxl,
              ),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back_rounded, color: C.ink),
                    style: IconButton.styleFrom(
                      backgroundColor: C.surface,
                      side: const BorderSide(color: C.hairline),
                    ),
                  ),
                ),
                const SizedBox(height: Space.xl),
                Text(
                  '${idx.toString().padLeft(2, '0')} · ${fill(app.t(S.minutes), {'n': lesson.minutes})}',
                  style: T.small,
                ),
                const SizedBox(height: Space.xs),
                Text(app.t(lesson.title), style: T.display),
                const SizedBox(height: Space.s),
                Text(app.t(lesson.hook), style: T.bodySoft),
                const SizedBox(height: Space.xl),
                SectionLabel(app.t(S.howItLooks)),
                const SizedBox(height: Space.s),
                MessageBubble(text: app.t(lesson.example), accent: C.sindoor),
                const SizedBox(height: Space.xl),
                SectionLabel(app.t(S.redFlags), color: C.sindoor),
                const SizedBox(height: Space.xs),
                for (final (i, f) in lesson.redFlags.indexed)
                  NumberedRow(n: i + 1, text: app.t(f), color: C.sindoor),
                const SizedBox(height: Space.l),
                SectionLabel(app.t(S.doThis), color: C.leaf),
                const SizedBox(height: Space.xs),
                for (final (i, d) in lesson.doThis.indexed)
                  NumberedRow(n: i + 1, text: app.t(d), color: C.leaf),
                const SizedBox(height: Space.xl),
                AppButton(
                  label: app.t(S.done),
                  icon: Icons.check_rounded,
                  onPressed: () {
                    app.completeLesson(lesson.id);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
