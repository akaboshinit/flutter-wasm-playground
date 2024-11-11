import 'package:wonders/common_libs.dart';

class PlaygroundPage extends StatelessWidget {
  const PlaygroundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          TextButton(onPressed: () => appRouter.go(ScreenPaths.heavyRender), child: const Text('Heavy Render')),
          TextButton(onPressed: () => appRouter.go(ScreenPaths.directedGraph), child: const Text('Directed Graph')),
        ],
      ),
    );
  }
}
