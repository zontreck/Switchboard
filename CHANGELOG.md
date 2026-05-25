# 0.1.0

## ADD:

- [x] Liquid Glass Shading

## CHANGE:

- [x] Upon request, changed the ListTile in the EditAlter page for revealing the Alter's ID. This is now a small ElevatedButton.
- [x] (BREAKING) Rip out NBT usage from theming
  - [x] Core Issue: Dart2JS does not support Int64 on the web browser. So, as much as NBT would help with compact theme strings, we cannot use it, if we want to have a fully features Web interface for the app as well.
- [x] (BREAKING) Rip out NBT from FieldData
- [x] Convert FieldData editors to use a JSON codec, and base/inherited classes for serialization purposes.

# 0.1.0+0517261258

## ADD:

- [x] Implement the `/alters` endpoint in the app, so we can retrieve the list of alters.
- [x] Handler for `/robots.txt` which returns a static DENY ALL response.
- [x] `/cron` will now prune the audit log based on timestamp. Audit entries are deleted every 24 hours.
- [x] Adding fields DB table. This will be for data fields like `Description`, or `Fav Color`
- [x] CLI utility for downloading octocon avatar images before sunset of servers.
- [x] Inadvisable remember me function.
- [x] Implement `/fields` endpoint, returns all custom fields, and system fields.
- [x] Implement `/field/uuid` endpoint. Allows fetching one field, deleting fields, and creation of fields.
- [x] Implement Edit Field page
- [x] Add settings page and button for changing the current font.
- [x] Helper functions for storing, clearing, and retrieving the custom font.
- [x] New possible TODO item: `/assets` endpoint to store arbitrary files like fonts. Would enable sharing fonts in theme exports.
- [x] API now includes a `S2CLazyResponse` which all packets are going to be derived from. This is to standardize the serialization and deserialization processes. To reduce redundant actions. Also to make creation of new packets easier.

## FIX:

- [x] The `/alters` endpoint was improperly implemented
- [x] Bug in the app that would cause a endless loop (DDOS) once a access token expired or failed to refresh.
- [x] `/alter/{id}`: `PUT`, `DELETE` and `PATCH` methods have been updated to either return a full Alter, or set `data` to null when there is no alter to return.
- [x] Fixes Bug with API server SQL in PUT method.
- [x] To allow for multiple alters, new DB Migration added (0014), which addresses this bug.
- [x] Adjust the app description in `pubspec.yaml`
- [x] The migration was patched before going live for `0015`, The patch is because it would have failed, adding a NOT NULL with no default. We'll just handle for it being null in the alter endpoints.
- [x] Secured the `/user/` endpoint against SQL injection.
- [x] `/user` will now return a `fields` object in the response, containing all the user's fields.
- [x] Simplify development API for Color serialization and deserialization.
- [x] Fix handling of settings to now check for differences against the default settings.
- [x] Most or all pages now use the Bottom attribute of the AppBar to show the page's title and a divider line. This is instead of having those be part of the page itself.
- [x] Updated the version of LibAC. Moved a few helper functions over to the Library codebase as they are generic enough and useful for other projects.
- [x] Alter patch/put endpoints improperly set the binary data for Fields

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
