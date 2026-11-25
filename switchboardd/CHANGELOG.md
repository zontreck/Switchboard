# 0.0.14

- Add response header: `X-Authorization-Expired`

# 0.0.13

- Migrate `/auth/check`

# 0.0.10

- Patch a error which occurred in the uuid impl

# 0.0.9

- Migrate over `/auth/login`
- Access tokens table now has a migration to update it. It no longer will store values that get encoded into the actual token.
