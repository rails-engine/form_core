# frozen_string_literal: true

class AddColumnsToFields < ActiveRecord::Migration[5.1]
  def change
    change_table :fields do |t|
      t.string :label, default: ""
      t.string :hint, default: ""
      t.string :prompt, default: ""
      t.references :section, foreign_key: true
    end
  end
end
