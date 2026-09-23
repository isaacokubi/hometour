# Firebase demo data seeding

This repository includes a local-only Firebase Admin seed utility for the HomeTour / Global Tours demo environment.

## What it creates

For each of these tenants:

- Amani Trails Safaris
- Savanna Crown Safaris
- Coastal Horizon Adventures

the seed creates:

- tenant/company information
- 5 destinations
- 6 tours
- 1 supplier
- 1 accommodation partner
- 6 Firebase Authentication accounts
- matching `users/{uid}` Firestore profiles
- Firebase custom claims for `tenantId` and `role`
- 4 sample customer bookings
- a test M-Pesa gateway configuration

The six accounts per tenant are:

- admin
- manager
- agent
- guide
- customer1
- customer2

Passwords are generated randomly on every seed run and written only to the local `.secrets/seed-credentials.json` file. Re-running the seed rotates the passwords.

## Required local setup

1. Install Node.js/npm if they are not already installed.
2. Create/download a Firebase service-account JSON for the Firebase project.
3. Store it locally as:

```text
.secrets/firebase-service-account.json
```

Do not commit, upload, or paste this file into source control.

## Run

```bash
npm install
npm run seed:firebase
```

You can use another service-account path:

```bash
GOOGLE_APPLICATION_CREDENTIALS="/absolute/path/service-account.json" npm run seed:firebase
```

The default Firebase project is `hometour-6bdde`. To override it:

```bash
FIREBASE_PROJECT_ID="your-project-id" npm run seed:firebase
```

After a successful run, read:

```text
.secrets/seed-credentials.json
```

to obtain the fresh login accounts and passwords.

## Security notes

The Firebase client API key in Flutter `.env` is not a service-account credential. The Admin service-account JSON is highly sensitive and must remain local.

The seed script is intended for development/demo data. Review the Firestore rules and production authentication/authorization design before using seeded accounts in a production environment.
