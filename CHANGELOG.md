# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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