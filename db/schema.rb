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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121109104548) do

  create_table "curriculums", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "curriculums", ["name"], :name => "index_curriculums_on_name", :unique => true

  create_table "goals", :force => true do |t|
    t.integer  "student_id",                                    :null => false
    t.integer  "subject_id",                                    :null => false
    t.integer  "curriculum_id",                                 :null => false
    t.date     "due_date"
    t.float    "accuracy",            :default => 0.0
    t.datetime "created_at",                                    :null => false
    t.datetime "updated_at",                                    :null => false
    t.boolean  "is_completed",        :default => false
    t.float    "baseline",            :default => 0.0
    t.date     "baseline_date",       :default => '2012-11-08', :null => false
    t.integer  "trial_days_total",    :default => 0
    t.integer  "trial_days_actual",   :default => 0
    t.boolean  "is_archived",         :default => false
    t.string   "grades_file_name"
    t.string   "grades_content_type"
    t.integer  "grades_file_size"
    t.datetime "grades_updated_at"
  end

  add_index "goals", ["curriculum_id"], :name => "index_goals_on_curriculum_id"
  add_index "goals", ["subject_id"], :name => "index_goals_on_subject_id"

  create_table "progresses", :force => true do |t|
    t.integer  "goal_id",                     :null => false
    t.date     "due_date",                    :null => false
    t.float    "accuracy",   :default => 0.0
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  add_index "progresses", ["goal_id"], :name => "index_progresses_on_goal_id"

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "statuses", :force => true do |t|
    t.integer  "goal_id",                             :null => false
    t.date     "due_date"
    t.float    "accuracy"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.boolean  "is_ideal",         :default => true
    t.integer  "user_id"
    t.float    "value",            :default => 0.0
    t.float    "ideal_value",      :default => 0.0
    t.time     "time_to_complete"
    t.integer  "progress_id"
    t.boolean  "is_unused",        :default => false
  end

  add_index "statuses", ["goal_id"], :name => "index_statuses_on_goal_id"

  create_table "student_sharings", :force => true do |t|
    t.string   "email",         :null => false
    t.integer  "role_id"
    t.integer  "student_id",    :null => false
    t.integer  "user_id"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
    t.string   "confirm_token"
    t.string   "first_name"
    t.string   "last_name"
  end

  add_index "student_sharings", ["email"], :name => "index_student_sharings_on_email"
  add_index "student_sharings", ["role_id"], :name => "index_student_sharings_on_role_id"
  add_index "student_sharings", ["student_id"], :name => "index_student_sharings_on_student_id"
  add_index "student_sharings", ["user_id"], :name => "index_student_sharings_on_user_id"

  create_table "students", :force => true do |t|
    t.string   "first_name",         :null => false
    t.string   "last_name",          :null => false
    t.date     "birthday"
    t.integer  "teacher_id"
    t.boolean  "gender"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
  end

  add_index "students", ["first_name", "last_name", "teacher_id"], :name => "index_students_on_first_name_and_last_name_and_teacher_id", :unique => true

  create_table "subjects", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "subjects", ["name"], :name => "index_subjects_on_name", :unique => true

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "first_name",                             :null => false
    t.string   "last_name",                              :null => false
    t.string   "phone"
    t.string   "classroom"
    t.integer  "role_id"
    t.integer  "parent_id"
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
    t.string   "school_name"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.boolean  "is_admin"
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
