# frozen_string_literal: true

# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 20_260_320_160_918) do
  create_table 'activities', force: :cascade do |t|
    t.datetime 'created_at', null: false
    t.string 'key'
    t.integer 'owner_id'
    t.string 'owner_type'
    t.text 'parameters'
    t.integer 'recipient_id'
    t.string 'recipient_type'
    t.integer 'trackable_id'
    t.string 'trackable_type'
    t.datetime 'updated_at', null: false
    t.integer 'version_id'
    t.index %w[owner_type owner_id], name: 'index_activities_on_owner'
    t.index %w[recipient_type recipient_id], name: 'index_activities_on_recipient'
    t.index %w[trackable_type trackable_id], name: 'index_activities_on_trackable'
  end

  create_table 'ahoy_events', force: :cascade do |t|
    t.string 'name'
    t.text 'properties'
    t.datetime 'time'
    t.integer 'user_id'
    t.integer 'visit_id'
    t.index %w[name time], name: 'index_ahoy_events_on_name_and_time'
    t.index ['user_id'], name: 'index_ahoy_events_on_user_id'
    t.index ['visit_id'], name: 'index_ahoy_events_on_visit_id'
  end

  create_table 'ahoy_visits', force: :cascade do |t|
    t.string 'app_version'
    t.string 'browser'
    t.string 'city'
    t.string 'country'
    t.string 'device_type'
    t.string 'ip'
    t.text 'landing_page'
    t.float 'latitude'
    t.float 'longitude'
    t.string 'os'
    t.string 'os_version'
    t.string 'platform'
    t.text 'referrer'
    t.string 'referring_domain'
    t.string 'region'
    t.datetime 'started_at'
    t.text 'user_agent'
    t.integer 'user_id'
    t.string 'utm_campaign'
    t.string 'utm_content'
    t.string 'utm_medium'
    t.string 'utm_source'
    t.string 'utm_term'
    t.string 'visit_token'
    t.string 'visitor_token'
    t.index ['user_id'], name: 'index_ahoy_visits_on_user_id'
    t.index ['visit_token'], name: 'index_ahoy_visits_on_visit_token', unique: true
    t.index %w[visitor_token started_at], name: 'index_ahoy_visits_on_visitor_token_and_started_at'
  end

  create_table 'areas', force: :cascade do |t|
    t.integer 'company_id'
    t.datetime 'created_at', null: false
    t.string 'name'
    t.datetime 'updated_at', null: false
    t.integer 'user_id'
  end

  create_table 'companies', force: :cascade do |t|
    t.datetime 'created_at', null: false
    t.string 'name'
    t.datetime 'updated_at', null: false
  end

  create_table 'users', force: :cascade do |t|
    t.integer 'company_id'
    t.datetime 'created_at', null: false
    t.datetime 'updated_at', null: false
  end

  create_table 'versions', force: :cascade do |t|
    t.datetime 'created_at'
    t.string 'event', null: false
    t.bigint 'item_id', null: false
    t.string 'item_type', null: false
    t.text 'object', limit: 1_073_741_823
    t.string 'whodunnit'
    t.index %w[item_type item_id], name: 'index_versions_on_item_type_and_item_id'
  end
end
