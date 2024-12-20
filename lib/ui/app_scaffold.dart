import 'package:flutter/foundation.dart';
import 'package:performance/performance.dart';
import 'package:wonders/common_libs.dart';
import 'package:wonders/ui/common/app_scroll_behavior.dart';

class WondersAppScaffold extends StatelessWidget {
  const WondersAppScaffold({super.key, required this.child});
  final Widget child;
  static AppStyle get style => _style;
  static AppStyle _style = AppStyle();

  @override
  Widget build(BuildContext context) {
    // Listen to the device size, and update AppStyle when it changes
    final mq = MediaQuery.of(context);
    appLogic.handleAppSizeChanged(mq.size);
    // Set default timing for animations in the app
    Animate.defaultDuration = _style.times.fast;
    // Create a style object that will be passed down the widget tree
    _style = AppStyle(screenSize: context.sizePx);
    return KeyedSubtree(
      key: ValueKey($styles.scale),
      child: Scaffold(
        body: Stack(
          children: [
            CustomPerformanceOverlay(
              alignment: Alignment.bottomRight,
              child: Theme(
                data: $styles.colors.toThemeData(),
                // Provide a default texts style to allow Hero's to render text properly
                child: DefaultTextStyle(
                  style: $styles.text.body,
                  // Use a custom scroll behavior across entire app
                  child: ScrollConfiguration(
                    behavior: AppScrollBehavior(),
                    child: child,
                  ),
                ),
              ),
            ),
            Positioned.fill(
                child: Align(
              alignment: Alignment.bottomLeft,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('isWasm: $kIsWasm', style: TextStyle(color: Colors.white)),
                  TextButton(onPressed: () => appRouter.go(ScreenPaths.home), child: const Text('Home')),
                  TextButton(onPressed: () => appRouter.go(ScreenPaths.playground), child: const Text('Playground')),
                ],
              ),
            ))
          ],
        ),
      ),
    );
  }
}
