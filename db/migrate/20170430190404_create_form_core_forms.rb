class CreateFormCoreForms < ActiveRecord::Migration[5.1]
  def change
    create_table :form_core_forms do |t|
      t.string :type, null: false, index: true

      t.timestamps
    end
  end
end
