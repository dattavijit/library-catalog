# Library Catalog (RAP / Fiori Elements) — design record
2026-08-18 · grilled with Avi

## Goal
Build a Library Catalog OData V4 service on SAP system A4H using RAP (RESTful ABAP
Programming Model), primarily to learn Fiori Elements. Success looks like: a working
Fiori Elements List Report + Object Page app on Book, with create/edit/delete through a
managed RAP scenario with draft, Author and Genre selectable via value help, everything
built in a dedicated local package.

The original brief described this as "perfect for learning many-to-many relationships."
That framing was explicitly dropped during the interview — the model that got built is
single-author, single-genre, no join tables.

## Decisions

- **No many-to-many.** Book has exactly one Author and one Genre — no Book-Author or
  Book-Genre join tables.
  - Why: Avi's explicit call, made twice, overriding the original "many-to-many" framing
    of the exercise.
  - Rejected: join tables for multi-author / multi-genre books — the thing that would
    have actually delivered on the original "learn many-to-many" framing.
  - Reversibility: expensive once data and an app exist — deliberately deferred, not an
    oversight.

- **OData V4 via RAP**, not classic Gateway/SEGW.
  - Why: matches the actual goal (learning Fiori Elements the current, standard way) and
    matches how Avi already works on A4H.
  - Rejected: OData V2 through the classic Service Builder.
  - Reversibility: one-way door — key strategy, draft handling, and CDS annotations all
    follow from this choice.

- **One Fiori Elements app, on Book only.** Author and Genre are read-only CDS lookup
  views feeding value help — no behavior definition, no app of their own, for now.
  - Why: keeps the first build focused; Author/Genre don't need full CRUD yet.
  - Rejected: three separate managed apps (Book, Author, Genre) in this pass.
  - Reversibility: moderate — adding behavior definitions + service bindings for
    Author/Genre later doesn't require touching Book.

- **Book's technical key is a generated UUID (late numbering).** ISBN is a regular field
  with a uniqueness check, not the OData key.
  - Why: matches SAP's own RAP tutorial pattern; avoids ISBN format/uniqueness edge cases
    (10 vs 13 digit, missing ISBNs) blocking the draft-create flow; smoother than early
    numbering for a managed+draft scenario.
  - Rejected: ISBN as an early-numbered business key.
  - Reversibility: one-way door in practice — changing the OData key after the data model,
    UI, and any consumers exist means a rebuild.

- **Managed RAP scenario with draft enabled.**
  - Why: the fuller, more representative Fiori Elements experience (Edit button,
    unsaved-changes isolation, resume-draft dialog) — matches what most real SAP apps and
    tutorials use, and the goal here is specifically to learn Fiori Elements patterns.
  - Rejected: managed without draft (direct save) — simpler, but a smaller slice of what
    RAP/Fiori Elements actually offer.
  - Reversibility: expensive to retrofit — draft table and draft actions are foundational
    to the behavior definition.

- **Author and Genre are seeded by a throwaway ABAP program**, not through an app.
  - Why: with no app for them, something has to populate the tables before Book creation
    is even testable.
  - Rejected: SM30/SE16 maintenance view now — deferred, not rejected outright.
  - Reversibility: cheap — the seed program is disposable and doesn't constrain a later
    proper maintenance app.

- **Value help style differs by entity.** Genre = simple dropdown (small, essentially
  fixed list). Author = full F4 search dialog with type-ahead (expected to grow over
  time).
  - Why: matches the actual expected data volume and growth pattern for each.
  - Rejected: the same pattern for both, for consistency — rejected because it doesn't
    fit Author's growth.
  - Reversibility: cheap — annotation-level change.

- **New local package `$LIBRARY_CATALOG`** holds everything. Doesn't exist yet — creating
  it is the first build step.
  - Why: Avi confirmed staying local to A4H for now; the `$` prefix marks it
    non-transportable, consistent with that.
  - Rejected: a transportable package — not needed since there's nowhere to transport to
    yet.
  - Reversibility: cheap to redo under a different package later, before real dependents
    exist.

- **RAP availability on A4H — resolved, not a risk.** Avi confirmed RAP objects already
  exist and work on A4H. The `✗ rap` flag surfaced early by the VSP connector's feature
  probe was a false negative: the probe uses an HTTP OPTIONS request against
  `/sap/bc/adt/ddic/ddl/sources`, which this system's ADT/ICF configuration rejects with
  a 400 ("method OPTIONS not supported") — a broken probe method, not a real absence of
  RAP support. `transport` failed identically for the same reason.

## Open risks

- **ISBN validation logic** (format, uniqueness) isn't designed yet — deferred to build
  time. Owner: Avi. Decide-by: before implementing the Book behavior definition's field
  validation for ISBN.
- **Object naming convention** (CDS interface/consumption view names, behavior
  definition, service definition/binding names) isn't decided. Owner: Avi. Decide-by:
  before creating the first CDS view.

## Assumptions

- A4H is a personal/sandbox-style system (client 001, user DEVELOPER), not a shared
  landscape with other consumers depending on these objects. This is why questions on
  transport sequencing, authorizations, cutover, and commercials weren't raised — they'd
  need a separate pass if this system is actually shared with a team.
- Author and Genre are modeled as independent reference data (CDS association, not
  composition, from Book) — implied by "single author/genre, no join tables, no lifecycle
  ownership," not separately interrogated since the data semantics already forced it.
- No requirement for concurrent multi-user edit-conflict handling beyond what managed RAP
  with draft gives by default.
- The field list is exactly as originally specified: Author (Name, Nationality), Book
  (Title, PublishDate, ISBN), Genre (Description). No copies-available, cover image, or
  similar fields. Not deeply grilled — cheap to extend later without touching the
  architecture.

## Out of scope

- Many-to-many modeling (Book-Author, Book-Genre join tables) — the original framing of
  the exercise, explicitly dropped by Avi's decision.
- CRUD apps for Author and Genre — deferred to a later pass.
- Transport to any other system.
- Authorization/PFCG role design — appropriate to skip for a personal learning system,
  but must be revisited before this goes anywhere shared.
