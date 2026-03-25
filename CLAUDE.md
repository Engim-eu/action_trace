# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Install dependencies
bundle install

# Run tests (uses dummy app at spec/dummy/)
bundle exec rspec

# Run a single test file
bundle exec rspec spec/path/to/spec.rb

# Lint
bin/rubocop
bin/rubocop -a  # auto-correct offenses

# Build gem
rake build

# Rails tasks for dummy app
bin/rails <command>
```

## Architecture

`action_trace` is a Rails Engine gem that consolidates four tracking libraries into a single integration point:

- **public_activity** (>= 3) — records user actions/events
- **ahoy_matey** (>= 5) — visit and analytics tracking
- **paper_trail** (>= 17) — model version history
- **discard** (>= 1) — soft deletes with audit trail

### Engine Structure

The gem uses `isolate_namespace ActionTrace` — all engine classes live under `ActionTrace::` to avoid host app conflicts. Entry point: `lib/action_trace.rb` → `lib/action_trace/engine.rb`.

The `app/` directory contains base classes following standard Rails engine conventions. Notably, `ActionTrace::ApplicationController` inherits from `::ApplicationController` (the host app's) so that authentication helpers, `current_user`, and before-actions are automatically available to the engine's controllers.

### Testing

Tests run against a dummy Rails 8.1.2 app at `spec/dummy/`. The Rakefile points `APP_RAKEFILE` there. When writing specs that require Rails context (database, routing), use the dummy app's setup.

### Code Style

Uses standard RuboCop with `rubocop-rails`. CI runs `bin/rubocop -f github` on PRs to main.

### Controller specs

The engine's controller specs use `type: :controller` (not `:request`) to support `assigns` and `render_template`. The `rails-controller-testing` gem is required in `spec/rails_helper.rb` for this. Engine routes are declared with `routes { ActionTrace::Engine.routes }` inside the spec.