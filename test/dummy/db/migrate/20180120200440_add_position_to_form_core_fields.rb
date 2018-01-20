class AddPositionToFormCoreFields < ActiveRecord::Migration[5.1]
  def change
    change_table :form_core_fields do |t|
      t.integer :position
    end
  end
end
