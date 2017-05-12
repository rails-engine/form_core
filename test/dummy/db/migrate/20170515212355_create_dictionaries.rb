class CreateDictionaries < ActiveRecord::Migration[5.1]
  def change
    create_table :dictionaries do |t|
      t.string :value, null: false, default: "", index: true
      t.string :scope, null: false, default: "", index: true

      t.timestamps
    end
  end
end
