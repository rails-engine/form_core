# frozen_string_literal: true

class AddPositionToSections < ActiveRecord::Migration[6.0]
  def change
    change_table :sections do |t|
      t.integer :position
    end
  end
end
