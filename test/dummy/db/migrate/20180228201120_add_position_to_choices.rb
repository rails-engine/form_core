# frozen_string_literal: true

class AddPositionToChoices < ActiveRecord::Migration[5.2]
  def change
    change_table :choices do |t|
      t.integer :position
    end
  end
end
