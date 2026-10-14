# MDC Connect

A Flutter student concern management prototype for submitting and following campus issues.

## Features

- Submit a concern with validated title, category, and description fields.
- Browse concerns with `ListView.builder`, search by text, and filter by status.
- Delete a concern after confirmation.
- Navigate between the concern feed and a short “How it works” guide.
- Load sample entries from JSONPlaceholder on first launch and fall back to built-in examples offline.
- Save entries on the device with SharedPreferences.

## Demo data and limits

JSONPlaceholder supplies sample posts for the API integration requirement. New concerns and deletions are saved locally; they are not sent to MDC staff. A real management workflow needs a school backend and authentication.

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
