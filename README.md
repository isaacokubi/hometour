# HomeTour — Global Tours Flutter App

Flutter/Dart mobile client for **Global Tours**, backed directly by **Firebase Authentication and Cloud Firestore**.

## Architecture

The mobile application no longer uses MongoDB, Mongoose, the MERN API, Axios/Dio, or API login/session endpoints.

The application uses:

- Firebase Authentication for email/password sign-in.
- Cloud Firestore for user profiles, tenant-scoped tours and customer bookings.
- Firebase Security Rules as the authorization boundary.
- Flutter dotenv for local Firebase client configuration.
- Provider for application/session state.

No Firebase service-account credentials belong in this Flutter application.

## Firestore collections

Expected documents:

- `users/{firebaseUid}`: `email`, `name`, `tenantId`, `role`
- `tours/{tourId}`: `tenantId`, `title`, `description`, `location`, `price`, `durationDays`, `featured`, `imageUrl`
- `bookings/{bookingId}`: `userId`, `tenantId`, `tourId`, `tourName`, `travelDate`, `numberOfGuests`, `unitPrice`, `totalAmount`, `status`, `bookingSource`, `paymentMethod`, `createdAt`, `updatedAt`

A customer's `users/{uid}.tenantId` is authoritative. The app does not inject a fallback tenant into an incomplete user profile.

## Firebase setup

Use the Firebase Console and FlutterFire tooling to register the Android, iOS and web apps for the Firebase project.

### Local configuration

1. Copy the example configuration:
   ```bash
   cp .env.example .env
   chmod 600 .env
   ```
2. Enter the Firebase client configuration values from your Firebase project.
3. Never commit `.env`; it is already excluded by `.gitignore`.
4. Enable **Email/Password** authentication.
5. Create the Firestore database.
6. Deploy the checked-in rules and indexes:
   ```bash
   firebase login
   firebase use YOUR_FIREBASE_PROJECT_ID
   firebase deploy --only firestore
   ```
7. Create a `users/{firebaseUid}` document for every authenticated customer and set a non-empty `tenantId`.
8. Add tenant-scoped tour documents to `tours`.
9. Run the Flutter application.

Firebase client identifiers are not server secrets. Firestore Security Rules remain the authorization boundary.

### FlutterFire CLI

For a real Firebase project, FlutterFire can generate platform registration/configuration:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

If the project keeps configuration in `.env`, ensure the generated Firebase project/app identifiers match the values in `.env`.

## Run and verify

```bash
flutter pub get
flutter analyze
flutter test
flutter run
```

## Production build

Before a release build:

1. Verify the Firebase project ID and app IDs in `.env`.
2. Verify Android package/application ID and iOS bundle ID match the registered Firebase apps.
3. Deploy Firestore rules and indexes.
4. Verify authentication and tenant-isolated tour/booking access with a real Firebase project.
5. Build using the target platform's normal Flutter release process.

This repository intentionally does not contain Firebase service-account credentials or a production `.env` file.

## Security model

- Unauthenticated Firestore access is denied.
- A signed-in customer can read only their own `users/{uid}` profile.
- Tours are readable only when their `tenantId` matches the authenticated user's tenant.
- Bookings can be created only for the authenticated user, their tenant, and the mobile booking source.
- Customers cannot update or delete bookings through the mobile client.
- All other Firestore documents are denied by the catch-all rule.

This repository contains no MongoDB or Mongoose application code.
