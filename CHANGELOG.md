# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

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