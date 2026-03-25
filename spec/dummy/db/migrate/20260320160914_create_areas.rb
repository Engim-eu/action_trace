# frozen_string_literal: true

class CreateAreas < ActiveRecord::Migration[8.1]
  def change
    create_table :areas do |t|
      t.integer :company_id
      t.integer :user_id
      t.timestamps
    end
  end
end
