import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../app/actions.dart';
import '../app/app_state.dart';
import '../app/strings.dart';
import '../app/theme.dart';
import '../detection/detector.dart';
import '../ui/postal.dart';
import '../ui/widgets.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final _report = TextEditingController();
  late final TextEditingController _family = TextEditingController(
    text: context.read<AppState>().familyNumber,
  );
  late final TextEditingController _name = TextEditingController(
    text: context.read<AppState>().name,
  );

  @override
  void dispose() {
    _report.dispose();
    _family.dispose();
    _name.dispose();
    super.dispose();
  }

  void _submitReport() {
    final app = context.read<AppState>();
    final n = NumberCheck.normalise(_report.text);
    if (n == null) {
      showToast(context, app.t(S.invalidNumber));
      return;
    }
    app.reportNumber(n);
    ReportSink.submit(kind: 'number', level: 'scam', number: n);
    _report.clear();
    FocusScope.of(context).unfocus();
    showToast(context, app.t(S.reported));
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return ListView(
      padding: EdgeInsets.fromLTRB(
        Space.page,
        MediaQuery.paddingOf(context).top + Space.xl,
        Space.page,
        120,
      ),
      children: [
        FadeUp(child: Text(app.t(S.helpTitle), style: T.display)),
        const SizedBox(height: Space.xl),

        // 1930
        FadeUp(
          order: 1,
          child: GestureDetector(
            onTap: Act.call,
            child: Container(
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFB52C22), C.sindoor, Color(0xFF7E1811)],
                ),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x40A3241C),
                    blurRadius: 26,
                    offset: Offset(0, 12),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Positioned(
                    right: -70,
                    top: -26,
                    child: Transform.rotate(
                      angle: -0.24,
                      child: const Postmark(
                        size: 150,
                        color: Color(0x24FFFFFF),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      Space.xl,
                      Space.l + 4,
                      Space.l + 4,
                      Space.l + 4,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          app.t(S.helplineTitle),
                          style: T.small.copyWith(
                            color: const Color(0xFFF6D5CF),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            const Expanded(
                              child: Text(
                                '1930',
                                style: TextStyle(
                                  fontFamily: F.serif,
                                  fontSize: 54,
                                  color: Colors.white,
                                  height: 1.15,
                                  letterSpacing: 3,
                                ),
                              ),
                            ),
                            Container(
                              width: 54,
                              height: 54,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.call_rounded,
                                color: C.sindoor,
                                size: 26,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: Space.s),
                        Text(
                          app.t(S.helplineBody),
                          style: T.small.copyWith(
                            color: const Color(0xFFF6D5CF),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: Space.m),
        PaperCard(
          onTap: Act.portal,
          child: Row(
            children: [
              const Icon(Icons.public_rounded, color: C.inkSoft, size: 20),
              const SizedBox(width: Space.m),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(app.t(S.portalTitle), style: T.heading),
                    Text(
                      'cybercrime.gov.in · ${app.t(S.portalBody)}',
                      style: T.small,
                    ),
                  ],
                ),
              ),
              const Icon(Icons.north_east_rounded, color: C.inkSoft, size: 18),
            ],
          ),
        ),
        const SizedBox(height: Space.xxl),

        // report a number
        Text(app.t(S.reportNumberTitle), style: T.heading),
        const SizedBox(height: 2),
        Text(app.t(S.reportNumberBody), style: T.small),
        const SizedBox(height: Space.m),
        Row(
          children: [
            Expanded(
              child: _Field(
                controller: _report,
                hint: app.t(S.numberHint),
                keyboard: TextInputType.phone,
              ),
            ),
            const SizedBox(width: Space.s),
            AppButton(
              label: app.t(S.report),
              expand: false,
              onPressed: _submitReport,
            ),
          ],
        ),
        const SizedBox(height: Space.xxl),

        // family
        Text(app.t(S.familyTitle), style: T.heading),
        const SizedBox(height: 2),
        Text(app.t(S.familyBody), style: T.small),
        const SizedBox(height: Space.m),
        Row(
          children: [
            Expanded(
              child: _Field(
                controller: _family,
                hint: app.t(S.familyHint),
                keyboard: TextInputType.phone,
              ),
            ),
            const SizedBox(width: Space.s),
            AppButton(
              label: app.t(S.save),
              tone: ButtonTone.outline,
              expand: false,
              onPressed: () {
                app.setFamily(_family.text);
                FocusScope.of(context).unfocus();
                showToast(context, app.t(S.saved));
              },
            ),
          ],
        ),
        const SizedBox(height: Space.xxl),

        // settings
        SectionLabel(app.t(S.settings)),
        const SizedBox(height: Space.s),
        _SettingRow(label: app.t(S.language), trailing: const LangToggle()),
        _SettingRow(
          label: app.t(S.name),
          trailing: SizedBox(
            width: 170,
            child: TextField(
              controller: _name,
              textAlign: TextAlign.end,
              style: T.body,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: app.t(S.yourNameHint),
                hintStyle: T.small,
              ),
              onSubmitted: app.setName,
              onTapOutside: (_) {
                app.setName(_name.text);
                FocusScope.of(context).unfocus();
              },
            ),
          ),
        ),
        const SizedBox(height: Space.xl),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.lock_outline_rounded, size: 16, color: C.inkFaint),
            const SizedBox(width: Space.s),
            Expanded(
              child: Text(
                app.t(S.privacyNote),
                style: T.small.copyWith(color: C.inkFaint),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({required this.controller, required this.hint, this.keyboard});
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboard;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      style: T.body,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: T.body.copyWith(color: C.inkFaint),
        filled: true,
        fillColor: C.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: C.hairline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: C.ink),
        ),
      ),
      onTapOutside: (_) => FocusScope.of(context).unfocus(),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({required this.label, required this.trailing});
  final String label;
  final Widget trailing;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minHeight: 56),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: C.hairline)),
      ),
      child: Row(
        children: [
          Text(label, style: T.body),
          const Spacer(),
          trailing,
        ],
      ),
    );
  }
}
