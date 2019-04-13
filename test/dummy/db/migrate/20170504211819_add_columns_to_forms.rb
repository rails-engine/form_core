# frozen_string_literal: true

class AddColumnsToForms < ActiveRecord::Migration[6.0]
  def change
    change_table :forms do |t|
      t.string :title, default: ""
      t.text :description, default: ""
    end
  end
end
