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

ActiveRecord::Schema.define(:version => 20110126042823) do

  create_table "companies", :force => true do |t|
    t.string   "name"
    t.string   "address1"
    t.string   "address2"
    t.string   "city"
    t.string   "state"
    t.string   "zip_code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "h1bs", :force => true do |t|
    t.string   "case_number"
    t.integer  "company_id"
    t.string   "employer"
    t.string   "address1"
    t.string   "address2"
    t.string   "city"
    t.string   "state"
    t.string   "zip_code"
    t.string   "city1"
    t.string   "state1"
    t.float    "pw_amount1"
    t.string   "pw_unit1"
    t.integer  "pw_published_year1"
    t.string   "pw_source1"
    t.string   "pw_other_source1"
    t.string   "salary1"
    t.string   "salary_unit1"
    t.string   "salary_max1"
    t.string   "city2"
    t.string   "state2"
    t.float    "pw_amount2"
    t.string   "pw_unit2"
    t.integer  "pw_published_year2"
    t.string   "pw_source2"
    t.string   "pw_other_source2"
    t.string   "salary2"
    t.string   "salary_unit2"
    t.string   "salary_max2"
    t.date     "requested_start_date"
    t.date     "requested_end_date"
    t.date     "approved_start_date"
    t.date     "approved_end_date"
    t.date     "applied_on"
    t.date     "decision_on"
    t.string   "soc_code"
    t.string   "soc_name"
    t.string   "naics_name"
    t.string   "job_title"
    t.string   "job_code"
    t.string   "case_status"
    t.integer  "year"
    t.boolean  "withdrawn"
    t.integer  "total_workers"
    t.string   "visa_class"
    t.string   "full_time_position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "perms", :force => true do |t|
    t.string   "case_number",         :null => false
    t.string   "application_type"
    t.integer  "company_id"
    t.integer  "year"
    t.string   "case_status"
    t.date     "decision_on"
    t.string   "employer"
    t.string   "address1"
    t.string   "address2"
    t.string   "city"
    t.string   "state"
    t.string   "zip_code"
    t.string   "naics_us_code"
    t.string   "naics_us_title"
    t.string   "sector"
    t.string   "pw_soc_code"
    t.string   "pw_job_title"
    t.string   "pw_job_level"
    t.float    "pw_amount"
    t.string   "pw_unit"
    t.string   "pw_soc_title"
    t.string   "pw_source_name"
    t.string   "pw_other_source"
    t.float    "offered_salary"
    t.float    "max_offered_salary"
    t.string   "offered_salary_unit"
    t.string   "job_city"
    t.string   "job_state"
    t.string   "citizenship"
    t.string   "current_visa"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
