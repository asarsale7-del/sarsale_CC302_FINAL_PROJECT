# MDC Connect

A Flutter campus concern management prototype for submitting and following campus issues.

## Features

- Let students and school staff create accounts and sign in with a school ID and password.
- Keep each account's saved concerns separate on the device.
- Use the royal-blue Material theme across sign-in and concern screens.
- Keep the interface palette to blue, yellow, and white.
- Show the Mater Dei campus as the sign-in and account-creation background.
- Submit a concern with validated title, category, and description fields.
- Browse concerns with `ListView.builder`, search by text, and filter by status.
- Delete a concern after confirmation.
- Navigate between the concern feed and a short “How it works” guide.
- Load sample entries from JSONPlaceholder on first launch and fall back to built-in examples offline.
- Save entries on the device with SharedPreferences.

## Demo data and limits

JSONPlaceholder supplies sample posts for the API integration requirement. New concerns and deletions are saved locally; they are not sent to MDC staff. A real management workflow needs a school backend and authentication.

Student and staff accounts are local to the device. Passwords use salted hashes in this prototype. Account creation does not verify that an ID belongs to an enrolled student or employee. Use MDC's authentication service for verified identities and shared account access.

## Run

```sh
flutter pub get
flutter run
```

## Check

```sh
flutter analyze
flutter test
flutter build web
```
