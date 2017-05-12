class AddColumnsToFormCoreForms < ActiveRecord::Migration[5.1]
  def change
    change_table :form_core_forms do |t|
      t.string :title, default: ''
      t.text :description, default: ''
    end
  end
end
