class CreateForms < ActiveRecord::Migration[5.1]
  def change
    create_table :forms do |t|
      t.string :type, null: false, index: true

      t.timestamps
    end
  end
end
