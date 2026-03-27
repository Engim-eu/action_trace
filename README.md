# ActionTrace

ActionTrace is a Rails engine that consolidates user interaction tracking into a single integration point. Instead of configuring [public_activity](https://github.com/chaps-io/public_activity), [ahoy_matey](https://github.com/ankane/ahoy), [paper_trail](https://github.com/paper-trail-gem/paper_trail), and [discard](https://github.com/jhawthorn/discard) individually, ActionTrace wires them together and exposes a unified activity log with a ready-to-use UI.

| Source | Description | Backed by |
|---|---|---|
| `data_create` | Model created | public_activity |
| `data_change` | Model updated | public_activity + paper_trail |
| `data_destroy` | Model destroyed | public_activity |
| `page_visit` | Controller action visited | ahoy_matey |
| `session_start` | User session begun | ahoy_matey (visit) |
| `session_end` | User logged out | ahoy_matey (event) |

---

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

The installer runs the setup generators for all four underlying gems and creates `config/initializers/action_trace.rb`.

### Skipping already-installed gems

If one or more of the underlying gems is already configured, pass `--skip-*` flags:

```bash
rails generate action_trace:install --skip-ahoy --skip-paper-trail
```

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

### Copy views and controller (optional)

ActionTrace ships minimal default views that work out of the box. Copy them into your app to customise the UI:

```bash
# Copy views only
rails generate action_trace:views

# Copy views and controller
rails generate action_trace:views --controller
```

Views are placed in `app/views/action_trace/activity_logs/`. Rails will use your copies instead of the engine defaults.

The `--controller` flag also copies `ActivityLogsController` to `app/controllers/action_trace/activity_logs_controller.rb`. The file includes commented-out lines for Devise and CanCanCan authentication — uncomment what applies to your setup or replace with your own auth logic.

> **Note:** once you copy the controller, the engine's version is no longer used. Future updates to the engine's controller will not be applied automatically — keep that in mind when upgrading.

---

## Usage

### Models — tracking data changes

Include `ActionTrace::DataTrackable` in any ActiveRecord model you want to track:

```ruby
class Document < ApplicationRecord
  include ActionTrace::DataTrackable
end
```

This records a `public_activity` event on every `create`, `update`, and `destroy`, linked to the current user (via `PublicActivity.get_controller`) and, when paper_trail is active, to the corresponding version.

For paper_trail versioning to work, the model also needs `has_paper_trail`:

```ruby
class Document < ApplicationRecord
  include ActionTrace::DataTrackable
  has_paper_trail
end
```

For soft-delete tracking with discard, add `include Discard::Model` alongside `DataTrackable`. The `data_destroy` event is still recorded via the `before_destroy` callback.

### Controllers — tracking page visits and sessions

Include `ActivityTrackable` in any controller (or `ApplicationController`) to track page visits:

```ruby
class ApplicationController < ActionController::Base
  include ActivityTrackable
end
```

This adds an `after_action :track_action` that records a `page_visit` event via Ahoy for every successful request made by a logged-in user. It also includes `PublicActivity::StoreController`, which makes the current controller available to model callbacks so that data events can be linked to the right user.

To skip tracking on a specific controller that inherits from `ApplicationController`:

```ruby
class HealthChecksController < ApplicationController
  skip_after_action :track_action
end
```

To record a session end on logout, call `track_session_end` before clearing the session:

```ruby
class SessionsController < Devise::SessionsController
  def destroy
    track_session_end
    super
  end
end
```

The engine's `ActivityLogsController` inherits from the host app's `ApplicationController`. Authentication and authorization are not enforced by default — copy the controller with the generator and uncomment the relevant lines for your setup (e.g. Devise's `authenticate_user!`, CanCanCan's `load_and_authorize_resource`).

### Querying activity logs directly

Use `ActionTrace::FetchActivityLogs` to fetch and paginate the unified activity log programmatically:

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

Presenter helpers are also available on each log:

```ruby
log.icon           # => 'fas fa-pencil-alt'
log.color          # => 'text-primary'
log.data_change?   # => true / false
log.page_visit?    # => true / false
# data_create?, data_destroy?, session_start?, session_end?
```

### Configuration

`config/initializers/action_trace.rb` is generated automatically. Available options:

```ruby
ActionTrace.configure do |config|
  # Controller names to exclude from page_visit tracking (default: [])
  config.excluded_controllers = %w[health_checks status]

  # Action names to exclude from page_visit tracking (default: [])
  config.excluded_actions = %w[ping]

  # The user model class name used to resolve company filtering (default: 'User')
  config.user_class = 'User'

  # How long to retain activity records before purging (default: 1.year)
  config.log_retention_period = 6.months
end
```

> `user_class` must have a `company_id` column. ActionTrace uses it to filter activity records by company (since Ahoy and PublicActivity store the user reference rather than a direct `company_id`).

### Purging old records

`ActionTrace::PurgeActivityLogJob` removes all `PublicActivity::Activity`, `Ahoy::Event`, and `Ahoy::Visit` records older than `log_retention_period` (default: 1 year). Schedule it with your preferred job scheduler:

```ruby
# e.g. with whenever or Sidekiq-cron
ActionTrace::PurgeActivityLogJob.perform_later
```

---

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).