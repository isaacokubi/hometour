# HomeTour — Global Tours Flutter App

Flutter/Dart mobile client for **Global Tours**, backed directly by **Firebase Authentication and Cloud Firestore**.

## Database migration

The mobile application no longer uses MongoDB, Mongoose, the MERN API, Axios/Dio, or API login/session endpoints.

The application now uses Firebase Authentication for email/password sign-in, Cloud Firestore for users, tenants, tours and bookings, and Firebase Security Rules for tenant isolation and customer booking access.

No Firebase service-account credentials belong in this Flutter application.

## Firestore collections

Expected documents:

- users/{firebaseUid}: email, name, tenantId, role
- tours/{tourId}: tenantId, title, description, location, price, durationDays, featured, imageUrl
- bookings/{bookingId}: userId, tenantId, tourId, tourName, travelDate, numberOfGuests, unitPrice, totalAmount, status, bookingSource, paymentMethod, createdAt, updatedAt

## Firebase setup

Firebase recommends FlutterFire configuration for registering Android, iOS and web applications:
https://firebase.google.com/docs/flutter/setup

After the Firebase project and apps are configured:

1. Copy .env.example to .env.
2. Enter the Firebase client configuration values.
3. Enable Email/Password authentication.
4. Create the Firestore database.
5. Deploy firestore.rules.
6. Create a users/{uid} document for each authenticated customer and set tenantId.
7. Add tenant-scoped tour documents to tours.
8. Run the Flutter application.

The .env file is intentionally ignored by Git. Firebase client identifiers are not server secrets; Firestore Security Rules remain the authorization boundary.

## Run

    flutter pub get
    flutter analyze
    flutter test
    flutter run

## Firebase rules deployment

    firebase login
    firebase use YOUR_FIREBASE_PROJECT_ID
    firebase deploy --only firestore:rules

This repository contains no MongoDB or Mongoose application code.
