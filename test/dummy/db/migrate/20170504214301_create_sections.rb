class CreateSections < ActiveRecord::Migration[5.1]
  def change
    create_table :sections do |t|
      t.string :title, default: ''
      t.references :form, foreign_key: {to_table: :form_core_forms}

      t.timestamps
    end
  end
end
