# 0.3.1

## ADD:

- [x] Implement extremely basic discord connectivity for the bot

## CHANGE:

- [x] Bot is now built using `bin/bot.dart`, as `server.dart` has been renamed and repurposed. The original purpose, was that this dart file would be the backend server, but we went with PHP for that instead.

# 0.3.1+0705260030

## ADD:

- [x] Missing Proxy info to alters
- [x] Migration of proxy information

# 0.3.0+0704261942

## ADD:

- [x] Adds a `Delete Alter` button to the edit alter page
- [x] Delete Alter now has a confirmation dialog!
- [x] Network Interface binding for delete alter `NetworkInterface.deleteAlter(alterId)`
- [x] Long press menu with fronting options and a delete option + confirmation dialog
- [x] Roadmap: 1.0 Release will include Encryption of the database.Not sure yet what this will look like implementation-wise.
- [x] API bindings for interacting with folders on the server.
  - [x] Patch - LazyResponse
  - [x] DELETE - LazyResponse
  - [x] PUT - LazyResponse
  - [x] POST - FolderResponse
  - [x] GET - FoldersResponse
- [x] Migration for tags

## CHANGE:

- [x] Add spacing to the edit alter page between the Copy Avatar Permalink button and the Show Alter ID button.
- [x] Update all icons to use new Logo from The Asterism Theatre
- [x] HARD RESET OF DATABASE: All migrations have been squashed down, indexes redone.
- [x] `NetworkInterface.putNewUser` will now return a `S2CLazyResponse` instead of a `S2CUserResponse`. This is because on registration, it does not return the full Fields list like a UserResponse would.
- [x] Rip out UUID from `Octocon Format`, replacing with Strings.
- [x] Move all instances of File Picker to a dedicated handler, fixing the Web App.

# 0.2.0+0630262333

## CHANGE:

- [x] PHP Backend: Fixes all alters wrongly appearing as fronting.
- [x] AS: Fix the fronting history and status. Only the currently active fronter will be highlighted, not all instances of the same alter.

# 0.2.0+0630260842

## CHANGE:

- [x] PHP backend: `/alters` will now include in the json, the same header values that get set. This is to resolve a bug with the WebApp specifically.
- [x] BREAKING: PHP backend: `/fronting` will now no longer expect request body for a full history request. Full history requests now get pulled from the request parameters. This is due to a bug in the WebApp.
  - This change breaks all public previous versions of the app until an update can go live.
- [x] Fix remember me functionality.

# 0.2.0+0629261800

## ADD:

- [x] New endpoint: `/wipe`. This endpoint is designed to erase all user data. It's only intended to ever be called from a Import function, or somewhere that makes it VERY clear that the action is irreversible.
- [x] Begin to add the automated Octocon data migration functions
- [x] New system field: `Pronouns`. This is just a basic plain text field. Migration ID `0020`
- [x] Add new migration for backend: `0018`, which addresses a bug in which the database would only allow one avatar to be posted for a user at a time. This attempts to address that issue, by making both user and image ID unique keys.
- [x] Start implementing the feedback database table (Migration `0021`, `0022`)
- [x] Add status column to the feedback table (`0022`)
- [x] Add a new table for comments on feedback items (`0022`)
- [x] Adds initial fronting table (`0023`)
- [x] Implements the `/fronting` endpoint.
  - [x] GET will retrieve one of two things. If the parameter json parameters `history` is set to TRUE, it will return all fronting history, including current fronters. Otherwise it only returns current fronters.
  - [x] POST will add someone to front.
  - [x] PUT will insert a StartTime and Endtime as specified by the payload. This is primarily to be used by Import functions.
  - [x] DELETE will delete the fronting object.
  - [x] PATCH will remove someone from front, updating only the EndTime value.
- [x] API bindings for the `NetworkInterface` to interact with the `/fronting` endpoint.
- [x] Added a glow effect and additional spacing for active fronters in the primary alters list
- [x] Made it possible to swipe to "dismiss" alters. This will be used instead to set front, or remove from front.
- [x] Implement set front gesture
- [x] Glow settings!
  - [x] Added Pride Flags as color presets
  - [x] REMOVED: Herobrine.
