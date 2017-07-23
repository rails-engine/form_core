class CreateFields < ActiveRecord::Migration[5.1]
  def change
    create_table :form_core_fields do |t|
      t.string :name, null: false
      t.integer :accessibility, null: false
      t.text :validations
      t.text :static_default_value
      t.text :options
      t.string :type, null: false, index: true
      t.references :form, foreign_key: {to_table: :form_core_forms}

      t.timestamps
    end
  end
end
