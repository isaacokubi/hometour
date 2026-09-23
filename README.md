# HomeTour / Global Tours

The MERN repository isaacokubi/hussein-mboya-tours is a read-only product specification. This repository is the Flutter/Firebase implementation target and never modifies the MERN source.

The implementation covers the source domain across authentication, tenant isolation, customer tours and bookings, role workspaces, operations, hospitality, finance/payment read models, reviews, wishlist, quotations, custom tour requests, transfers, vehicles, staff, commissions, invoices, notifications and platform tenant administration.

Business-critical payment credentials, M-Pesa secrets and callbacks belong in trusted server-side functions. They must never be stored as Flutter secrets or client-readable Firestore fields.

Run: create .env from .env.example, run flutter pub get, flutter analyze, flutter test and flutter build web.
