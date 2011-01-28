class CreateH1bs < ActiveRecord::Migration
  def self.up
    create_table :h1bs do |t|
      t.string :case_number

      t.integer :company_id

      t.string :employer
      t.string :address1
      t.string :address2
      t.string :city
      t.string :state
      t.string :zip_code

      t.string  :city1
      t.string  :state1
      t.float   :pw_amount1
      t.string  :pw_unit1
      t.integer :pw_published_year1
      t.string  :pw_source1
      t.string  :pw_other_source1
      t.string  :salary1
      t.string  :salary_unit1
      t.string  :salary_max1

      t.string  :city2
      t.string  :state2
      t.float   :pw_amount2
      t.string  :pw_unit2
      t.integer :pw_published_year2
      t.string  :pw_source2
      t.string  :pw_other_source2
      t.string  :salary2
      t.string  :salary_unit2
      t.string  :salary_max2

      t.date    :requested_start_date
      t.date    :requested_end_date
      t.date    :approved_start_date
      t.date    :approved_end_date
      t.date    :applied_on
      t.date    :decision_on

      t.string  :soc_code
      t.string  :soc_name
      t.string  :naics_name
      t.string  :job_title
      t.string  :job_code
      t.date    :decision_on
      t.string  :case_status
      t.integer :year
      t.boolean :withdrawn

      t.integer :total_workers
      t.string  :visa_class
      t.string  :full_time_position

      t.timestamps
    end
  end

  def self.down
    drop_table :h1bs
  end
end
