# frozen_string_literal: true

class CreateChoices < ActiveRecord::Migration[5.2]
  def change
    create_table :choices do |t|
      t.text :label, null: false
      t.references :field, foreign_key: true

      t.timestamps
    end
  end
end
