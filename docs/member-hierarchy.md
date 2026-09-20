# Member hierarchy (MLM) - the rules for members, users and points

**Read this before building or changing anything that involves members**: the Users
screen, the Points screen, creating/editing/deactivating a member, allocating or
reclaiming points, card generation credits, or any endpoint that takes a user id.
Every such change must follow the rules below, and this document must be updated in
the same change if a rule changes.

The system is a network (MLM): every member has exactly one **parent** - the member who
created them (`UserEntity.CreatedById`). Members form a tree with the SuperAdmin at
the top.

## 1. Member types (roles)

| Role         | Enum (`UserRole`) | Notes                                             |
| ------------ | ----------------- | ------------------------------------------------- |
| SuperAdmin   | `SuperAdmin` = 1  | Root of the tree. The source of all points.      |
| Distributor  | `Distributor` = 3 | Manages a whole branch.                           |
| Retailer     | `Retailer` = 5    | Manages only its immediate children.              |
| User         | `User` = 4        | End user. Cannot manage members.                  |

`2` was the old `Admin` role. It no longer exists; existing `Admin` rows were migrated to
Distributor. Do not reuse the value `2`.

## 2. Who can create whom

| Creator                | Can create                       |
| ---------------------- | -------------------------------- |
| SuperAdmin             | Distributor, Retailer, User      |
| Distributor            | Distributor, Retailer, User      |
| Retailer               | Retailer, User                   |
| User                   | nobody - has no member screens   |

Nobody can create a SuperAdmin. The creator becomes the new member's parent.

## 3. Who can see whom (this decides the Users screen **and** the Points screen)

| Viewer      | Sees                                                                        |
| ----------- | --------------------------------------------------------------------------- |
| SuperAdmin  | **Every** member, and which member each one belongs to (their parent)       |
| Distributor | Their **whole branch**: every Distributor / Retailer / User below them, at any depth |
| Retailer    | Only their **immediate** children (Retailers / Users they created)          |
| User        | Only themselves - the Users screen is not available to them                 |

Every viewer also sees **themselves** in the list, tagged "(You)".

A Retailer sees only one level down and never anyone above them. Example: A creates
retailer B, and B creates retailer C.

- A sees B, but **not** C.
- B sees C. B does not see A (nobody sees their upline) or anything above.

A Distributor, by contrast, sees B **and** C (and everything deeper): a whole branch.

The **same visible set** is used for both screens. Never build a separate rule for a
screen: reuse the single implementation (section 6).

## 4. What a viewer may do with the members they see

- **View / open** a member: only if visible. A member outside the visible set is
  reported as *not found*, not *forbidden*, so existence is not leaked.
- **Rename** a member: only if visible **and** not yourself (you can always edit your own
  name).
- **Change a password**: only the member **themselves** or a **SuperAdmin**. A
  Distributor or Retailer cannot change the password of the members below them. (Setting
  the first password when adding a member is fine.)
- **Activate / deactivate** a member: **SuperAdmin only**. Nobody, the SuperAdmin
  included, deactivates themselves.
