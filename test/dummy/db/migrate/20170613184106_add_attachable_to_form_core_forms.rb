class AddAttachableToFormCoreForms < ActiveRecord::Migration[5.1]
  def change
    change_table :form_core_forms do |t|
      t.references :attachable, polymorphic: true, index: true
    end
  end
end
