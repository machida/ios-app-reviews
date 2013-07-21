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

ActiveRecord::Schema.define(version: 20130721043752) do

  create_table "app_categories", force: true do |t|
    t.integer  "app_id",      null: false
    t.integer  "category_id", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "app_categories", ["app_id"], name: "index_app_categories_on_app_id"
  add_index "app_categories", ["category_id"], name: "index_app_categories_on_category_id"

  create_table "app_reviews", force: true do |t|
    t.integer  "app_id",     null: false
    t.integer  "review_id",  null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "app_reviews", ["app_id"], name: "index_app_reviews_on_app_id"
  add_index "app_reviews", ["review_id"], name: "index_app_reviews_on_review_id"

  create_table "apps", force: true do |t|
    t.integer  "code",                             null: false
    t.string   "name",                             null: false
    t.string   "url",                              null: false
    t.integer  "price",                            null: false
    t.decimal  "rating",                           null: false
    t.string   "version",                          null: false
    t.text     "description",                      null: false
    t.string   "artwork60_url",                    null: false
    t.string   "artwork100_url",                   null: false
    t.string   "artwork512_url",                   null: false
    t.integer  "developer_id",                     null: false
    t.integer  "primary_category_id",              null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "formatted_price",     default: "", null: false
  end

  add_index "apps", ["developer_id"], name: "index_apps_on_developer_id"
  add_index "apps", ["primary_category_id"], name: "index_apps_on_primary_category_id"

  create_table "categories", force: true do |t|
    t.integer  "code",       null: false
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "developers", force: true do |t|
    t.integer  "code",       null: false
    t.string   "name",       null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reviewers", force: true do |t|
    t.integer  "code",       null: false
    t.string   "name",       null: false
    t.string   "url",        null: false
    t.string   "feed_url",   null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "reviews", force: true do |t|
    t.integer  "reviewer_id"
    t.string   "title",        null: false
    t.string   "url",          null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "published_at"
  end

  add_index "reviews", ["reviewer_id"], name: "index_reviews_on_reviewer_id"
  add_index "reviews", ["url"], name: "index_reviews_on_url"

end
