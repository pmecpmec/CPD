import 'package:crossplatformdevelopment/data/models/models.dart';
import 'package:crossplatformdevelopment/features/matches/invite_overgangen.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('toegestaneInviteOvergangen', () {
    test('biedt vanaf pending accepteren en afwijzen', () {
      expect(toegestaneInviteOvergangen(InviteStatus.pending), [
        InviteStatus.accepted,
        InviteStatus.declined,
      ]);
      expect(
        magInviteOvergang(InviteStatus.pending, InviteStatus.canceled),
        isFalse,
      );
    });

    test('biedt vanaf accepted alleen annuleren', () {
      expect(toegestaneInviteOvergangen(InviteStatus.accepted), [
        InviteStatus.canceled,
      ]);
      expect(
        magInviteOvergang(InviteStatus.accepted, InviteStatus.declined),
        isFalse,
      );
    });

    test('biedt vanaf declined en canceled niets', () {
      expect(toegestaneInviteOvergangen(InviteStatus.declined), isEmpty);
      expect(toegestaneInviteOvergangen(InviteStatus.canceled), isEmpty);
    });
  });
}
