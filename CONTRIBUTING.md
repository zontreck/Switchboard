# Contribution Guidelines

1. You must know and understand your code.
2. Test your code before sending it as a contribution. Drafts are fine, but make sure tests are performed.
3. AI use is highly discouraged for code contributions. You can use it if you need a starting point, or a second pair of eyes looking over the code. Do NOT use AI for the entire coding process. Vibe coding is not allowed for this codebase.
4. Testsuites are encouraged to go along with contributions. Not all functions in the app have their own tests yet. We aim to change that.
5. Ownership: When contributing to Switchboard, you acknowledge that you do not retain IP rights over your own code or contributions. All assets once committed and/or accepted into the project become the property of Switchboard. Switchboard does contain CC0 assets, like fonts, for these and all future CC0 contributions, we respect that designation. CC0 will remain CC0, and all unlicensed code/assets become GPLv3+ when contributed.
6. Our versioning is `Major.Minor.Patch+DateTime`, please stick to it until further notice.

# Branches

We use a few different branches internally as of 0.4.0.

| Branch  | Description                                                                                                                                                                                                                    |
| ------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| master  | The main production branch                                                                                                                                                                                                     |
| develop | The development branch. This is considered unstable most of the time, as things might break. ALL code contributions MUST target this branch. Only releases or fully tested code will ever be merged over to the master branch. |
