---
trigger: always_on
glob:
description:
---

## Routing Guidelines
- **Modular Routes**: Group routes by feature into their own files and classes (e.g., `HomeRoutes` in `home_routes.dart`). Spread these feature routes into the main `AppRoutes`.
- **Named Routes**: Always provide a `name` for each `GoRoute`.
- **Static Route Names**: Store route names as `static const String` variables within the route classes (e.g., `static const String homeRoute = 'home';`) to avoid hardcoding strings and prevent typos.

## Riverpod Notifier Mutations
- **onSuccess and onError Callbacks**: When creating methods in `AsyncNotifier` (or similar providers) that perform mutations (like adding or removing a service, logging in, etc.), include optional `VoidCallback? onSuccess` and `void Function(String)? onError` parameters.
- **State Invalidation**: Upon a successful API call, call `ref.invalidateSelf();` and `await future;` before invoking the `onSuccess` callback.
- **Error Handling**: Use `AppExceptionHandler.instance.handleError(e, st);` in the catch block and invoke the `onError` callback with `e.toFriendlyString()`.
