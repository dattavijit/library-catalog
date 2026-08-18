#!/usr/bin/env bash
# Creates the Library Catalog tracer-bullet tickets as GitHub issues on
# dattavijit/library-catalog, in dependency order, with blocking links.
#
# Run this on a machine where `gh` is installed and authenticated
# (check with: gh auth status). Requires push access to the repo.
#
# Usage: ./create-github-issues.sh
#   Optional: LABEL=some-label ./create-github-issues.sh

set -euo pipefail

REPO="dattavijit/library-catalog"
LABEL="${LABEL:-}"

if ! command -v gh >/dev/null 2>&1; then
  echo "gh CLI not found. Install it first: https://cli.github.com" >&2
  exit 1
fi

if ! gh auth status >/dev/null 2>&1; then
  echo "gh is not authenticated. Run: gh auth login" >&2
  exit 1
fi

# Native --blocked-by / --parent support landed in gh 2.94.0.
GH_VERSION="$(gh --version | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1)"
ver_ge() { [ "$(printf '%s\n%s\n' "$2" "$1" | sort -V | head -1)" = "$2" ]; }
USE_NATIVE=false
if ver_ge "$GH_VERSION" "2.94.0"; then
  USE_NATIVE=true
  echo "gh $GH_VERSION supports native blocking links — using --blocked-by."
else
  echo "gh $GH_VERSION predates native blocking links (need 2.94.0+) — falling back to a 'Blocked by:' text line in each issue body."
fi

LABEL_ARGS=()
if [ -n "$LABEL" ]; then
  LABEL_ARGS=(--label "$LABEL")
fi

create_issue() {
  local title="$1" body="$2" blocked_by_number="${3:-}"
  local args=(--repo "$REPO" --title "$title" "${LABEL_ARGS[@]}")

  if [ -n "$blocked_by_number" ]; then
    if [ "$USE_NATIVE" = true ]; then
      args+=(--blocked-by "$blocked_by_number")
    else
      body="**Blocked by:** #${blocked_by_number}

${body}"
    fi
  else
    if [ "$USE_NATIVE" = false ]; then
      body="**Blocked by:** _nothing — ready to start_

${body}"
    fi
  fi

  local url
  url="$(gh issue create "${args[@]}" --body "$body")"
  echo "$url"
  echo "${url##*/}"
}

echo "Creating ticket 1/4: Reference data foundation"
OUT1="$(create_issue "Reference data foundation" \
"## What to build

Package \`\$LIBRARY_CATALOG\`, Author and Genre DB tables, a throwaway ABAP seed program to populate them, and read-only CDS interface + consumption views for both. Also the moment to settle the still-open object naming convention (CDS interface/consumption view names, behavior definition, service definition/binding names), since this is where the first CDS views get created.

## Acceptance criteria

- [ ] Package \`\$LIBRARY_CATALOG\` exists in A4H
- [ ] Author table (Name, Nationality) and Genre table (Description) exist, with generated UUID keys
- [ ] Seed program populates both tables with sample data
- [ ] Read-only CDS interface + consumption views exist for Author and Genre
- [ ] Seeded data is visible via ADT Data Preview on both consumption views
- [ ] Object naming convention decided and applied")"
NUM1="$(echo "$OUT1" | tail -1)"

echo "Creating ticket 2/4: Book — read-only tracer bullet"
OUT2="$(create_issue "Book — read-only tracer bullet" \
"## What to build

Book DB table (generated UUID key, Title, PublishDate, ISBN, associations to Author and Genre), CDS interface + consumption views, a managed RAP behavior definition with draft enabled from the start (retrofitting draft later is expensive, so it's built in now even though create isn't wired up yet), a service definition and binding, and a bare Fiori Elements List Report + Object Page showing Book data.

## Acceptance criteria

- [ ] Book DB table exists with UUID key and the four fields, plus FK-style references to Author and Genre
- [ ] CDS interface + consumption views expose Book with resolved Author and Genre
- [ ] Behavior definition is managed, with draft enabled, standard operations set to read/display for now
- [ ] Service definition + binding published for the Book entity
- [ ] Fiori Elements List Report + Object Page runs and shows seeded Book data, including Author and Genre
- [ ] This is demoable end to end: open the app, see the list, open one book, see its details" \
"$NUM1")"
NUM2="$(echo "$OUT2" | tail -1)"

echo "Creating ticket 3/4: Book create / edit / delete via draft"
OUT3="$(create_issue "Book create / edit / delete via draft" \
"## What to build

Wire up Create, Update, and Delete on the behavior definition from #${NUM2}, plus the matching Fiori Elements UI actions (New, Save, Edit, Delete). Resolve the still-open ISBN validation logic (format and uniqueness) as part of this — it was explicitly deferred to 'before implementing the Book behavior definition's field validation for ISBN,' which is now.

## Acceptance criteria

- [ ] Create, Update, Delete standard operations implemented in the behavior definition
- [ ] ISBN format and uniqueness validation implemented and triggers a user-visible error on violation
- [ ] Fiori Elements app: New button creates a draft, Save activates it, Edit resumes editing, Delete removes a book
- [ ] Draft indicator and unsaved-changes behavior work as expected (resume-draft dialog, discard)
- [ ] This is demoable end to end: create a new book, save it, edit it, delete it, all through the running app" \
"$NUM2")"
NUM3="$(echo "$OUT3" | tail -1)"

echo "Creating ticket 4/4: Author and Genre value help"
create_issue "Author and Genre value help" \
"## What to build

Value help annotations on Book's Author and Genre fields — a full F4 search dialog with type-ahead for Author (expected to grow over time), a simple dropdown for Genre (small, essentially fixed list) — wired into the Create and Edit forms.

## Acceptance criteria

- [ ] Genre field on Book's create/edit form shows a dropdown sourced from the Genre CDS view
- [ ] Author field on Book's create/edit form shows a full search dialog with type-ahead, sourced from the Author CDS view
- [ ] Both value helps reflect the data seeded in ticket 1
- [ ] This is demoable end to end: start creating or editing a book, pick a Genre from the dropdown and an Author from the search dialog" \
"$NUM3" >/dev/null

echo "Done — 4 issues created on $REPO in dependency order."
