import 'dart:math';

import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:wonders/common_libs.dart' hide Random;

class HeavyRenderPage extends HookWidget {
  const HeavyRenderPage({
    super.key,
  });

  static const chartHorizontalPadding = 16;
  static const _defaultBarLength = 10000;
  static const _canvasChartColor = Colors.teal;
  static const _containerChartColor = Colors.brown;

  @override
  Widget build(BuildContext context) {
    final textEditingController = useTextEditingController(
      text: _defaultBarLength.toString(),
    );

    final canvasBarChartItems = useState(
      BarChartItem.createList(
        length: textEditingController.intText!,
        color: _canvasChartColor,
      ),
    );
    final containerBarChartItems = useState(
      BarChartItem.createList(
        length: textEditingController.intText!,
        color: _containerChartColor,
      ),
    );

    final tabController = useTabController(initialLength: 2);

    return Scaffold(
      appBar: AppBar(
        title: const Text('flutter_bar_chart_sample'),
        bottom: TabBar(
          controller: tabController,
          tabs: const [
            Tab(text: 'Canvas'),
            Tab(text: 'Container'),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: tabController,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: Chart.canvas(
                      barChartItems: canvasBarChartItems.value,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: Chart.container(
                      barChartItems: containerBarChartItems.value,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(
            height: 1,
            color: Colors.black87,
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 60),
            child: Column(
              children: [
                const Gap(8),
                TextField(
                  controller: textEditingController,
                  keyboardType: TextInputType.number,
                ),
                const Gap(8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      final intText = textEditingController.intText;

                      if (intText == null) {
                        // showSnackBar(context, 'Integer only.');
                        return;
                      }

                      if (intText < 5) {
                        // showSnackBar(context, '5 or higher only.');
                        return;
                      }

                      if (tabController.index == 0) {
                        canvasBarChartItems.value = BarChartItem.createList(
                          length: textEditingController.intText!,
                          color: _canvasChartColor,
                        );
                      } else {
                        containerBarChartItems.value = BarChartItem.createList(
                          length: textEditingController.intText!,
                          color: _containerChartColor,
                        );
                      }
                    },
                    child: const Text('Create!'),
                  ),
                ),
                const Gap(32),
              ],
            ),
          )
        ],
      ),
    );
  }
}

extension on TextEditingController {
  int? get intText => int.tryParse(text);
}

class Chart extends StatelessWidget {
  const Chart.canvas({
    super.key,
    required this.barChartItems,
  }) : _barChartType = _BarChartType.canvas;

  const Chart.container({
    super.key,
    required this.barChartItems,
  }) : _barChartType = _BarChartType.container;

  final List<BarChartItem> barChartItems;
  final _BarChartType _barChartType;

  static const _chartHeight = 340.0;
  static const _chartFadeAnimationDuration = Duration(milliseconds: 200);
  static const _barAnimationDuration = Duration(seconds: 1);

  @override
  Widget build(BuildContext context) {
    Widget barChart() {
      switch (_barChartType) {
        case _BarChartType.canvas:
          return BarChartByCanvas(
            barChartItems: barChartItems,
            maxBarHeight: _chartHeight - ChartXAxis.scaleTextHeight,
            barAnimationDuration: _barAnimationDuration,
          );
        case _BarChartType.container:
          return BarChartByContainer(
            barChartItems: barChartItems,
            maxBarHeight: _chartHeight - ChartXAxis.scaleTextHeight,
            barAnimationDuration: _barAnimationDuration,
          );
      }
    }

    return AnimatedSwitcher(
      duration: _chartFadeAnimationDuration,
      child: SizedBox(
        key: ValueKey(barChartItems),
        height: _chartHeight,
        child: Stack(
          children: [
            ChartXAxis(
              barChartItems: barChartItems,
            ),
            const ChartYAxis(),
            barChart(),
          ],
        ),
      ),
    );
  }
}

enum _BarChartType {
  canvas,
  container,
}

class BarChartByContainer extends HookWidget {
  const BarChartByContainer({
    super.key,
    required this.barChartItems,
    required this.maxBarHeight,
    required this.barAnimationDuration,
  });

  final List<BarChartItem> barChartItems;
  final double maxBarHeight;
  final Duration barAnimationDuration;

