import '../../data/models/models.dart';

/// Toegestane statusovergangen van een uitnodiging (FR-16).
///
/// De match zelf heeft geen status. Alleen `invites[].status` telt, en alleen
/// deze stappen mag de app aanbieden: pending naar accepted of declined, en
/// accepted naar canceled.
List<InviteStatus> toegestaneInviteOvergangen(InviteStatus huidig) =>
    switch (huidig) {
      InviteStatus.pending => const [
        InviteStatus.accepted,
        InviteStatus.declined,
      ],
      InviteStatus.accepted => const [InviteStatus.canceled],
      InviteStatus.declined || InviteStatus.canceled => const [],
    };

bool magInviteOvergang(InviteStatus van, InviteStatus naar) =>
    toegestaneInviteOvergangen(van).contains(naar);

/// De tekst die de API in `POST /matches/invites/{id}` verwacht.
String inviteStatusNaarApi(InviteStatus status) => switch (status) {
  InviteStatus.pending => 'pending',
  InviteStatus.accepted => 'accepted',
  InviteStatus.declined => 'declined',
  InviteStatus.canceled => 'canceled',
};

/// Korte knoptekst bij een toegestane overgang.
String inviteOvergangKnop(InviteStatus naar) => switch (naar) {
  InviteStatus.accepted => 'Accepteren',
  InviteStatus.declined => 'Afwijzen',
  InviteStatus.canceled => 'Annuleren',
  InviteStatus.pending => 'In afwachting',
};
