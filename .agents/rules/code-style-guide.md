---
trigger: always_on
glob:
description:
---

## Routing Guidelines
- **Modular Routes**: Group routes by feature into their own files and classes (e.g., `HomeRoutes` in `home_routes.dart`). Spread these feature routes into the main `AppRoutes`.
- **Named Routes**: Always provide a `name` for each `GoRoute`.
- **Static Route Names**: Store route names as `static const String` variables within the route classes (e.g., `static const String homeRoute = 'home';`) to avoid hardcoding strings and prevent typos.
