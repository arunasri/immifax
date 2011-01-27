class CreatePerms < ActiveRecord::Migration
  def self.up
    create_table :perms do |t|
      t.string    :case_number,     :null => false
      t.string    :application_type
      t.integer   :company_id

      t.integer   :year
      t.string    :case_status
      t.date      :decision_on

      t.string    :employer
      t.string    :address1
      t.string    :address2
      t.string    :city
      t.string    :state
      t.string    :zip_code
      t.string    :naics_us_code
      t.string    :naics_us_title
      t.string    :sector

      t.string    :pw_soc_code
      t.string    :pw_job_title
      t.string    :pw_job_level
      t.float     :pw_amount
      t.string    :pw_unit
      t.string    :pw_soc_title
      t.string    :pw_source_name
      t.string    :pw_other_source

      t.float     :offered_salary
      t.float     :max_offered_salary
      t.string    :offered_salary_unit

      t.string    :job_city
      t.string    :job_state
      t.string    :citizenship
      t.string    :current_visa

      t.timestamps
    end
  end

  def self.down
    drop_table :perms
  end
end
