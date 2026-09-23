import admin from 'firebase-admin';
import crypto from 'node:crypto';
import fs from 'node:fs';
import path from 'node:path';

const PROJECT_ID = process.env.FIREBASE_PROJECT_ID || 'hometour-6bdde';
const SERVICE_ACCOUNT_PATH =
  process.env.GOOGLE_APPLICATION_CREDENTIALS ||
  path.resolve('.secrets/firebase-service-account.json');
const CREDENTIALS_OUTPUT =
  process.env.SEED_CREDENTIALS_OUTPUT ||
  path.resolve('.secrets/seed-credentials.json');

if (!fs.existsSync(SERVICE_ACCOUNT_PATH)) {
  console.error('\nFirebase service-account file was not found.');
  console.error(`Expected: ${SERVICE_ACCOUNT_PATH}`);
  console.error('Download a service-account JSON from Firebase Console > Project settings > Service accounts,');
  console.error('save it at .secrets/firebase-service-account.json, then run this seed again.');
  process.exit(1);
}

let serviceAccount;
try {
  serviceAccount = JSON.parse(fs.readFileSync(SERVICE_ACCOUNT_PATH, 'utf8'));
} catch (error) {
  console.error('\nThe Firebase service-account file is not valid JSON.');
  console.error(error.message);
  process.exit(1);
}

const requiredServiceAccountFields = ['project_id', 'client_email', 'private_key'];
const missingFields = requiredServiceAccountFields.filter(
  (field) => typeof serviceAccount[field] !== 'string' || serviceAccount[field].trim() === '',
);

if (missingFields.length > 0) {
  console.error('\nThe selected JSON is NOT a Firebase Admin SDK service-account key.');
  console.error(`Missing required fields: ${missingFields.join(', ')}`);
  console.error('Do not use google-services.json, firebase_options files, or web Firebase config files here.');
  console.error('Download a new private key from Firebase Console > Project settings > Service accounts > Firebase Admin SDK.');
  process.exit(1);
}

if (serviceAccount.project_id !== PROJECT_ID) {
  console.error('\nThe Firebase service-account belongs to a different project.');
  console.error(`Expected project: ${PROJECT_ID}`);
  console.error(`Key project: ${serviceAccount.project_id}`);
  process.exit(1);
}

admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  projectId: PROJECT_ID,
});

const db = admin.firestore();
const auth = admin.auth();
const Timestamp = admin.firestore.Timestamp;

const tenantDefinitions = [
  {
    id: 'tenant-amani-trails',
    slug: 'amani-trails-safaris',
    name: 'Amani Trails Safaris',
    legalName: 'Amani Trails Safaris Ltd',
    city: 'Nairobi',
    country: 'Kenya',
    phone: '+254 700 100 101',
    email: 'info@amanitrails.example',
    website: 'https://amani-trails-safaris.example',
    currency: 'KES',
    description: 'Kenya-focused safari and beach travel operator.',
  },
  {
    id: 'tenant-savanna-crown',
    slug: 'savanna-crown-safaris',
    name: 'Savanna Crown Safaris',
    legalName: 'Savanna Crown Safaris Ltd',
    city: 'Nairobi',
    country: 'Kenya',
    phone: '+254 700 100 102',
    email: 'info@savannacrown.example',
    website: 'https://savannacrown.example',
    currency: 'KES',
    description: 'Safari, wildlife and cultural experiences across East Africa.',
  },
  {
    id: 'tenant-coastal-horizon',
    slug: 'coastal-horizon-adventures',
    name: 'Coastal Horizon Adventures',
    legalName: 'Coastal Horizon Adventures Ltd',
    city: 'Mombasa',
    country: 'Kenya',
    phone: '+254 700 100 103',
    email: 'info@coastalhorizon.example',
    website: 'https://coastalhorizon.example',
    currency: 'KES',
    description: 'Coastal holidays, island excursions and Kenyan adventure travel.',
  },
];

const roleDefinitions = [
  { key: 'admin', label: 'Administrator', emailPrefix: 'admin', nameSuffix: 'Admin' },
  { key: 'manager', label: 'Manager', emailPrefix: 'manager', nameSuffix: 'Manager' },
  { key: 'agent', label: 'Travel Agent', emailPrefix: 'agent', nameSuffix: 'Agent' },
  { key: 'guide', label: 'Tour Guide', emailPrefix: 'guide', nameSuffix: 'Guide' },
  { key: 'customer1', label: 'Customer', emailPrefix: 'customer1', nameSuffix: 'Customer One' },
  { key: 'customer2', label: 'Customer', emailPrefix: 'customer2', nameSuffix: 'Customer Two' },
];

