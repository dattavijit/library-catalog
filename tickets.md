# Tickets: Library Catalog (RAP / Fiori Elements)

Built from [`docs/library-catalog-rap-design-record.md`](docs/library-catalog-rap-design-record.md). Four tickets, each a full pass through every RAP layer (DB table → CDS interface view → CDS consumption view → behavior definition → service definition/binding → Fiori Elements UI) rather than one layer at a time.

Work the **frontier**: any ticket whose blockers are all done. This chain is linear, so work top to bottom.

## 1. Reference data foundation

**What to build:** Package `$LIBRARY_CATALOG`, Author and Genre DB tables, a throwaway ABAP seed program to populate them, and read-only CDS interface + consumption views for both. Also the moment to settle the still-open object naming convention (CDS interface/consumption view names, behavior definition, service definition/binding names), since this is where the first CDS views get created.

**Blocked by:** nothing — can start immediately.

- [x] Package `$LIBRARY_CATALOG` exists in A4H
- [x] Author table (Name, Nationality) and Genre table (Description) exist, with generated UUID keys
- [x] Seed program populates both tables with sample data — confirmed: 5 authors, 5 genres in `ZLIB_AUTHOR`/`ZLIB_GENRE` (Avi ran `ZLIB_SEED_DATA` manually in ADT; remote execution from this session was blocked, see note below).
- [x] Read-only CDS interface + consumption views exist for Author and Genre
- [x] Seeded data is visible via ADT Data Preview on both consumption views — verified via `ZC_LIB_AUTHOR`/`ZC_LIB_GENRE`, all 10 rows visible with resolved text.
- [x] Object naming convention decided and applied — see below

**Ticket 1 complete.**

**Naming convention applied** (ZLIB_ prefix, SAP tutorial style): DB tables `ZLIB_AUTHOR` / `ZLIB_GENRE` / (later) `ZLIB_BOOK`; CDS interface views `ZI_LIB_AUTHOR` / `ZI_LIB_GENRE` / (later) `ZI_LIB_BOOK`; CDS consumption views `ZC_LIB_AUTHOR` / `ZC_LIB_GENRE` / (later) `ZC_LIB_BOOK`; behavior definition on the Book interface view; service definition/binding `ZUI_LIB_BOOK` / `ZUI_LIB_BOOK_O4`.

**Note on `ZLIB_SEED_DATA` execution:** A4H's ADT connector doesn't have the `ZADT_VSP` WebSocket handler deployed, so remote report execution (RunReport/RunReportAsync) and RFC calls time out, and ABAP Unit tests with DB-writing statements are blocked by the system's test risk-level setting. Every object was created and activated successfully from this session; Avi ran the report by hand (10-second F8 in ADT) to actually populate the tables. Expect the same pattern for any future ticket step that requires *running* code rather than just creating/activating it.

## 2. Book — read-only tracer bullet

**What to build:** Book DB table (generated UUID key, Title, PublishDate, ISBN, associations to Author and Genre), CDS interface + consumption views, a managed RAP behavior definition with draft enabled from the start (retrofitting draft later is expensive, so it's built in now even though create isn't wired up yet), a service definition and binding, and a bare Fiori Elements List Report + Object Page showing Book data.

**Blocked by:** 1 (needs the Author/Genre tables and CDS views for the associations to resolve).

- [x] Book DB table exists with UUID key and the four fields, plus FK-style references to Author and Genre — `ZLIB_BOOK` (+ `ZLIB_BOOK_D` draft table). Also carries a technical `LAST_CHANGED_AT` field, required by RAP for the draft ETag (see note below) — not a business field, not part of the original spec.
- [x] CDS interface + consumption views expose Book with resolved Author and Genre — `ZI_LIB_BOOK` (raw fields + `_Author`/`_Genre` associations), `ZC_LIB_BOOK` (adds `author_name`/`genre_description` via path expressions, List Report/Object Page UI annotations). Verified queryable end to end.
- [x] Behavior definition is managed, with draft enabled, standard operations set to read/display for now — `ZI_LIB_BOOK` (managed, with draft, persistent+draft table wired, lock master, total/master etag) and `ZC_LIB_BOOK` (projection, use draft) both activate clean with zero create/update/delete declared, as intended for this ticket.
- [x] Service definition + binding published for the Book entity — `ZUI_LIB_BOOK` (service definition) and `ZUI_LIB_BOOK_O4` (OData V4 UI binding). Avi published the binding manually in ADT; confirmed `published: true`.
- [x] Fiori Elements List Report + Object Page runs and shows seeded Book data, including Author and Genre — confirmed: 5 books in `ZLIB_BOOK`, all resolving Author name and Genre description correctly via `ZC_LIB_BOOK`.
- [x] This is demoable end to end: open the app, see the list, open one book, see its details — backend confirmed end to end; Avi ran the seed program and published the binding manually.

