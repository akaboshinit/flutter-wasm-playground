import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class IsolatePage extends HookWidget {
  const IsolatePage({super.key});

  @override
  Widget build(BuildContext context) {
    final useIsolate = useState(true);
    final result = useState(0);
    final isCalculating = useState(false);
    final calculationTime = useState<int>(0);

    final animation = useAnimationController(
      duration: const Duration(seconds: 1),
    )..repeat();

    Future<void> calculateFibonacci() async {
      isCalculating.value = true;
      result.value = 0;
      calculationTime.value = 0;

      const n = 45;
      final startTime = DateTime.now();

      if (useIsolate.value) {
        result.value = await compute(fibonacci, n);
      } else {
        result.value = fibonacci(n);
      }

      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      calculationTime.value = duration.inMilliseconds;

      debugPrint('Calculation ${useIsolate.value ? "with" : "without"} Isolate took ${duration.inMilliseconds}ms');

      isCalculating.value = false;
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Isolate Performance Demo')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Code base by https://zenn.dev/koichi_51/articles/24ed1c7cc252b4'),
            RotationTransition(turns: animation, child: const Icon(Icons.settings, size: 100)),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text('Use Isolate: ${useIsolate.value}'),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Switch(
                value: useIsolate.value,
                onChanged: (value) {
                  useIsolate.value = value;
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: ElevatedButton(
                onPressed: isCalculating.value ? null : calculateFibonacci,
                child: const Text('Calculate Fibonacci(45)'),
              ),
            ),
            const SizedBox(height: 20),
            if (isCalculating.value)
              const CircularProgressIndicator()
            else
              Column(
                children: [
                  Text('Result: ${result.value}'),
                  const SizedBox(height: 10),
                  Text('Calculation Time: ${calculationTime.value}ms'),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

int fibonacci(int n) {
  if (n <= 1) return n;
  return fibonacci(n - 1) + fibonacci(n - 2);
}
