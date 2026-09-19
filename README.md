# IDManager

A card/ID template designer and generator: an image background with draggable text
and image layers on top, zoomable on screen, printed at exact physical size. Backend
is .NET Core; frontend is Flutter (web + Windows desktop from one codebase). The app
is fully online - every screen talks to the API directly; there is no offline mode,
local database, or sync engine.

## Members, users and points

The system is an MLM-style network of four member types (SuperAdmin, Distributor,
Retailer, User). Who can add whom, who can see whom, and how points move are defined in
**[docs/member-hierarchy.md](docs/member-hierarchy.md)** - read it before changing
anything that involves members, the Users or Points screens, or an endpoint that takes a
user id.

## Architecture

Both stacks follow the same layered-segregation pattern (adapted from RetinueSoft's
ReXL platform architecture): each layer depends only on the layer beneath it, and
business logic never leaks into UI or HTTP framework code.

**Backend** - three projects, Clean Architecture:
```
backend/src/
  IDManager.Domain/          Entities, Dtos, Enums, OperationResult - pure data, no logic, no ASP.NET dependency
  IDManager.Infrastructure/  DbContext + Services (all business logic), organized by feature (Security/Users/Points/Templates/Cards/AuditLog)
  IDManager.Api/             Program.cs (composition root) + Endpoints/ (Minimal API, thin - map OperationResult to real HTTP status codes)
```
Services return an `OperationResult`/`OperationResult<T>` (Success/NotFound/
ValidationFailed/Forbidden/Conflict, with field-level errors where relevant) instead
of throwing for expected outcomes; `EndpointResults.ToHttpResult()` maps that
uniformly to 200/404/400/403/409 across every endpoint - no generic
`{success,message}` envelope hiding real HTTP semantics.

**Frontend** - six layers, adapted from ReXL's Foundation → Infrastructure → Core
Engine → Business Service → Application → Presentation split, minus the
offline-specific pieces (no local Drift database, no Synchronization Engine - this
app has nothing to sync):
```
frontend/idmanager_app/lib/
  foundation/          ApiClient (Dio + JWT), theme, TokenStorage (session persistence) - no business logic
  infrastructure/      Repositories that call the API directly and map JSON <-> Core Engine domain models
  core_engine/          Freezed domain models + repository contracts (interfaces) + Engine services (validation, reusable capabilities), per module: security, points, templates, cards, audit
  business_service/    Cross-engine orchestration and business rules (e.g. CardGenerationService coordinates the Templates and Cards engines)
  application/          Riverpod controllers + freezed UI state, one per screen/workflow
  presentation/         Screens, shared widgets (MasterListScreen/ManageMasterScaffold reused across Users/Templates/Audit Log), go_router routing
```
Dependency rule: `presentation -> application -> business_service -> core_engine -> infrastructure -> foundation`.
Reverse dependencies are not allowed - e.g. `core_engine` never imports anything
from `infrastructure` or `presentation`.

## Why physical units

Every layer's position/size (`xMm`, `yMm`, `widthMm`, `heightMm`, `fontSizePt`) is
stored in millimeters/points relative to the template's real card size
(`cardWidthMm` / `cardHeightMm`), not screen pixels. On-screen zoom
(`InteractiveViewer` in the Flutter canvas) is purely a view transform - it never
touches these numbers. The backend renders the final PDF as true vector content at
the card's exact physical size from the same numbers, so print output is always
correct regardless of what zoom level the layout was designed at. See
`backend/src/IDManager.Infrastructure/Templates/PdfGenerationService.cs` and
`frontend/idmanager_app/lib/presentation/templates/template_editor_screen.dart`.

## Running the backend

Requires .NET 8 SDK and PostgreSQL.

```bash
cd backend/src/IDManager.Infrastructure
# set ConnectionStrings:Default and Jwt:Key in IDManager.Api/appsettings.json (or via
# environment variables / user-secrets) before running against a real database.
dotnet ef database update --startup-project ../IDManager.Api
cd ../IDManager.Api
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
dart run build_runner build --delete-conflicting-outputs   # generates .freezed.dart / .g.dart
flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:5080/api
# or, for a Windows build (must be run on Windows):
flutter build windows --dart-define=API_BASE_URL=https://your-api-host/api
```

`API_BASE_URL` defaults to `http://localhost:5080/api` if not specified. Re-run the
`build_runner` command after changing any `@freezed` model or `@riverpod` provider.

## Running the tests

```bash
# Backend (xUnit, against a real transaction-capable SQLite in-memory database -
# not EF Core's InMemory provider, which doesn't support the transactions
# PointsService relies on):
cd backend && dotnet test

# Frontend (core_engine services against fake repositories, plus JSON round-trip
# tests for the backend contract in template_mappers.dart):
cd frontend/idmanager_app && flutter test
```

## What's implemented in this skeleton

- Full role hierarchy (SuperAdmin/Admin/Distributor/User), JWT auth, points economy
  (allocate/reclaim/spend-on-card - SuperAdmin is the unlimited source, everyone else
  redistributes from their own balance), audit log.
- Template CRUD, multiple front/back image "combinations" per template, PDF field
  extraction (PdfPig), matching extracted fields to a template's positioned layers by
  key.
- The layer designer canvas: zoomable background image, draggable text/image layers,
  a properties panel (position, font size, bold, width/height), Save.
- End-user card generation flow: pick template + combination, upload a PDF, preview
  the matched card, download a true vector, exact-size PDF (no screenshot/rasterize
  step - see "Why physical units" above).
- Unit tests: backend (`PointsService`'s SuperAdmin-unlimited-pool rule and its edge
  cases, `TemplateService`'s layer-matching logic, `AuthService`, `CardService`'s
  guard clauses) and frontend (`core_engine` services against fake repositories,
  `template_mappers.dart` JSON round-trips against the backend's exact DTO shape).

## Known gaps / next iteration

- The designer canvas supports drag-to-reposition but not resize/rotate handles yet.
- PDF text-extraction row/column matching is a generic heuristic; a source document
  using a script/language PdfPig extracts imperfectly may need extra text-reordering
  fixups layered on top - deliberately left out here, see the comment in
  `PdfExtractionService.cs`.
- Test coverage stops at the service/engine layer - no Endpoint-level (WebApplicationFactory)
  or widget/screen-level tests yet, and `CardService`'s real PDF-extraction happy path
  is only exercised via manual/live testing, not a unit test fixture.
- `Jwt:Key` and the seed admin password are development defaults in
  `appsettings.json` - replace them (env vars / secret manager) before any real
  deployment.
