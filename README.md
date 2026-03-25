# ActionTrace

ActionTrace is a Rails engine that consolidates user interaction tracking into a single integration point.
It glues together [public_activity](https://github.com/chaps-io/public_activity), [ahoy_matey](https://github.com/ankane/ahoy), [paper_trail](https://github.com/paper-trail-gem/paper_trail), and [discard](https://github.com/jhawthorn/discard) so you don't have to configure each one individually.

## What it tracks

| Source | Description | Backed by |
|---|---|---|
| `data_create` | Model created | public_activity |
| `data_change` | Model updated | public_activity + paper_trail |
| `data_destroy` | Model destroyed | public_activity |
| `page_visit` | Controller action visited | ahoy_matey |
| `session_start` | User session begun | ahoy_matey (visit) |
| `session_end` | User logged out | ahoy_matey (event) |

## Installation

Add to your Gemfile:

```ruby
gem "action_trace"
```

Then run:

```bash
bundle install
rails generate action_trace:install
rails db:migrate
```

The installer runs the setup generators for all four gems and creates `config/initializers/action_trace.rb`.

### Skipping already-installed gems

If one or more of the underlying gems is already set up, pass `--skip-*` flags:

```bash
rails generate action_trace:install --skip-ahoy --skip-paper-trail
```

Available flags:

| Flag | Skips |
|---|---|
| `--skip-ahoy` | `ahoy:install` |
| `--skip-paper-trail` | `paper_trail:install` |
| `--skip-public-activity` | `public_activity:migration` |
| `--skip-discard` | discard initializer entry |

### Mount the engine

In `config/routes.rb`:

```ruby
mount ActionTrace::Engine, at: '/action_trace'
```

This exposes:

```
GET  /action_trace/activity_logs
POST /action_trace/activity_logs/filter
```

The controller inherits from the host app's `ApplicationController`. Authentication and authorization are not enforced by default — copy the controller with the generator and uncomment the relevant lines for your setup (e.g. Devise's `authenticate_user!`, CanCanCan's `load_and_authorize_resource`).

## Configuration

`config/initializers/action_trace.rb` is generated automatically. Available options:

```ruby
ActionTrace.configure do |config|
  # Controller names to exclude from page_visit tracking (default: [])
  config.excluded_controllers = %w[health_checks status]

  # Action names to exclude from page_visit tracking (default: [])
  config.excluded_actions = %w[ping]

  # The user model class name used to resolve company filtering
  # for PublicActivity::Activity, Ahoy::Visit and Ahoy::Event (default: 'User')
  config.user_class = 'User'

  # How long to retain activity records before purging (default: 1.year)
  config.log_retention_period = 6.months
end
```

> `user_class` must have a `company_id` column. ActionTrace uses it to filter
> activity records through the user when filtering by company (since those
> models store the user reference rather than a direct `company_id`).

## Usage

### Track page visits — controller concern

Include `ActivityTrackable` in any controller (or `ApplicationController`):

```ruby
class ApplicationController < ActionController::Base
  include ActivityTrackable
end
```

This adds an `after_action :track_action` that records a `page_visit` event via Ahoy for every successful request made by a logged-in user.

To record a session end on logout, call `track_session_end` in your sessions controller before clearing the session:

```ruby
class SessionsController < Devise::SessionsController
  def destroy
    track_session_end
    super
  end
end
```

### Track model changes — model concern

Include `ActionTrace::DataTrackable` in any ActiveRecord model:

```ruby
class Document < ApplicationRecord
  include ActionTrace::DataTrackable
end
```

This records a `public_activity` event on every `create`, `update`, and `destroy`, linked to the current user (via `PublicActivity.get_controller`) and, when paper_trail is active, to the corresponding version.

### Query activity logs

Use `ActionTrace::FetchActivityLogs` directly to fetch and paginate unified activity:

```ruby
result = ActionTrace::FetchActivityLogs.call(
  current_user: current_user,
  filters: {
    'source'     => 'data_change',  # optional — one of the sources listed above
    'company_id' => 5,              # optional — overrides current_user.company_id
    'user_id'    => 12,             # optional
    'start_date' => '2026-01-01',   # optional — YYYY-MM-DD
    'end_date'   => '2026-03-31'    # optional — YYYY-MM-DD
  },
  range: 0  # offset for pagination (increments of 50)
)

result.activity_logs  # => Array of ActionTrace::ActivityLog
result.total_count    # => Integer
```

Each `ActionTrace::ActivityLog` exposes:

| Attribute | Type | Description |
|---|---|---|
| `id` | String | Prefixed ID e.g. `act_42`, `visit_7`, `evt_3` |
| `source` | String | One of the sources in the table above |
| `occurred_at` | DateTime | When the event happened |
| `user` | String | Display name of the user |
| `subject` | String | Human-readable description |
| `details` | Hash | Raw event payload |
| `paper_trail_version` | PaperTrail::Version | Associated version (data events only) |
| `trackable` | ActiveRecord object | The changed record (data events only) |
| `trackable_type` | String | Class name of the changed record |

#### Presenter helpers

`ActionTrace::ActivityLog` also provides:

```ruby
log.icon    # => 'fas fa-pencil-alt'
log.color   # => 'text-primary'
log.data_change?   # => true / false
log.page_visit?    # => true / false
# … (data_create?, data_destroy?, session_start?)
```

## Customizing views and controller

ActionTrace ships minimal default views for `activity_logs#index`. These work out of the box but are intentionally bare — copy them into your app to customize the UI.

### Copy views

```bash
rails generate action_trace:views
```

This copies the engine views to `app/views/action_trace/activity_logs/` in your application. Rails will use your copies instead of the engine defaults.

### Copy views and controller

```bash
rails generate action_trace:views --controller
```

Also copies `ActivityLogsController` to `app/controllers/action_trace/activity_logs_controller.rb`. The file includes commented-out lines for Devise and CanCanCan — uncomment what applies to your setup, or replace with your own auth logic.

> After copying the controller, the engine's version is no longer used. Any future updates to the engine's controller will not be applied automatically — keep that in mind when upgrading.

## Maintenance

### Purge old records

`ActionTrace::PurgeActivityLogJob` removes all `PublicActivity::Activity`, `Ahoy::Event`, and `Ahoy::Visit` records older than `log_retention_period` (default: 1 year). Schedule it with your preferred job scheduler:

```ruby
# e.g. with whenever or Sidekiq-cron
ActionTrace::PurgeActivityLogJob.perform_later
```

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).