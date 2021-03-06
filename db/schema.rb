# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160912033504) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "forms", force: :cascade do |t|
    t.string   "name"
    t.text     "intro"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.integer  "first_question"
    t.string   "json"
  end

  create_table "options", force: :cascade do |t|
    t.string   "value"
    t.integer  "question_id"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "next_question"
  end

  add_index "options", ["question_id"], name: "index_options_on_question_id", using: :btree

  create_table "questions", force: :cascade do |t|
    t.string   "question_type"
    t.string   "text"
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "form_id"
    t.string   "qname"
  end

  add_index "questions", ["form_id"], name: "index_questions_on_form_id", using: :btree

  create_table "respondents", force: :cascade do |t|
    t.string   "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "responses", force: :cascade do |t|
    t.string   "value",         null: false
    t.datetime "created_at",    null: false
    t.datetime "updated_at",    null: false
    t.integer  "respondent_id"
    t.integer  "question_id"
  end

  add_index "responses", ["question_id"], name: "index_responses_on_question_id", using: :btree
  add_index "responses", ["respondent_id"], name: "index_responses_on_respondent_id", using: :btree

  create_table "twilio_states", force: :cascade do |t|
    t.integer  "form_id"
    t.integer  "question_id"
    t.string   "phone"
    t.integer  "state"
    t.datetime "created_at",                    null: false
    t.datetime "updated_at",                    null: false
    t.integer  "alpha_index"
    t.boolean  "sent_last_hour", default: true
  end

  add_index "twilio_states", ["form_id"], name: "index_twilio_states_on_form_id", using: :btree
  add_index "twilio_states", ["question_id"], name: "index_twilio_states_on_question_id", using: :btree

  add_foreign_key "options", "questions"
  add_foreign_key "questions", "forms"
  add_foreign_key "twilio_states", "forms"
  add_foreign_key "twilio_states", "questions"
end
