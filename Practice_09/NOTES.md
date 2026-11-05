# Practice 9 — Put It High, Subscribe Low

## Level 1 — lifting state up
The `lifted` Git commit contains the initial implementation. `Shell` owns the list; parameters go down and callbacks go up.
Adding `total` to the badge required changing the `CartBadge` constructor and the call site in `BooksScreen` (2 source files; 1 explicit constructor declaration). `AppBar` and `actions` are Flutter APIs, not custom constructors to modify.

## Rebuild measurements
**Measure these on your own device before submission; do not invent values.**
- Level 1, one Add: `BooksScreen build` = ___; `row ...` lines = ___ (up to six visible rows).
- Level 4, 3 increments with `watch`: `badge build` = ___ (expected three when badge is mounted and subscribed).
- Level 4, 3 increments with `select`: `badge build` = ___ (expected zero because distinct-book count is unchanged).
- Removing a book with `select`: `badge build` = ___ (expected one if badge is mounted).

Note: the Books screen is normally below the Cart route; to measure badge increments while it is mounted, use DevTools and verify the lifecycle of the route/element. Actual counters can vary with navigation and development tooling.

## Level 3 — deliberately wrong provider verbs
- `watch` in `onPressed`: Provider asserts that listening outside the widget build phase is invalid. Fix: `read` in callback.
- `read` inside `build`: does not register a dependency; the badge may stay stale. In debug builds Provider can assert that `read` was used inside build.

Record the **exact messages from your installed Provider version** after reproducing the errors: ___

## Where does it live?
- Cart: **provided** — shared between two routes.
- Search text: **ephemeral** — used only in BooksScreen.
- Total expanded/collapsed: **ephemeral** — local to CartScreen (if this feature is added).
- Theme mode: **provided** — multiple routes need the same app-wide setting (if a switch is added).

## Separation of concerns
`Cart` is a ChangeNotifier model with no BuildContext or Material UI imports. The model enforces no duplicates, quantities, totals, and change notifications. Widgets own SnackBars, navigation and confirmation dialogs.

## Final verification checklist
- [ ] Run `flutter pub get` and `flutter run`
- [ ] Run `dart format .`
- [ ] Run `flutter analyze` — confirm `No issues found!`
- [ ] Record actual rebuild counts and provider error messages above
- [ ] Capture `screenshot_books.png` showing 2 books added and badge 2
- [ ] Capture `screenshot_cart.png` showing quantity 2 and correct total
- [ ] Commit screenshots and NOTES.md to GitHub
