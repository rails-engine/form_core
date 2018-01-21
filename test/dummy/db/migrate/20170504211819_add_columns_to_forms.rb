# frozen_string_literal: true

class AddColumnsToForms < ActiveRecord::Migration[5.1]
  def change
    change_table :forms do |t|
      t.string :title, default: ""
      t.text :description, default: ""
    end
  end
end
