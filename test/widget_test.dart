import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kids_tv/data/datasources/mock_seed_data.dart';
import 'package:kids_tv/main.dart';
import 'package:kids_tv/presentation/shared/widgets/live_channel_card.dart';

void main() {
  testWidgets('Kids TV app builds smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: KidsTvApp(),
      ),
    );
    await tester.pump();

    // Verify app branding or Admin Portal loads cleanly
    expect(
      find.byWidgetPredicate(
        (widget) =>
            (widget is Text &&
                (widget.data?.contains('Admin') == true ||
                    widget.data?.contains('Kids') == true ||
                    widget.data?.contains('Sign In') == true)) ||
            (widget is RichText && widget.text.toPlainText().contains('Kids')),
      ),
      findsWidgets,
    );
  });

  testWidgets('LiveChannelCard renders cleanly in tight constraints without RenderFlex overflow',
      (WidgetTester tester) async {
    final channel = MockSeedData.initialLiveChannels.first;

    // Test in tight container (height: 100)
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 100,
            width: 160,
            child: LiveChannelCard(
              channel: channel,
              width: 160,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    // Verify channel name is rendered and no RenderFlex overflow exception thrown
    expect(find.text(channel.name), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('LiveChannelCard renders cleanly in standard container (height: 155)',
      (WidgetTester tester) async {
    final channel = MockSeedData.initialLiveChannels.first;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 155,
            width: 160,
            child: LiveChannelCard(
              channel: channel,
              width: 160,
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text(channel.name), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
