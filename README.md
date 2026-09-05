<div align="center">

# SaveFood — Anti Food Waste App

A Flutter marketplace app for Algeria that connects bakeries, restaurants, supermarkets, and cafes with nearby consumers and charities, so surplus food gets sold at a discount or donated instead of thrown away.

[![Flutter](https://img.shields.io/badge/Flutter-3.4+-02569B?logo=flutter)](https://flutter.dev/)
[![Dart](https://img.shields.io/badge/Dart-3-0175C2?logo=dart)](https://dart.dev/)
[![Firebase](https://img.shields.io/badge/Firebase-Auth%20%7C%20Firestore%20%7C%20FCM-FFCA28?logo=firebase)](https://firebase.google.com/)
[![Django REST API](https://img.shields.io/badge/Backend-Django%20REST%20API-092E20?logo=django)](https://www.django-rest-framework.org/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](#license)

</div>

<br>

## Overview

SaveFood is a three sided app built with Flutter: merchants list surplus food, consumers buy it at a reduced price, and charities can claim what's left as a donation. The mobile client talks to a Django REST API backend and uses Firebase for authentication, push notifications, and some real time data.

The app leans into a specific market: prices are shown in Algerian Dinar (DZD), and the onboarding screens carry an Algerian flag accent, so this isn't a generic template project. It's built around a real workflow: a merchant posts a listing before it expires, a consumer reserves it and picks it up with a QR code, and unclaimed surplus can be routed to a charity instead of the bin.

<br>

## Key Features

| Area | Description |
|---|---|
| Three user roles | Consumer, Merchant, and Charity, each with its own onboarding and home flow |
| Merchant listings | Create and manage surplus food listings with category, dietary tags, freshness grade, pricing, and pickup windows |
| Consumer marketplace | Browse and search nearby deals, save favorites, and reserve items before they expire |
| Charity donations | Merchants can flag surplus as a donation; charities browse available donations by urgency and distance |
| Pickup route planning | Backend powered route optimization (`/orders/route-plan/`) so a charity can plan one trip across multiple pickups |
| QR based pickup | `mobile_scanner` / `qr_flutter` are used to verify order pickup at the merchant's counter |
| Merchant subscriptions | Billing plans control how many active listings a merchant can run and whether they can receive donations |
| Verification flow | Merchant and charity accounts go through a document review / pending approval step before they can transact |
| Chat | In app messaging between merchants and consumers/charities |
| Maps and location | Google Maps integration, geocoding, and distance calculation for nearby listings |
| Notifications | Firebase Cloud Messaging plus local notifications for order and listing updates |
| Localization | `flutter_localizations` and `l10n.yaml` for multi language support |
| Offline caching | `hive` for local storage and `cached_network_image` for image caching |

<br>

## Tech Stack

**Framework and language**
* [Flutter](https://flutter.dev/) (Dart SDK 3.4+)
* [flutter_bloc](https://pub.dev/packages/flutter_bloc) and [provider](https://pub.dev/packages/provider) for state management
* [equatable](https://pub.dev/packages/equatable) for value comparisons

**Backend and data**
* Django REST API (external service, consumed over HTTP via `dio`)
* [Firebase](https://firebase.google.com/): `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_messaging`
* [Google Sign In](https://pub.dev/packages/google_sign_in)
* [hive](https://pub.dev/packages/hive) / `hive_flutter` for local persistence
* [flutter_secure_storage](https://pub.dev/packages/flutter_secure_storage) and `shared_preferences` for tokens and app settings

**Maps and location**
* [google_maps_flutter](https://pub.dev/packages/google_maps_flutter)
* [geolocator](https://pub.dev/packages/geolocator) / [geocoding](https://pub.dev/packages/geocoding)
* [permission_handler](https://pub.dev/packages/permission_handler)

**Media, scanning, and UI**
* [mobile_scanner](https://pub.dev/packages/mobile_scanner) / [qr_flutter](https://pub.dev/packages/qr_flutter) for QR code pickup verification
* [image_picker](https://pub.dev/packages/image_picker), [cached_network_image](https://pub.dev/packages/cached_network_image)
* [google_fonts](https://pub.dev/packages/google_fonts), [flutter_svg](https://pub.dev/packages/flutter_svg), [shimmer](https://pub.dev/packages/shimmer)
* [flutter_animate](https://pub.dev/packages/flutter_animate) / [animate_do](https://pub.dev/packages/animate_do) for UI motion
* [fl_chart](https://pub.dev/packages/fl_chart) for merchant analytics
* [speech_to_text](https://pub.dev/packages/speech_to_text) for voice input

**Networking and messaging**
* [dio](https://pub.dev/packages/dio) as the HTTP client
* [web_socket_channel](https://pub.dev/packages/web_socket_channel) for real time chat

<br>

## Project Structure

```
anti_food_waste_app/
├── lib/
│   ├── main.dart                 (App entry point)
│   ├── firebase_options.dart     (Generated Firebase config)
│   ├── core/
│   │   ├── config/                 (App config, e.g. API base URL per environment)
│   │   ├── constants/              (Shared constants)
│   │   ├── navigation/             (App router)
│   │   ├── network/                 (API client and exception handling)
│   │   ├── providers/               (Shared app level providers)
│   │   ├── services/                 (Cross cutting services)
│   │   └── utils/                     (Helpers)
│   ├── l10n/                      (Localization resources)
│   └── features/
│       ├── auth/                    (Sign up, sign in, Google auth)
│       ├── role_selector/           (Consumer / Merchant / Charity entry point)
│       ├── onboarding/              (First run onboarding flow)
│       ├── home/                    (Home feed per role)
│       ├── search/                  (Listing search)
│       ├── favorites/               (Saved listings)
│       ├── merchant/                (Listing management, merchant orders, stats)
│       ├── consumer/                (Consumer facing browsing/ordering)
│       ├── charity/                 (Donation browsing and claiming)
│       ├── orders/                  (Order lifecycle, route planning)
│       ├── verification/            (Merchant / charity document approval)
│       ├── billing/                 (Subscription plans)
│       ├── chat/                    (Messaging between roles)
│       ├── notifications/           (In app + push notifications)
│       ├── profile/                 (Account/profile management)
│       └── help/                    (Support / help center)
├── assets/images/                (App and onboarding images)
├── android/ ios/ web/ macos/ windows/ linux/   (Platform runners)
├── test/                          (Widget and integration tests)
├── pubspec.yaml
└── l10n.yaml
```

Each feature generally follows a `data / domain / presentation` layering: `domain` holds models (and repositories where present), `data` handles API and serialization, and `presentation` holds screens, widgets, and state management (BLoC or Provider).

<br>

## Core Flows

### Merchant
1. Sign up and go through account verification before the account is approved to sell.
2. Create listings with category, dietary tags, pricing, quantity, and a pickup window.
3. Optionally mark surplus as a donation instead of a paid listing.
4. Manage incoming orders and check the merchant dashboard/stats.
5. Subscribe to a billing plan that determines the number of active listings allowed and whether donations can be received.

### Consumer
1. Browse or search nearby deals on the map or list view.
2. Save favorites and reserve a listing before it expires.
3. Show up at the pickup window and confirm pickup via QR code.
4. Chat with the merchant if needed, and get notified about order status changes.

### Charity
1. Go through document verification before being approved to claim donations.
2. Browse available donations, filtered by urgency, category, and distance.
3. Claim a donation and, when multiple pickups are involved, request an optimized route plan.
4. Confirm collection at the merchant's location.

<br>

## Getting Started

### Prerequisites

* [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.4 or later (Dart 3.4+)
* A configured Firebase project (Android/iOS/Web apps registered, `firebase_options.dart` regenerated with `flutterfire configure` for your own project)
* A running instance of the Django REST API backend this app talks to
* A Google Maps API key for `google_maps_flutter`

### 1. Clone the repository

```bash
git clone https://github.com/Zineddine-Rebbouh/anti_food_waste_app.git
cd anti_food_waste_app
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Point the app at your backend

The API base URL is set via a compile time define in `lib/core/config/app_config.dart` and can be overridden at build/run time:

```bash
# Android emulator talking to a backend on your machine
flutter run --dart-define=BASE_URL=http://10.0.2.2:8000/api/v1/

# Physical device on the same network
flutter run --dart-define=BASE_URL=http://<your-lan-ip>:8000/api/v1/

# Production
flutter run --dart-define=ENV=prod --dart-define=BASE_URL=https://api.savefood.dz/api/v1/
```

### 4. Configure Firebase

Set up your own Firebase project and regenerate the config:

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

This regenerates `lib/firebase_options.dart` for your project's Android, iOS, and web apps.

### 5. Run the app

```bash
flutter run
```

<br>

## Testing

```bash
flutter test
```

Tests live under `test/`, including a merchant listing test and a listing integration diagnostic.

<br>

## Roadmap Ideas

* [ ] CI pipeline for automated builds and tests
* [ ] End to end tests for the pickup and donation flows
* [ ] Expanded analytics for merchant dashboards
* [ ] More granular push notification preferences

<br>

## Contributing

Contributions, issues, and feature requests are welcome.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

<br>

## License

This project is licensed under the MIT License.

<br>

## Author

**Zineddine Rebbouh**
GitHub: [@Zineddine-Rebbouh](https://github.com/Zineddine-Rebbouh)

</div>
