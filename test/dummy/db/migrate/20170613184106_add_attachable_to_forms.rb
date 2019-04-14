# frozen_string_literal: true

class AddAttachableToForms < ActiveRecord::Migration[6.0]
  def change
    change_table :forms do |t|
      t.references :attachable, polymorphic: true, index: true
    end
  end
end
