## v0.1.1 2024-03-27

- Add Client#open_timeout=
- Add Resource#modified?

## v0.1.0 2022-12-05

- Reduced data transferred for regular queries
- Fixed support for more modern Ruby (3+)
- Fixed error handling and changes for newer Passwordstate versions
- Improved pretty printing when debugging

## v0.0.4 2019-10-23

- Fixed a client request issue due to a rubocop change

## v0.0.3 2019-10-23

- Added method to check if resource types are available
- Added `_bare: true` flag on resource getter to create a bare object for
  method calls
- Fixed handling of host objects
- Further improved exception handling

## v0.0.2 2018-08-14

- Added title and full_path fields to the appropriate resources - almost every
  resource should now have an obvious human-readable name
- Fixed password searching in password lists
- Improved exception handling

## v0.0.1 2018-07-31

- Initial release
