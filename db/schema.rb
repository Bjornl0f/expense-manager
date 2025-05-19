# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_05_17_153757) do
  create_table "categories", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "name"], name: "index_categories_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_categories_on_user_id"
  end

  create_table "expense_categories", force: :cascade do |t|
    t.integer "expense_id", null: false
    t.integer "category_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_expense_categories_on_category_id"
    t.index ["expense_id", "category_id"], name: "index_expense_categories_on_expense_id_and_category_id", unique: true
    t.index ["expense_id"], name: "index_expense_categories_on_expense_id"
  end

  create_table "expense_payment_methods", force: :cascade do |t|
    t.integer "expense_id", null: false
    t.integer "payment_method_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expense_id", "payment_method_id"], name: "index_expense_payment_methods_on_expense_and_payment_method", unique: true
    t.index ["expense_id"], name: "index_expense_payment_methods_on_expense_id"
    t.index ["payment_method_id"], name: "index_expense_payment_methods_on_payment_method_id"
  end

  create_table "expenses", force: :cascade do |t|
    t.integer "user_id", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.date "date", null: false
    t.text "description", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "spender_id", null: false
    t.index ["date"], name: "index_expenses_on_date"
    t.index ["spender_id"], name: "index_expenses_on_spender_id"
    t.index ["user_id"], name: "index_expenses_on_user_id"
  end

  create_table "payment_methods", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "name"], name: "index_payment_methods_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_payment_methods_on_user_id"
  end

  create_table "spenders", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_spenders_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "categories", "users"
  add_foreign_key "expense_categories", "categories"
  add_foreign_key "expense_categories", "expenses"
  add_foreign_key "expense_payment_methods", "expenses"
  add_foreign_key "expense_payment_methods", "payment_methods"
  add_foreign_key "expenses", "spenders"
  add_foreign_key "expenses", "users"
  add_foreign_key "payment_methods", "users"
  add_foreign_key "spenders", "users"
end
