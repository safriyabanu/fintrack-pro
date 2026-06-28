import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack_pro/main.dart';

void main() {
  testWidgets('app renders the splash screen', (tester) async {
    await tester.pumpWidget(const FinTrackApp());

    expect(find.text('FinTrack Pro'), findsWidgets);
  });
}