- **Points**: allocate points, or (SuperAdmin only) reclaim them, only for **your own members** - the members you
  created directly, one level down, not anyone deeper in your branch - and never for
  yourself (the one exception is the SuperAdmin's own top-up, section 5). The Points
  screen's member dropdown lists only you and your own members. A member's **points
  history** is readable for any visible member (or yourself).
- A member's role and parent are fixed at creation.

## 4a. Member details (shop and identity proof)

Every member can carry **optional** details - none is required, when adding or later:

- **Shop**: shop name, shop address, city, pincode.
- **Identity proof**: ID type (Aadhaar, Voter ID, ...), ID number, and a **front** and a **back**
  photo of the card.

Rules:

- Who may **set or change** them: the member themselves, and any member who may edit them (section
  4). Whoever adds a member may fill them in at the same time.
- Who may **see** them: whoever can see the member (section 3). The identity photos follow the same
  rule - a member outside the viewer's view is reported as *not found*, so a Retailer never sees
  the photos of someone two levels down, and nobody sees their upline's.
- The identity photos are **never sent in a member list**; the list and the member carry only
  whether each photo exists (`HasIdFront`, `HasIdBack`), and a photo is fetched on its own
  (`GET /api/users/{id}/identity/{front|back}`), added or replaced with `PUT` (JPG, PNG or WebP, up
  to 5 MB) and removed with `DELETE`. They are stored apart from the member (`UserIdentities`) so
  they are only loaded when asked for.
- Updating a member: a detail that is not sent is left as it is; a blank one clears it.

## 5. Points

- Every member, the SuperAdmin included, has a real balance. **Allocating** points to a
  member **debits the allocator** and credits that member; **reclaiming** (a **SuperAdmin-only**
  action - nobody else can take points back) debits the
  member and credits the allocator. The allocator needs enough points to allocate, and
  the member needs enough to be reclaimed from. Points must be greater than zero. Every
  allocation and reclaim needs a **reason** (it is what both members' points history shows); only
  the SuperAdmin's own top-up may leave it out.
- The SuperAdmin is the only source of points: they can **top up their own balance**
  (Points screen: select yourself, "Add to my balance"). Nobody else can adjust their
  own points, and the SuperAdmin cannot deduct from their own balance.
- Total points in the system therefore only change by a SuperAdmin top-up; everything
  else is a transfer.
- Every card generation **debits** the generating member and **credits the SuperAdmin**
  (always the SuperAdmin, not the member's parent), so the SuperAdmin's balance is the
  running total of points spent on cards and points are easy to verify. Both entries are
  recorded pending when the card is generated and applied when the PDF is downloaded.
- A member needs enough points to generate a card. The SuperAdmin is never blocked by
  their balance when generating one: they pay and receive the same amount, so their own
  balance does not change.

## 6. Where it is implemented - keep it in one place

- Backend: `IDManager.Infrastructure/Members/MemberHierarchyService.cs` is the **only**
  place that decides who can create whom (`CanCreate`) and who can see whom
  (`GetVisibleMembersAsync`). `UserService` and `PointsService` call it; endpoints only
  gate by role and pass the caller's id. Do not re-implement these rules inline.
- Frontend: the Users and Points screens show whatever the API returns (they filter
  nothing themselves). The role dropdown when adding a member offers only what
  `UserRole.creatableRoles` allows.
- Endpoints that take a user id (`/users/{id}`, `/points/list`, `/points/increase`,
  `/points/decrease`, update, deactivate) must check the id against the caller's visible
  set. Role attributes alone are not enough.

## 7. Other permissions that follow from the roles

The Admin role is gone, so what Admin used to do is now SuperAdmin-only unless stated:

- Templates (create, edit, designer, sample PDF parsing): SuperAdmin only.
- Audit log: SuperAdmin only.
- Generate card: every role.
- Points screen: every role sees their own history; SuperAdmin / Distributor / Retailer
  also see the allocate/reclaim panel, and the history shown follows the member picked in its
  drop-down (the member's point details, headed with their name and balance); picking yourself, or
  nobody, shows your own. The history lists **completed** transactions only; a SuperAdmin has a
  switch to list the pending and failed ones too (marked, and enforced on the server - nobody else
  can ask for them).

## 8. Checklist for any member-related change

1. Which role is calling? Is the role allowed to do this at all (sections 2, 7)?
2. If the call names another member, is that member in the caller's visible set
   (section 3)? If it is the caller themselves, is that allowed (section 4)?
3. Did you go through `MemberHierarchyService` rather than writing a new rule?
4. Does the change add a role, a screen or a relationship? Then update this document.
5. Add or update tests in `IDManager.Tests/Members` for the rule you touched.
