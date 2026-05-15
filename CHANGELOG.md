# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [0.9.0] - 2026-05-15

### Fixed
- `ActivityLogFetchable`: `apply_activity_type_filter` now uses Arel (`arel_table[:key].matches`) instead of raw SQL with MySQL-specific backtick quoting, making the gem database-agnostic (SQLite, PostgreSQL, MySQL)

## [0.8.0] - 2026-04-27

### Added
- `install_generator`: initializer template now includes a custom `Ahoy::Store` that filters events based on `ActionTrace.configuration.excluded_controllers` and `excluded_actions`, preventing excluded controllers/actions from being recorded as Ahoy events

## [0.7.0] - 2026-04-27

### Changed
- `install_generator`: removed `inject_body_tracking_attributes` — the generator no longer patches `app/views/layouts/application.html.erb` automatically. Add the `data-track-*` attributes to your `<body>` tag manually (instructions printed in the post-install message and documented in the README)

### Added
- POST_INSTALL message now includes the exact `<body>` snippet to copy
- README: new "JavaScript — client-side page visit tracking" section documenting the `action_trace.js` script and the required body attributes, including a conditional variant for unauthenticated pages

## [0.6.0] - 2026-04-14

### Changed
- `ApplicationController`: host app URL helpers (`_path`/`_url`) are now proxied via `method_missing` on an inline helper module instead of including `Rails.application.routes.url_helpers` globally, avoiding route conflicts between the engine and the host app

## [0.5.0] - 2026-04-14

### Added
- `Engine`: `config.to_prepare` now includes `Rails.application.routes.url_helpers` in `ActionTrace::ApplicationController`, making host app URL helpers available in engine controllers and views

## [0.4.0] - 2026-03-30

### Added
- `ActivityLog` now exposes a `company` attribute, derived from `user.company` when the user responds to that method

### Changed
- `user` field in `FetchDataChanges`, `FetchPageVisits`, and `FetchSessionStarts` now returns the full user object instead of `complete_name`, giving callers full access to user attributes
- `install_generator`: `filter_by_company` for Ahoy models (`Visit`, `Event`) is now injected directly into the host app's model files during `ahoy:install`, replacing the engine-level `define_singleton_method` approach

### Fixed
- `ActivityLogFetchable`: `company_id` scope is no longer applied when the model does not define a `company_id` column, preventing unintended `WHERE company_id = ?` queries on unrelated models
- `views_generator`: `copy_views` now uses an absolute path resolved via `__dir__` to correctly locate source views inside the gem regardless of the calling context

## [0.3.0] - 2026-03-27

### Fixed
- `Interactor` and `Interactor::Organizer` now included with fully-qualified `::Interactor` to avoid constant lookup conflicts inside the `ActionTrace` namespace
- `interactor` gem explicitly required in `lib/action_trace.rb` so the dependency is always loaded before the engine boots
- `action_trace:views --controller` generator fixed: source path had one extra `../` and resolved outside the gem directory

### Changed
- README fully restructured: clearer installation section, usage split by models vs controllers, customisation options documented (e.g. `skip_after_action :track_action`), `has_paper_trail` and discard usage clarified

## [0.2.0] - 2026-03-27

### Fixed
- Explicit `require` for `public_activity`, `ahoy_matey`, and `paper_trail` in engine to prevent `NameError` when mounted in a host app
- `Ahoy::Visit` and `Ahoy::Event` models now provided by the engine — no need to run `ahoy:install` in the host app
- `install_generator` fixed: added `Rails::Generators::Migration`, `source_root`, `source_paths`, and `next_migration_number` so `migration_template` works correctly

## [0.1.0] - 2026-03-27

### Added
- Initial release
- Rails Engine integrating `public_activity`, `ahoy_matey`, `paper_trail`, and `discard`
- Unified interface for activity tracking, visit analytics, model versioning, and soft deletes