class CreateH1bs < ActiveRecord::Migration
  def self.up
    create_table :h1bs do |t|
      t.string :case_number

      t.integer :company_id

      t.string :employer_name
      t.string :employer_address1
      t.string :employer_address2
      t.string :employer_city
      t.string :employer_state
      t.string :employer_postal_code

      t.string  :city1
      t.string  :state1
      t.integer :prevailing_wage1
      t.integer :prevailing_wage_published_year1
      t.string  :prevailing_wage_source1
      t.string  :prevailing_wage_other_source1
      t.string  :proposed_salary1
      t.string  :proposed_salary_unit1
      t.string  :proposed_salary_max1
      t.boolean :part_time1

      t.string  :city2
      t.string  :state2
      t.integer :prevailing_wage2
      t.integer :prevailing_wage_published_year2
      t.string  :prevailing_wage_source2
      t.string  :prevailing_wage_other_source2
      t.string  :proposed_salary2
      t.string  :proposed_salary_unit2
      t.string  :proposed_salary_max2
      t.boolean :part_time2

      t.date    :requested_begin_date
      t.date    :requested_end_date
      t.date    :approved_begin_date
      t.date    :approved_end_date

      t.string  :job_code
      t.string  :job_title
      t.date    :decision_on
      t.string  :decision
      t.integer :year
      t.boolean :withdrawn

      t.integer :number_of_immigrants
      t.string  :wage_source

      t.timestamps
    end
  end

  def self.down
    drop_table :h1bs
  end
end
