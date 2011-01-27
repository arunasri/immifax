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
    t.string   "employer_name"
    t.string   "employer_address1"
    t.string   "employer_address2"
    t.string   "employer_city"
    t.string   "employer_state"
    t.string   "employer_postal_code"
    t.string   "city1"
    t.string   "state1"
    t.integer  "prevailing_wage1"
    t.integer  "prevailing_wage_published_year1"
    t.string   "prevailing_wage_source1"
    t.string   "prevailing_wage_other_source1"
    t.string   "proposed_salary1"
    t.string   "proposed_salary_unit1"
    t.string   "proposed_salary_max1"
    t.boolean  "part_time1"
    t.string   "city2"
    t.string   "state2"
    t.integer  "prevailing_wage2"
    t.integer  "prevailing_wage_published_year2"
    t.string   "prevailing_wage_source2"
    t.string   "prevailing_wage_other_source2"
    t.string   "proposed_salary2"
    t.string   "proposed_salary_unit2"
    t.string   "proposed_salary_max2"
    t.boolean  "part_time2"
    t.date     "requested_begin_date"
    t.date     "requested_end_date"
    t.date     "approved_begin_date"
    t.date     "approved_end_date"
    t.string   "job_code"
    t.string   "job_title"
    t.date     "decision_on"
    t.string   "decision"
    t.integer  "year"
    t.boolean  "withdrawn"
    t.integer  "number_of_immigrants"
    t.string   "wage_source"
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
