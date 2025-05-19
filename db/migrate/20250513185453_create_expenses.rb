class CreateExpenses < ActiveRecord::Migration[8.0]
  def change
    create_table :expenses do |t|
      t.references :user, null: false, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.date :date, null: false
      t.text :description, null: false

      t.timestamps
    end
    add_index :expenses, :date
  end
end