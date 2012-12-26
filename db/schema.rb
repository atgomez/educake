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

ActiveRecord::Schema.define(:version => 20130225065442) do

  create_table "curriculum_areas", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "curriculum_areas", ["name"], :name => "index_curriculum_areas_on_name", :unique => true

  create_table "curriculum_cores", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "curriculum_cores", ["name"], :name => "index_curriculum_cores_on_name", :unique => true

  create_table "curriculum_grades", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "curriculum_grades", ["name"], :name => "index_curriculum_grades_on_name", :unique => true

  create_table "curriculums", :force => true do |t|
    t.integer  "curriculum_core_id",  :null => false
    t.integer  "subject_id",          :null => false
    t.integer  "curriculum_grade_id", :null => false
    t.integer  "curriculum_area_id",  :null => false
    t.integer  "standard",            :null => false
    t.string   "description1",        :null => false
    t.text     "description2",        :null => false
    t.datetime "created_at",          :null => false
    t.datetime "updated_at",          :null => false
  end

  add_index "curriculums", ["curriculum_core_id", "subject_id", "curriculum_grade_id", "curriculum_area_id", "standard"], :name => "curriculums_unique_index", :unique => true

  create_table "goals", :force => true do |t|
    t.integer  "student_id",                           :null => false
    t.integer  "curriculum_id",                        :null => false
    t.float    "accuracy",          :default => 0.0,   :null => false
    t.float    "baseline",          :default => 0.0,   :null => false
    t.date     "baseline_date",                        :null => false
    t.date     "due_date",                             :null => false
    t.integer  "trial_days_total",                     :null => false
    t.integer  "trial_days_actual",                    :null => false
    t.text     "description"
    t.boolean  "is_completed",      :default => false
    t.datetime "created_at",                           :null => false
    t.datetime "updated_at",                           :null => false
  end

  add_index "goals", ["baseline_date"], :name => "index_goals_on_baseline_date"
  add_index "goals", ["curriculum_id"], :name => "index_goals_on_curriculum_id"
  add_index "goals", ["due_date"], :name => "index_goals_on_due_date"
  add_index "goals", ["student_id"], :name => "index_goals_on_student_id"

  create_table "grades", :force => true do |t|
    t.integer  "goal_id",                             :null => false
    t.integer  "user_id"
    t.integer  "progress_id"
    t.date     "due_date",                            :null => false
    t.float    "accuracy",         :default => 0.0,   :null => false
    t.float    "value",            :default => 0.0
    t.float    "ideal_value",      :default => 0.0
    t.time     "time_to_complete"
    t.boolean  "is_unused",        :default => false
    t.text     "note"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
  end

  add_index "grades", ["due_date"], :name => "index_grades_on_due_date"
  add_index "grades", ["goal_id"], :name => "index_grades_on_goal_id"
  add_index "grades", ["progress_id"], :name => "index_grades_on_progress_id"
  add_index "grades", ["user_id"], :name => "index_grades_on_user_id"

  create_table "progresses", :force => true do |t|
    t.integer  "goal_id",                     :null => false
    t.date     "due_date",                    :null => false
    t.float    "accuracy",   :default => 0.0, :null => false
    t.datetime "created_at",                  :null => false
    t.datetime "updated_at",                  :null => false
  end

  add_index "progresses", ["due_date"], :name => "index_progresses_on_due_date"
  add_index "progresses", ["goal_id"], :name => "index_progresses_on_goal_id"

  create_table "roles", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "roles", ["name"], :name => "index_roles_on_name", :unique => true

  create_table "schools", :force => true do |t|
    t.string   "name",       :null => false
    t.string   "address1",   :null => false
    t.string   "address2"
    t.string   "city"
    t.string   "state",      :null => false
    t.string   "zipcode"
    t.string   "phone",      :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "schools", ["name", "city"], :name => "index_schools_on_name_and_city", :unique => true
  add_index "schools", ["name", "state"], :name => "index_schools_on_name_and_state", :unique => true

  create_table "student_sharings", :force => true do |t|
    t.string   "first_name",                       :null => false
    t.string   "last_name",                        :null => false
    t.string   "email",                            :null => false
    t.integer  "student_id",                       :null => false
    t.integer  "user_id"
    t.integer  "role_id",                          :null => false
    t.string   "confirm_token"
    t.boolean  "is_blocked",    :default => false
    t.datetime "created_at",                       :null => false
    t.datetime "updated_at",                       :null => false
  end

  add_index "student_sharings", ["confirm_token"], :name => "index_student_sharings_on_confirm_token"
  add_index "student_sharings", ["email", "student_id"], :name => "index_student_sharings_on_email_and_student_id", :unique => true
  add_index "student_sharings", ["role_id"], :name => "index_student_sharings_on_role_id"
  add_index "student_sharings", ["student_id"], :name => "index_student_sharings_on_student_id"
  add_index "student_sharings", ["user_id"], :name => "index_student_sharings_on_user_id"

  create_table "students", :force => true do |t|
    t.string   "first_name",         :null => false
    t.string   "last_name",          :null => false
    t.date     "birthday",           :null => false
    t.integer  "teacher_id"
    t.boolean  "gender"
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.datetime "created_at",         :null => false
    t.datetime "updated_at",         :null => false
  end

  add_index "students", ["first_name", "last_name", "teacher_id"], :name => "index_students_on_first_name_and_last_name_and_teacher_id", :unique => true

  create_table "subjects", :force => true do |t|
    t.string   "name",       :null => false
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  add_index "subjects", ["name"], :name => "index_subjects_on_name", :unique => true

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "",    :null => false
    t.string   "encrypted_password",     :default => "",    :null => false
    t.string   "first_name",                                :null => false
    t.string   "last_name",                                 :null => false
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
    t.string   "photo_file_name"
    t.string   "photo_content_type"
    t.integer  "photo_file_size"
    t.datetime "photo_updated_at"
    t.boolean  "is_admin",               :default => false
    t.integer  "school_id"
    t.text     "notes"
    t.boolean  "is_blocked",             :default => false
    t.datetime "created_at",                                :null => false
    t.datetime "updated_at",                                :null => false
  end

  add_index "users", ["confirmation_token"], :name => "index_users_on_confirmation_token", :unique => true
  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["parent_id"], :name => "index_users_on_parent_id"
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true
  add_index "users", ["role_id"], :name => "index_users_on_role_id"
  add_index "users", ["school_id"], :name => "index_users_on_school_id"

end
