# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2018_06_20_194148) do

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.integer "record_id", null: false
    t.integer "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "choices", force: :cascade do |t|
    t.text "label", null: false
    t.integer "field_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position"
    t.index ["field_id"], name: "index_choices_on_field_id"
  end

  create_table "dictionaries", force: :cascade do |t|
    t.string "value", default: "", null: false
    t.string "scope", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["scope"], name: "index_dictionaries_on_scope"
    t.index ["value"], name: "index_dictionaries_on_value"
  end

  create_table "fields", force: :cascade do |t|
    t.string "name", null: false
    t.integer "accessibility", null: false
    t.text "validations"
    t.text "options"
    t.string "type", null: false
    t.integer "form_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "label", default: ""
    t.string "hint", default: ""
    t.integer "section_id"
    t.integer "position"
    t.index ["form_id"], name: "index_fields_on_form_id"
    t.index ["section_id"], name: "index_fields_on_section_id"
    t.index ["type"], name: "index_fields_on_type"
  end

  create_table "forms", force: :cascade do |t|
    t.string "type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title", default: ""
    t.text "description", default: ""
    t.string "attachable_type"
    t.integer "attachable_id"
    t.index ["attachable_type", "attachable_id"], name: "index_forms_on_attachable_type_and_attachable_id"
    t.index ["type"], name: "index_forms_on_type"
  end

  create_table "sections", force: :cascade do |t|
    t.string "title", default: ""
    t.boolean "headless", default: false, null: false
    t.integer "form_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "position"
    t.index ["form_id"], name: "index_sections_on_form_id"
  end

end
