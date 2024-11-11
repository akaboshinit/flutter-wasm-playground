import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wonders/common_libs.dart';

class AnimationPage extends HookWidget {
  const AnimationPage({super.key});
  @override
  Widget build(
    BuildContext context,
  ) {
    final textEditingController = useTextEditingController(text: '1');
    final count = useState(1);

    final animation = useAnimationController(
      duration: const Duration(seconds: 1),
    )..repeat();

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: textEditingController,
            keyboardType: TextInputType.number,
            onChanged: (value) {
              count.value = int.tryParse(value) ?? 0;
            },
          ),
          Expanded(
            child: GridView.extent(
              maxCrossAxisExtent: 100,
              children: [
                for (var i = 0; i < count.value; i++)
                  RotationTransition(
                    turns: animation,
                    child: const Icon(Icons.settings, size: 100),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
