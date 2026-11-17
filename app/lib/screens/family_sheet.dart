import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../app/actions.dart';
import '../app/app_state.dart';
import '../app/strings.dart';
import '../app/theme.dart';
import '../ui/widgets.dart';

/// "Tell my family": the warning, who it goes to, and how to send it.
/// WhatsApp comes first because that is where most families talk; SMS is
/// offered on phones; copying always works.
Future<void> showFamilySheet(BuildContext context, String message) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: C.paper,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (_) => _FamilySheet(message: message),
  );
}

class _FamilySheet extends StatefulWidget {
  const _FamilySheet({required this.message});
  final String message;

  @override
  State<_FamilySheet> createState() => _FamilySheetState();
}

class _FamilySheetState extends State<_FamilySheet> {
  late final _number = TextEditingController(
    text: context.read<AppState>().familyNumber,
  );
  late bool _editing = _number.text.isEmpty;

  @override
  void dispose() {
    _number.dispose();
    super.dispose();
  }

  String _remember() {
    final app = context.read<AppState>();
    final n = _number.text.trim();
    if (n.isNotEmpty && n != app.familyNumber) app.setFamily(n);
    return n;
  }

  Future<void> _send(Future<bool> Function(String, String) via) async {
    final n = _remember();
    final ok = await via(n, widget.message);
    if (!mounted) return;
    if (ok) {
      Navigator.of(context).pop();
    } else {
      await _copy(failed: true);
    }
  }

  Future<void> _copy({bool failed = false}) async {
    final app = context.read<AppState>();
    _remember();
    await Clipboard.setData(ClipboardData(text: widget.message));
    if (!mounted) return;
    // The toast lives on the screen behind the sheet, so it stays up after
    // the sheet closes.
    showToast(context, app.t(failed ? S.openFailed : S.copied));
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final phone = !kIsWeb;
    return Padding(
      padding: EdgeInsets.fromLTRB(
        Space.page,
        Space.s,
        Space.page,
        MediaQuery.viewInsetsOf(context).bottom +
            MediaQuery.paddingOf(context).bottom +
            Space.l,
      ),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  decoration: BoxDecoration(
                    color: C.hairlineStrong,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: Space.l),
              Text(app.t(S.warnTitle), style: T.title),
              const SizedBox(height: 4),
              Text(app.t(S.warnBody), style: T.bodySoft),
              const SizedBox(height: Space.m),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: C.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: C.hairline),
                ),
                child: Text(
                  widget.message,
                  maxLines: 5,
                  overflow: TextOverflow.ellipsis,
                  style: T.small.copyWith(color: C.inkSoft, height: 1.45),
                ),
              ),
              const SizedBox(height: Space.m),
              if (_editing)
                TextField(
                  controller: _number,
                  keyboardType: TextInputType.phone,
                  style: T.body,
                  decoration: InputDecoration(
                    hintText: app.t(S.warnNumberHint),
                    hintStyle: T.body.copyWith(color: C.inkFaint),
                    prefixIcon: const Icon(
                      Icons.person_outline_rounded,
                      color: C.inkFaint,
                      size: 20,
                    ),
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
                )
              else
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline_rounded,
                      color: C.inkSoft,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${app.t(S.warnTo)}: ${_number.text}',
                      style: T.body.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const Spacer(),
                    TextButton(
                      onPressed: () => setState(() => _editing = true),
                      child: Text(
                        app.t(S.change),
                        style: T.small.copyWith(
                          color: C.ink,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: Space.l),
              AppButton(
                label: app.t(S.sendWhatsApp),
                icon: Icons.chat_rounded,
                onPressed: () => _send(Act.whatsApp),
              ),
              if (phone) ...[
                const SizedBox(height: Space.s),
                AppButton(
                  label: app.t(S.sendSms),
                  icon: Icons.sms_outlined,
                  tone: ButtonTone.outline,
                  onPressed: () => _send(Act.textFamily),
                ),
              ],
              const SizedBox(height: Space.s),
              AppButton(
                label: app.t(S.copyMsg),
                icon: Icons.copy_rounded,
                tone: ButtonTone.quiet,
                onPressed: _copy,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
