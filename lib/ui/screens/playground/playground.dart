import 'package:wonders/common_libs.dart';

class PlaygroundPage extends StatelessWidget {
  const PlaygroundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(onPressed: () => appRouter.go(ScreenPaths.heavyRender), child: const Text('Heavy Render')),
            TextButton(onPressed: () => appRouter.go(ScreenPaths.directedGraph), child: const Text('Directed Graph')),
            TextButton(onPressed: () => appRouter.go(ScreenPaths.animation), child: const Text('Animation')),
          ],
        ),
      ),
    );
  }
}