- [x] Add boolean field type
- [x] Website code, due to google sites being a PITA
- [x] Font for website: Unitblock CC0 : https://ggbot.itch.io/unitblock-font
- [x] Button on alter page to copy permanent profile picture link.

## CHANGE:

- [x] Update the text on onboarding phase 0 (Ad opt in request page)
- [x] Agreeing to ads on the Onboarding page will now enable Ads on navigation by default. By default, this is every 4 page changes.
- [x] Fix a bug in the server's SQL tables, where a image binary could potentially be too long to commit to the database.
- [x] Automatically migrate images being saved with `Set URL` to the `/avatar/` endpoint.
- [x] Fixes the anti-cachebusting feature that was preventing image updates on the edit alter page
- [x] Fully fixes the image bug with migration `0019`.
- [x] Alter background color is now pulled from the alter's system color field data.
- [x] Migration system now uses a state system, so it can easily change behavior and page contents.
- [x] Main website is no longer hosted on Google Sites, prototyping is still done using the visual designer on Sites however.
- [x] Completely remove UUID usage. At least for now.
  - This was causing a massive issue with Int64 in DartJS on the web. It could not be easily resolved, so for the moment we've just ripped out all instances of UUID. We may bring back UUID usage, once we find a way to create a web safe UUID.

# 0.1.0+0617260921

## ADD:

- [x] Liquid Glass Shading
  - [x] Not everything will have liquid glass right away. We'll get stuff converted over time.
- [x] API for type correcting decoded Json to reduce chances of weird and strange errors being thrown. (Attempt to fix Error when loading Alter List)
- [x] Date field type
- [x] Ability to upload and clear alter profile images.
- [x] Return the image from the `avatar` database when it does exist. This code did not previously exist.
- [x] Begin to add a onboarding process
- [x] Adds optional Ads to the app with a Opt Out feature, which is the default.
- [x] Links to Privacy Policy, TOS, and Patreon directly on the Sandwich menu
- [x] Toggleable Banner ad on the main page only for now. This is meant to gather some feedback on placement, and the optional nature of the ads.
- [x] Number field type
- [x] Feedback HUB for users to send feedback, bug reports, or feature requests.
  - [x] This feature will have some integration with Patreon or Ko-Fi, where supporters will be able to receive responses from the development team directly, to see the status on their feedback ticket.
- [x] Update the API implementation sheet.
  - [x] We're now going to be planning to have several new endpoints. All existing ones have been marked as verified if they were not already. New endpoints are for the following: `fronting`, `feedback`

## CHANGE:

- [x] Upon request, changed the ListTile in the EditAlter page for revealing the Alter's ID. This is now a small ElevatedButton.
- [x] (BREAKING) Rip out NBT usage from theming
  - [x] Core Issue: Dart2JS does not support Int64 on the web browser. So, as much as NBT would help with compact theme strings, we cannot use it, if we want to have a fully featured Web interface for the app as well.
  - [x] May go back to NBT once the iOS app can be compiled.
- [x] (BREAKING) Rip out NBT from FieldData
- [x] Convert FieldData editors to use a JSON codec, and base/inherited classes for serialization purposes.
- [x] NBT -> Json
  - [x] Internally, if data was previously NBT, it will be reset to defaults. This is anything from FieldData in Alters to the App Settings. Themes will also need to be recreated/exported using the new serializer.
- [x] Fixed the response format for the `/avatar` endpoints, as they were not returning the `reason` entry.
- [x] Fix the DELETE operation on `/avatar` as it was not using the correct Column name when a image did exist.
- [x] Fix a small oversight with `/avatar` `POST` which would result in the Avatar field not ever getting properly updated. This would cause a disconnect with the Edit page, which called the `Alter#makeAvatarURL` method, and supports custom URLs.
- [x] Fixes image constraints, where a image with an alpha'd top or bottom would be cropped.
- [x] Fixes image caching without the use of cachebusting. Saving or updating image data will now flush the cache. When the Login screen loads, it will also flush the caches now.
- [x] Part way through development, around version code 0616261000, we made the decision to remove banner ads, and instead use Interstitial ads, but give the user control over the frequency and trigger settings.
- [x] Update CI/CD scripts to point to AstaraCreations as the org owner for Switchboard.
- [x] Includes AD_ID permission in the manifest file now.

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
