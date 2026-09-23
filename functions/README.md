# Trusted backend

These Firebase Functions hold business-critical operations that should not be trusted to a Flutter client: booking creation and booking status transitions, plus an immutable booking audit trail.

M-Pesa and other gateway secrets must be supplied as server environment/secrets when the real provider integration is enabled. Do not put them in Flutter .env or Firestore documents readable by clients.

Deploy from the functions directory after enabling a Firebase billing plan that supports Cloud Functions.