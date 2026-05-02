# 0.1.0+042026

## ADD:

- [x] Implement the `/alters` endpoint in the app, so we can retrieve the list of alters.
- [x] Handler for `/robots.txt` which returns a static DENY ALL response.

## FIX:

- [x] The `/alters` endpoint was improperly implemented
- [x] Bug in the app that would cause a endless loop (DDOS) once a access token expired or failed to refresh.
- [x] `/alter/{id}`: `PUT`, `DELETE` and `PATCH` methods have been updated to either return a full Alter, or set `data` to null when there is no alter to return.
- [x] Fixes Bug with API server SQL in PUT method.
- [x] To allow for multiple alters, new DB Migration added (0014), which addresses this bug.
- [x] Adjust the app description in `pubspec.yaml`

# 0.1.0+0419262121

## ADD:

- [x] Color preference settings for the Selected bottom navigation bar indicator.
- [x] Color preference for unselected navigator indicator
- [x] Ability to import app settings
- [x] Ability to reset to default theme

## REMOVE:

- [x] Leftover debug code

# 0.1.0+0419261700

## ADD:

- [x] Implemented `/alters` endpoint
- [x] Start implementing the alters management page, post-login screen.
- [x] App settings screen, with customization options.
- [x] App settings export capability
- [x] Ability to preview what the theme would look like

## CHANGE/FIX:

- [x] Fix the SQL format used for queries in `/alters`
- [x] Fix the images in `/images` or `/avatar` so that the Alpha channel is preserved.

# 0.1.0+0419261054

## ADD:

- [x] Implement the Avatars endpoint on backend
- [x] Added the Avatars table to database
- [x] Added a placeholder Avatar image to be returned when not found, or when not yet set.
  - [x] Contributed by The Asterism Theatre

# 0.1.0+0418261248

## ADD:

- [x] Implement account login.
- [x] Added Privacy Policy Page
- [x] Added package for rendering markdown
- [x] Implement API bindings for checking auth, and refreshing.

## CHANGE:

- [x] Cleaned up code in Login Page regarding the Version number display in the DrawerHeader. It will now use a FutureBuilder to avoid possible crashes.

## REMOVE:

- [x] Removed LOGIN from the sandwich menu. (Redundant)

# 0.1.041826+0916

## CHANGE:

- [x] Moved Pages into their own dart code files, and moved those files into a new pages folder.

# All Previous Versions

## Initial Releases

- [x] Got UI Partially implemented
- [x] Got Application Icon created (The artwork is made by The Asterism Theatre (F: Jordan))
- [x] Backend Server networking created
- [x] Established a standard network protocol for communication.
