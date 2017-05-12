class AddColumnsToFormCoreFields < ActiveRecord::Migration[5.1]
  def change
    change_table :form_core_fields do |t|
      t.string :label, default: ''
      t.string :hint, default: ''
      t.string :prompt, default: ''
      t.references :section, foreign_key: true
    end
  end
end
