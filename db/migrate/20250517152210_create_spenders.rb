class CreateSpenders < ActiveRecord::Migration[8.0]
  def change
    create_table :spenders do |t|
      t.string :name

      t.timestamps
    end
  end
end