const destinationTemplates = [
  ['Maasai Mara', 'Narok County', 'Kenya', 'Classic Big Five safari destination.'],
  ['Amboseli National Park', 'Kajiado County', 'Kenya', 'Elephants with views toward Mount Kilimanjaro.'],
  ['Lake Nakuru', 'Nakuru County', 'Kenya', 'Rift Valley wildlife and birding destination.'],
  ['Diani Beach', 'Kwale County', 'Kenya', 'Indian Ocean beach holiday destination.'],
  ['Lamu Old Town', 'Lamu County', 'Kenya', 'Historic Swahili coastal destination.'],
];

const tourTemplates = [
  ['Maasai Mara Explorer', 'Maasai Mara', 3, 45000, 'Three-day wildlife safari with game drives and full-board accommodation.'],
  ['Amboseli Wildlife Escape', 'Amboseli National Park', 2, 32000, 'Two-day wildlife experience with guided game drives.'],
  ['Rift Valley Discovery', 'Lake Nakuru', 2, 28000, 'Two-day Lake Nakuru and Rift Valley discovery package.'],
  ['Diani Beach Retreat', 'Diani Beach', 4, 52000, 'Four-day beach retreat with transfers and selected excursions.'],
  ['Lamu Heritage Journey', 'Lamu Old Town', 3, 39000, 'Three-day coastal heritage and cultural experience.'],
  ['Kenya Grand Circuit', 'Kenya', 7, 125000, 'Seven-day multi-destination Kenya highlights itinerary.'],
];

function password() {
  return `GT!${crypto.randomBytes(8).toString('base64url')}9a`;
}

function slug(value) {
  return value.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
}

function safeEmailPart(value) {
  return slug(value);
}

function stableId(prefix, ...parts) {
  return `${prefix}-${parts.map(slug).join('-')}`;
}

async function upsertAuthUser({ email, displayName, password: pwd }) {
  let user;
  try {
    user = await auth.getUserByEmail(email);
    user = await auth.updateUser(user.uid, {
      password: pwd,
      displayName,
      disabled: false,
      emailVerified: true,
    });
  } catch (error) {
    if (error.code !== 'auth/user-not-found') throw error;
    user = await auth.createUser({
      email,
      password: pwd,
      displayName,
      emailVerified: true,
      disabled: false,
    });
  }
  return user;
}

async function setClaims(uid, tenantId, role) {
  await auth.setCustomUserClaims(uid, {
    tenantId,
    role,
    globalTours: true,
  });
}

