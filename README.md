# IDManager

A card/ID template designer and generator: an image background with draggable text
and image layers on top, zoomable on screen, printed at exact physical size. Backend
is .NET Core; frontend is Flutter (web + Windows desktop from one codebase).

## Why physical units

Every layer's position/size (`xMm`, `yMm`, `widthMm`, `heightMm`, `fontSizePt`) is
stored in millimeters/points relative to the template's real card size
(`cardWidthMm` / `cardHeightMm`), not screen pixels. On-screen zoom
(`InteractiveViewer` in the Flutter canvas) is purely a view transform - it never
touches these numbers. The backend renders the final PDF as true vector content at
the card's exact physical size from the same numbers, so print output is always
correct regardless of what zoom level the layout was designed at. See
`backend/IDManager.Api/Persistence/Services/PdfGenerationService.cs` and
`frontend/idmanager_app/lib/features/templates/template_editor_screen.dart`.

## Structure

```
backend/                    .NET 8 Web API (IDManager.Api)
  Domain/Entities/          User, CardTemplate, TemplateCombination, IDCard, PointTransaction, AuditLog
  Dtos/                     API contracts, incl. the physical-unit layer model (TemplateLayerDtos.cs)
  Persistence/Services/     Business logic (Auth, User, Template, Points, PDF extraction/generation, AuditLog)
  Controllers/              REST endpoints
frontend/idmanager_app/     Flutter app (targets: web, windows)
  lib/core/                 models, network (Dio API clients), Riverpod state, theme
  lib/features/             auth, dashboard, templates (designer), cards (generate/print), users, points, audit_log
```

## Running the backend

Requires .NET 8 SDK and PostgreSQL.

```bash
cd backend/IDManager.Api
# set ConnectionStrings:DefaultConnection and Jwt:Key in appsettings.json (or via
# environment variables / user-secrets) before running against a real database.
dotnet ef database update
dotnet run
```

On first run, if the `Users` table is empty, a SuperAdmin account is seeded:
- Phone: `9999999999` (override with `SeedAdmin:Phone`)
- Password: `Admin@123` (override with `SeedAdmin:Password`)

Swagger UI is available at `/swagger` in Development.

## Running the frontend

Requires the Flutter SDK (stable channel, web + Windows desktop enabled).

```bash
cd frontend/idmanager_app
flutter pub get
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:5080/api
# or, for a Windows build (must be run on Windows):
flutter build windows --dart-define=API_BASE_URL=https://your-api-host/api
```

`API_BASE_URL` defaults to `http://localhost:5080/api` if not specified.

## What's implemented in this skeleton

- Full role hierarchy (SuperAdmin/Admin/Distributor/User), JWT auth, points economy
  (increase/decrease/spend-on-card, mirroring the points ledger from the predecessor
  app), audit log.
- Template CRUD, multiple front/back image "combinations" per template, PDF field
  extraction (PdfPig), matching extracted fields to a template's positioned layers by
  key.
- The layer designer canvas: zoomable background image, draggable text/image layers,
  a properties panel (position, font size, bold, width/height), Save.
- End-user card generation flow: pick template + combination, upload a PDF, preview
  the matched card, download a true vector, exact-size PDF (no screenshot/rasterize
  step - see "Why physical units" above).

## Known gaps / next iteration

- The designer canvas supports drag-to-reposition but not resize/rotate handles yet.
- PDF text-extraction row/column matching is a generic heuristic; the predecessor app
  had script-specific (Tamil) Unicode-reordering fixes layered on top for one
  particular source document - intentionally left out here, see the comment in
  `PdfExtractionService.cs`.
- No automated test coverage yet beyond a basic Flutter widget smoke test.
- `Jwt:Key` and the seed admin password are development defaults in
  `appsettings.json` - replace them (env vars / secret manager) before any real
  deployment.
