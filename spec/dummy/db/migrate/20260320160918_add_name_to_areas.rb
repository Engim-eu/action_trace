# frozen_string_literal: true

class AddNameToAreas < ActiveRecord::Migration[8.1]
  def change
    add_column :areas, :name, :string
  end
end
