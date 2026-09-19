# IDManager - notes for Claude

Backend: .NET 8 (`backend/`). Frontend: Flutter (`frontend/idmanager_app/`). See
`README.md` for the architecture and how to run.

## Members, users and points - read the rules first

Anything involving members must follow **[docs/member-hierarchy.md](docs/member-hierarchy.md)**:
the four roles (SuperAdmin, Distributor, Retailer, User), who can create whom, who can
see whom, and how points move. That covers the Users screen, the Points screen, any
endpoint taking a user id, and card-generation point credits.

- Read that document before starting the work, and follow its checklist (section 8).
- The visibility and creation rules live in one place,
  `IDManager.Infrastructure/Members/MemberHierarchyService.cs`. Reuse it; never
  re-implement the rules in a service, endpoint or screen.
- If a rule changes, update the document in the same change.