  static const _barRatio = 0.8;
  static const _barTopRadius = Radius.circular(8);

  @override
  Widget build(BuildContext context) {
    // 水平のpaddingを引いたものを、描画可能な横幅とする
    final layoutWidth = MediaQuery.of(context).size.width - 100;
    // 棒グラフ一つ当たりの横幅を算出
    final barWidth = (layoutWidth - ChartYAxis.scaleTextWidth) / barChartItems.length * _barRatio;

    final animationController = useAnimationController(duration: barAnimationDuration);

    final animationHeight = useMemoized(
      () => animationController.drive(
        Tween(
          begin: 0.0,
          end: maxBarHeight,
        ).chain(
          CurveTween(
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
      [maxBarHeight],
    );

    useEffect(() {
      // [barChartItems]が更新されたタイミングでアニメーション発火
      Future.microtask(animationController.forward);

      return animationController.reset;
    }, [barChartItems]);

    return SizedBox.expand(
      child: AnimatedBuilder(
        animation: animationHeight,
        builder: (context, _) => Padding(
          padding: const EdgeInsets.only(
            right: ChartYAxis.scaleTextWidth,
            bottom: ChartXAxis.scaleTextHeight,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.end,
            // 与えられた[barChartItems]の数だけ[Container]を表示させる
            children: barChartItems
                .map(
                  (item) => Container(
                    decoration: BoxDecoration(
                      color: item.color,
                      borderRadius: const BorderRadius.only(
                        topLeft: _barTopRadius,
                        topRight: _barTopRadius,
                      ),
                    ),
                    width: barWidth,
                    // それぞれの棒グラフの高さに応じてアニメーションの進捗を変える
                    height: item.height * animationHeight.value / maxBarHeight,
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class BarChartByCanvas extends HookWidget {
  const BarChartByCanvas({
    super.key,
    required this.barChartItems,
    required this.maxBarHeight,
    required this.barAnimationDuration,
  });

  final List<BarChartItem> barChartItems;
  final double maxBarHeight;
  final Duration barAnimationDuration;

  @override
  Widget build(BuildContext context) {
    final animationController = useAnimationController(duration: barAnimationDuration);

    final animationHeight = useMemoized(
      () => animationController.drive(
        Tween(
          begin: 0.0,
          end: maxBarHeight,
        ).chain(
          CurveTween(
            curve: Curves.easeOutCubic,
          ),
        ),
      ),
      [maxBarHeight],
    );

    useEffect(() {
      // [barChartItems]が更新されたタイミングでアニメーション発火
      Future.microtask(animationController.forward);

      return animationController.reset;
    }, [barChartItems]);

    return SizedBox.expand(
      child: AnimatedBuilder(
        animation: animationHeight,
        builder: (context, _) => CustomPaint(
          painter: _BarChartPainter(
            barChartItems: barChartItems,
            animationHeight: animationHeight.value,
          ),
        ),
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  const _BarChartPainter({
    required this.barChartItems,
    required this.animationHeight,
  });

  final List<BarChartItem> barChartItems;
  final double animationHeight;

  static const _barRatio = 0.8;
  static const _barTopRadius = Radius.circular(8);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..strokeWidth = 1;

    final yAxisHeight = size.height - ChartXAxis.scaleTextHeight;
    final xAxisWidth = size.width - ChartYAxis.scaleTextWidth;

    final xAxisEqualWidth = xAxisWidth / barChartItems.length;
    final barWidth = xAxisEqualWidth * _barRatio;
    final barMarginLeft = (xAxisEqualWidth - barWidth) / 2;

    for (var i = 0; i < barChartItems.length; i++) {
      final item = barChartItems[i];

      // それぞれの棒グラフの高さに応じてアニメーションの進捗を変える
      final animationBarHeight = item.height * animationHeight / yAxisHeight;

      final barX = xAxisEqualWidth * i + barMarginLeft;
      final barY = yAxisHeight - animationBarHeight;

      final rect = Rect.fromLTWH(barX, barY, barWidth, animationBarHeight);

      canvas.drawRRect(
        RRect.fromRectAndCorners(rect, topLeft: _barTopRadius, topRight: _barTopRadius),
        paint..color = item.color,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class ChartXAxis extends StatelessWidget {
  const ChartXAxis({
    super.key,
    required this.barChartItems,
  });

  static const scaleTextHeight = 40.0;

  final List<BarChartItem> barChartItems;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: CustomPaint(
        painter: _XAxisPainter(
          barChartItems: barChartItems,
        ),
      ),
    );
  }
}

class _XAxisPainter extends CustomPainter {
  const _XAxisPainter({
    required this.barChartItems,
  });

  static const _scaleTextLeftMargin = 2.0;
  static const _dividedCount = 5;

  final List<BarChartItem> barChartItems;

  @override
  void paint(Canvas canvas, Size size) {
    TextPainter makeTextPainter(int i) {
      return TextPainter(
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 12),
          text: i.toString(),
        ),
      )..layout();
    }

    final paint = Paint()
      ..color = Colors.black26
      ..strokeWidth = 1;

    final xAxisWidth = size.width - ChartYAxis.scaleTextWidth;
    final barWidth = xAxisWidth / barChartItems.length;

    final threshold = barChartItems.length ~/ _dividedCount;

    for (var i = 0; i < barChartItems.length; i++) {
      if (i != 0 && i % threshold != 0) {
        continue;
      }

      final x = barWidth * i;
      final textPainter = makeTextPainter(i);
      final textY = size.height - textPainter.height;

      // ボーダー
      canvas.drawVerticalDottedLine(
        paint: paint,
        x: x,
        maxY: size.height,
      );

      // テキスト
      textPainter.paint(
        canvas,
        Offset(x + _scaleTextLeftMargin, textY),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

extension on Canvas {
  static const _dotHeight = 2.0;
  static const _dotSpace = 2.0;

  /// {x, y} から {x, maxY} までドットボーダーラインを描画
  void drawVerticalDottedLine({
    required Paint paint,
    required double x,
    double y = 0,
    required double maxY,
  }) {
    while (y < maxY) {
      drawLine(Offset(x, y), Offset(x, y + _dotHeight), paint);
      y += _dotHeight + _dotSpace;
    }
  }
}

class ChartYAxis extends StatelessWidget {
  const ChartYAxis({
    super.key,
  });

  static const scaleTextWidth = 40.0;

  @override
  Widget build(BuildContext context) {
    return const SizedBox.expand(
      child: CustomPaint(
        painter: _YAxisPainter(),
      ),
    );
  }
}

class _YAxisPainter extends CustomPainter {
  const _YAxisPainter();

  static const _textMarginTop = 8;
  static const _scaleCount = 5;
  static const _scaleTextLeftMargin = 4.0;

  @override
  void paint(Canvas canvas, Size size) {
    TextPainter makeTextPainter(int i) {
      return TextPainter(
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
        text: TextSpan(
          style: const TextStyle(color: Colors.black87, fontSize: 12),
          text: i.toString(),
        ),
      )..layout();
    }

    final paint = Paint()
      ..color = Colors.black26
      ..strokeWidth = 2;

    final yAxisHeight = size.height - ChartXAxis.scaleTextHeight;
    final yAxisWidth = size.width - ChartYAxis.scaleTextWidth;
    final yAxisScaleMarginTop = yAxisHeight / _scaleCount;

    paint.strokeWidth = 1;
    for (var i = 0; i <= _scaleCount; i++) {
      // ボーダー
      final y = yAxisScaleMarginTop * i;
      canvas.drawLine(Offset(0, y), Offset(yAxisWidth, y), paint);

      // テキスト
      final scale = yAxisHeight - yAxisScaleMarginTop * i;
      makeTextPainter(scale.toInt()).paint(
        canvas,
        Offset(yAxisWidth + _scaleTextLeftMargin, y - _textMarginTop),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class BarChartItem {
  BarChartItem._({
    required this.height,
    required this.color,
  });

  final double height;
  final Color color;

  static List<BarChartItem> createList({
    required int length,
    required Color color,
  }) {
    final random = Random();

    return List.generate(
      length,
      (_) => BarChartItem._(
        // 200 ~ 300 の範囲の[height]を生成
        height: random.nextInt(200) + 101,
        color: color,
      ),
    );
  }
}
