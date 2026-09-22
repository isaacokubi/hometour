# HomeTour — Global Tours Flutter App

Flutter/Dart mobile client for the Global Tours multi-tenant tours and travel platform.

## Source repository audited

https://github.com/isaacokubi/hussein-mboya-tours

The source repository is a production-oriented MERN SaaS covering tenant isolation, authentication, tours, destinations, bookings, payments, finance, hospitality, operations, RBAC and Kenyan compliance/eTIMS architecture.

## Source audit findings

The source README records the 2026-09-21 code verification baseline as passing: server static checks, 95 backend tests with 92 passed and 3 intentionally skipped, security tests, tour-domain tests, client lint/build and the production-readiness contract. It also explicitly states that live production/provider certification remained unverified.

The source API contract uses tenant-aware headers. The Flutter client follows that model by persisting the authenticated tenant ID and sending X-Tenant-ID, or using X-Tenant-Slug for public tenant resolution.

Relevant API contracts ported into the mobile client include:
- GET /auth/me
- POST /auth/login
- POST /auth/logout
- GET /tours
- GET /bookings/my-bookings
- POST /bookings

## Implemented mobile application

- Global Tours Material 3 shell.
- Secure authentication/session storage.
- Tenant-aware API requests.
- Home/explore experience.
- Tours listing.
- Tour details.
- Date and traveller selection.
- Booking creation.
- Customer booking history.
- Profile and logout.
- API URL override using --dart-define=API_URL.

## Run

Default Android emulator API URL:
http://10.0.2.2:5000/api

Run against a deployed API:
flutter run --dart-define=API_URL=https://YOUR-API-HOST/api

Development:
flutter pub get
flutter analyze
flutter test
flutter run

This repository is a Flutter mobile client; it does not copy the React UI. It reuses the audited backend's API/domain contracts so the mobile application can operate alongside the existing web platform.
