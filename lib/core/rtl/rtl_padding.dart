import 'package:busnow/core/l10n/locale_provider.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RtlPadding extends ConsumerWidget {
  final Widget child;
  final double left;
  final double right;
  final double top;
  final double bottom;

  const RtlPadding({
    super.key,
    required this.child,
    this.left = 0.0,
    this.right = 0.0,
    this.top = 0.0,
    this.bottom = 0.0,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRtl = ref.watch(isRtlProvider);

    return Padding(
      padding: EdgeInsets.only(
        left: isRtl ? right : left,
        right: isRtl ? left : right,
        top: top,
        bottom: bottom,
      ),
      child: child,
    );
  }
}
