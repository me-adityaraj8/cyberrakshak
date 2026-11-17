/// The two languages the app speaks.
enum Lang { hi, en }

/// A piece of text in both languages. Used for UI copy and for content
/// (lessons, quiz questions, detection reasons).
class Tr {
  const Tr(this.en, this.hi);
  final String en;
  final String hi;

  String of(Lang lang) => lang == Lang.hi ? hi : en;
}