async function seed() {
  const now = Timestamp.now();
  const credentials = [];

  console.log(`Seeding Firebase project: ${PROJECT_ID}`);
  console.log(`Service account: ${serviceAccount.client_email}\n`);

  for (const tenant of tenantDefinitions) {
    await db.collection('tenants').doc(tenant.id).set({
      ...tenant,
      status: 'active',
      demoSeed: true,
      updatedAt: now,
      createdAt: now,
    }, { merge: true });

    const destinationIds = [];
    for (const [index, item] of destinationTemplates.entries()) {
      const [name, county, country, description] = item;
      const id = stableId('destination', tenant.id, index + 1);
      destinationIds.push(id);
      await db.collection('destinations').doc(id).set({
        tenantId: tenant.id,
        name,
        slug: slug(name),
        county,
        country,
        description,
        status: 'active',
        demoSeed: true,
        updatedAt: now,
        createdAt: now,
      }, { merge: true });
    }

    const tourIds = [];
    for (const [index, item] of tourTemplates.entries()) {
      const [title, location, durationDays, price, description] = item;
      const id = stableId('tour', tenant.id, index + 1);
      tourIds.push(id);
      await db.collection('tours').doc(id).set({
        tenantId: tenant.id,
        title,
        slug: slug(title),
        description,
        location,
        price,
        durationDays,
        featured: index < 2,
        imageUrl: '',
        currency: tenant.currency,
        status: 'active',
        availableSeats: 20 + index * 5,
        destinationId: destinationIds[index % destinationIds.length],
        demoSeed: true,
        updatedAt: now,
        createdAt: now,
      }, { merge: true });
    }

    const supplierId = stableId('supplier', tenant.id, 'primary');
    await db.collection('suppliers').doc(supplierId).set({
      tenantId: tenant.id,
      name: `${tenant.name} Preferred Travel Supplier`,
      type: 'transport_and_accommodation',
      contactName: 'Demo Supplier Contact',
      phone: '+254 711 222 333',
      email: `supplier@${safeEmailPart(tenant.name)}.example`,
      status: 'active',
      demoSeed: true,
      updatedAt: now,
      createdAt: now,
    }, { merge: true });

    const accommodationId = stableId('accommodation', tenant.id, 'demo');
    await db.collection('accommodations').doc(accommodationId).set({
      tenantId: tenant.id,
      name: `${tenant.name} Demo Lodge Partner`,
      location: tenant.city,
      roomTypes: ['Standard', 'Deluxe', 'Family'],
      status: 'active',
      demoSeed: true,
      updatedAt: now,
      createdAt: now,
    }, { merge: true });

    for (const role of roleDefinitions) {
      const email = `${role.emailPrefix}@${safeEmailPart(tenant.name)}.demo.globaltours.test`;
      const displayName = `${tenant.name} ${role.nameSuffix}`;
      const pwd = password();
      const user = await upsertAuthUser({ email, displayName, password: pwd });
      const actualRole = role.key.startsWith('customer') ? 'customer' : role.key;

      await setClaims(user.uid, tenant.id, actualRole);

      await db.collection('users').doc(user.uid).set({
        email,
        name: displayName,
        tenantId: tenant.id,
        tenantName: tenant.name,
        role: actualRole,
        roleLabel: role.label,
        status: 'active',
        isActive: true,
        phone: '+254 700 000 000',
        demoSeed: true,
        authProvider: 'password',
        updatedAt: now,
        createdAt: now,
      }, { merge: true });

      credentials.push({
        tenant: tenant.name,
        tenantId: tenant.id,
        role: actualRole,
        email,
        password: pwd,
        uid: user.uid,
      });
    }

    const customerCredentials = credentials.filter(
      (entry) => entry.tenantId === tenant.id && entry.role === 'customer',
    );

    for (const [customerIndex, customer] of customerCredentials.entries()) {
      for (let bookingIndex = 0; bookingIndex < 2; bookingIndex++) {
        const tourIndex = (customerIndex * 2 + bookingIndex) % tourIds.length;
        const bookingId = stableId(
          'booking',
          tenant.id,
          customerIndex + 1,
          bookingIndex + 1,
        );
        const travelDate = new Date();
        travelDate.setDate(travelDate.getDate() + 14 + customerIndex * 7 + bookingIndex * 3);
        const unitPrice = tourTemplates[tourIndex][3];
        const guests = customerIndex + bookingIndex + 1;

        await db.collection('bookings').doc(bookingId).set({
          userId: customer.uid,
          tenantId: tenant.id,
          tourId: tourIds[tourIndex],
          tourName: tourTemplates[tourIndex][0],
          travelDate: Timestamp.fromDate(travelDate),
          numberOfGuests: guests,
          unitPrice,
          totalAmount: unitPrice * guests,
          status: bookingIndex === 0 ? 'pending' : 'confirmed',
          bookingSource: 'mobile_app',
          paymentMethod: 'MPESA',
          createdAt: now,
          updatedAt: now,
          demoSeed: true,
        }, { merge: true });
      }
    }

    await db.collection('paymentGateways').doc(stableId('gateway', tenant.id, 'mpesa')).set({
      tenantId: tenant.id,
      provider: 'MPESA',
      displayName: 'M-Pesa Demo Gateway',
      mode: 'test',
      status: 'configured',
      shortcode: '174379',
      callbackUrl: '',
      demoSeed: true,
      updatedAt: now,
      createdAt: now,
    }, { merge: true });

    console.log(`✓ ${tenant.name}: tenant + 5 destinations + 6 tours + 6 users + bookings + demo operations data`);
  }

  fs.mkdirSync(path.dirname(CREDENTIALS_OUTPUT), { recursive: true });
  fs.writeFileSync(
    CREDENTIALS_OUTPUT,
    JSON.stringify({
      generatedAt: new Date().toISOString(),
      projectId: PROJECT_ID,
      warning: 'Demo credentials. Keep this file private. Running the seed again rotates the passwords.',
      users: credentials,
    }, null, 2) + '\n',
    { mode: 0o600 },
  );

  console.log('\n============================================================');
  console.log('FIREBASE SEED COMPLETE');
  console.log('============================================================');
  console.log(`Users seeded: ${credentials.length}`);
  console.log(`Credential file: ${CREDENTIALS_OUTPUT}`);
  console.log('Passwords were generated locally and are not stored in the repository.');
  console.log('============================================================\n');
}

seed()
  .catch((error) => {
    console.error('\nFIREBASE SEED FAILED');
    console.error(error);
    process.exitCode = 1;
  })
  .finally(async () => {
    await admin.app().delete();
  });
