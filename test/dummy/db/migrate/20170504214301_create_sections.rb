# frozen_string_literal: true

class CreateSections < ActiveRecord::Migration[5.1]
  def change
    create_table :sections do |t|
      t.string :title, default: ""
      t.boolean :headless, null: false, default: false
      t.references :form, foreign_key: true

      t.timestamps
    end
  end
end
