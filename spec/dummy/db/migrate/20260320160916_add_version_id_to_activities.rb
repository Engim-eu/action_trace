# frozen_string_literal: true

class AddVersionIdToActivities < ActiveRecord::Migration[8.1]
  def change
    add_column :activities, :version_id, :integer
  end
end