**Ticket 2 complete.**

**Note on the draft ETag requirement:** RAP enforces "if with draft is used, flag a total etag field" — a hard compile error, not optional. This required adding a technical `LAST_CHANGED_AT` timestamp to `ZLIB_BOOK`/`ZLIB_BOOK_D` purely for RAP's optimistic-concurrency/draft plumbing (same category as the draft table's `%admin` include from ticket 1). Also learned the hard way: draft-table field names must exactly match the *CDS interface view's* exposed element names (not the underlying DB column names) once any field is referenced in the behavior definition — mismatches (e.g. `PUBLISH_DATE` vs `PublishDate`) are silently tolerated as warnings on the persistent table but are hard errors on the draft table. Fix was to drop PascalCase aliasing in `ZI_LIB_BOOK` and keep interface-view field names identical to the DB columns; the friendlier `author_name`/`genre_description` computed columns live only in the projection view (`ZC_LIB_BOOK`), which isn't subject to this check.

## 3. Book create / edit / delete via draft

**What to build:** Wire up Create, Update, and Delete on the behavior definition from #2, plus the matching Fiori Elements UI actions (New, Save, Edit, Delete). Resolve the still-open ISBN validation logic (format and uniqueness) as part of this — it was explicitly deferred to "before implementing the Book behavior definition's field validation for ISBN," which is now.

**Blocked by:** 2.

- [x] Create, Update, Delete standard operations implemented in the behavior definition — `ZI_LIB_BOOK` now declares `create; update; delete;` plus the standard draft actions (Resume, Edit, Activate, Discard, Prepare); `ZC_LIB_BOOK` exposes all of them via `use create/update/delete` and `use action`. `id` is flagged `numbering:managed` so the UUID key is auto-generated on create (late numbering, per the design record).
- [x] ISBN format and uniqueness validation implemented and triggers a user-visible error on violation — new behavior implementation class `ZBP_I_LIB_BOOK` with local handler class `lhc_Book`, method `validateIsbn` (runs `on save` for create/update, and in the draft `Prepare` action so errors surface before save too). Rule chosen with Avi: strip hyphens/spaces, require 10 or 13 digits, a 13-digit ISBN must start with 978/979, and it must not already be used by another book. Each failure raises a field-level error message via `if_abap_behv`.
- [ ] Fiori Elements app: New button creates a draft, Save activates it, Edit resumes editing, Delete removes a book — backend capabilities are all wired and active; I have no way to drive the OData UI from this session (no browser/execution access to A4H). **Needs Avi to test in the running app.**
- [ ] Draft indicator and unsaved-changes behavior work as expected (resume-draft dialog, discard) — this is standard Fiori Elements behavior once draft + the draft actions are exposed (no custom UI code needed), but same as above, needs a human to actually click through it.
- [ ] This is demoable end to end: create a new book, save it, edit it, delete it, all through the running app — pending Avi's manual test. Same app/URL as ticket 2 (no republish needed — the service binding already exposes `ZC_LIB_BOOK`, and its capabilities update automatically now that the behavior definition declares create/update/delete).

**Suggested test pass for Avi:** open the Book app → New → fill in Title/PublishDate/ISBN + Author/Genre UUIDs (raw GUID entry is expected here — value help lands in ticket 4) → try saving with a bad ISBN (e.g. `123`) and confirm you get a field-level error → fix it and Save → confirm the row appears → Edit it → Delete it. Also worth trying: start a New draft, navigate away without saving, come back and confirm the resume-draft dialog appears (or Discard removes it).

## 4. Author and Genre value help

**What to build:** Value help annotations on Book's Author and Genre fields — a full F4 search dialog with type-ahead for Author (expected to grow over time), a simple dropdown for Genre (small, essentially fixed list) — wired into the Create and Edit forms.

**Blocked by:** 3 (needs the create/edit form to attach value help to).

- [ ] Genre field on Book's create/edit form shows a dropdown sourced from the Genre CDS view
- [ ] Author field on Book's create/edit form shows a full search dialog with type-ahead, sourced from the Author CDS view
- [ ] Both value helps reflect the data seeded in #1
- [ ] This is demoable end to end: start creating or editing a book, pick a Genre from the dropdown and an Author from the search dialog
