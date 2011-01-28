class StrongHash
  def initialize(hash)
    @hash = hash
  end

  def [](key)
    unless @hash.has_key?(key)
      raise RuntimeError, "#{key} Not Found. #{caller}"
    end
    @hash[key]
  end

  def header?
    @hash.keys == @hash.values
  end
end

namespace :visa do
  namespace :load do

    DATA_DIR    = Rails.root.join('data')
    TMP_DIR     = Rails.root.join('tmp')
    SCRIPT_DIR  = Rails.root.join('script')

    def unzip_to_temp(filename)
      system `rm -rf #{TMP_DIR}`
      system `mkdir #{TMP_DIR}`
      system `unzip #{DATA_DIR}/#{filename} -d #{TMP_DIR}`
      system `cd #{TMP_DIR} && mv *.txt target.txt`
    end

    def each_row_of_data
      system `#{SCRIPT_DIR}/chop #{TMP_DIR}/target.txt #{TMP_DIR}/data`
      count = 0
      Dir.glob("#{TMP_DIR}/data/*.csv").sort.each do | csv |
        FasterCSV.foreach(csv, :headers => :first_row, :row_sep => :auto, :col_sep => ",") do | row |
          count += 1
          yield(row)
          putc '.'
          break if count > 500
        end
        break if count > 500
      end
      system `rm -rf #{TMP_DIR}`
    end

    task :h1b_efile_2009 => :environment do
      unzip_to_temp("H1B_efile_FY09_text.zip")
      each_row_of_data do | row |
        fields    = StrongHash.new(row.to_hash)
        fields["duder"]

      end
    end

    task :h1b_2006 => :environment do
      unzip_to_temp("H1B_efile_FY06_text.zip")
      each_row_of_data do | row |

        fields = StrongHash.new(row.to_hash)
        employer_name   = fields["NAME"].try(:strip)
        next if fields.header? || employer_name.blank?


        address1  = fields["ADDRESS"]
        address2  = fields["ADDRESS2"]
        city      = fields["CITY"]
        state     = fields["STATE"]
        zipcode   = fields["POSTAL_CODE"]

        unless company = Company.find_by_name(employer_name)
          company = Company.new(:name => employer_name)
          company.address1 = address1
          company.address2 = address2
          company.city     = city
          company.state    = state
          company.zip_code = zipcode
          company.save
        end

        case_no = fields["CASE_NO"]

        h1b  = company.h1bs.find_or_initialize_by_case_number(case_no)
        h1b.employer = employer_name
        h1b.year = 2006
        h1b.address1 = address1
        h1b.address2 = address2
        h1b.city     = city
        h1b.state    = state
        h1b.zip_code = zipcode


        h1b.city1             = fields["CITY_1"]
        h1b.state1            = fields["STATE_1"]
        h1b.pw_amount1        = fields["PREVAILING_WAGE_1"]
        h1b.pw_source1        = fields["WAGE_SOURCE_1"]
        h1b.pw_other_source1  = fields["OTHER_WAGE_SOURCE_1"]
        h1b.pw_published_year1= fields["YR_SOURCE_PUB_1"]

        h1b.city2             = fields["CITY_2"]
        h1b.state2            = fields["STATE_2"]
        h1b.pw_amount2        = fields["PREVAILING_WAGE_2"]
        h1b.pw_source2        = fields["WAGE_SOURCE_2"]
        h1b.pw_other_source2  = fields["OTHER_WAGE_SOURCE_2"]
        h1b.pw_published_year2= fields["YR_SOURCE_PUB_2"]

        h1b.salary1             = fields["WAGE_RATE_1"]
        h1b.salary_unit1        = fields["RATE_PER_1"]
        h1b.salary_max1         = fields["MAX_RATE_1"]
        h1b.salary2             = fields["WAGE_RATE_2"]
        h1b.salary_unit2        = fields["RATE_PER_2"]
        h1b.salary_max2         = fields["MAX_RATE_2"]

        h1b.requested_start_date  = fields["BEGIN_DATE"].try(:to_date)
        h1b.requested_end_date    = fields["END_DATE"].try(:to_date)

        h1b.approved_start_date  = fields["CERTIFIED_BEGIN_DATE"].try(:to_date)
        h1b.approved_end_date    = fields["CERTIFIED_END_DATE"].try(:to_date)

        h1b.job_title             = fields["JOB_TITLE"]
        h1b.applied_on            = fields["SUBMITTED_DATE"].try(:to_date)
        h1b.decision_on           = fields["DOL_DECISION_DATE"].try(:to_date)
        h1b.case_status           = fields["APPROVAL_STATUS"]
        h1b.total_workers         = fields["NBR_IMMIGRANTS"]
        h1b.full_time_position    = fields["PART_TIME_1"].try(:=~,/n/i).present?

        h1b.save
      end
    end

    task :h1b_2007 => :environment do
      unzip_to_temp("H1B_efile_FY07_text.zip")
      each_row_of_data do | row |

        fields = StrongHash.new(row.to_hash)
        employer_name   = fields["Employer_Name"].try(:strip)
        next if fields.header? || employer_name.blank?

        address1  = fields["Address_1"]
        address2  = fields["Address_2"]
        city      = fields["City"]
        state     = fields["State"]
        zipcode   = fields["Zip_Code"]

        unless company = Company.find_by_name(employer_name)
          company = Company.new(:name => employer_name)
          company.address1 = address1
          company.address2 = address2
          company.city     = city
          company.state    = state
          company.zip_code = zipcode
          company.save
        end

        case_no = fields["Case Number"]

        h1b  = company.h1bs.find_or_initialize_by_case_number(case_no)
        h1b.employer = employer_name
        h1b.year = 2007
        h1b.address1 = address1
        h1b.address2 = address2
        h1b.city     = city
        h1b.state    = state
        h1b.zip_code = zipcode


        h1b.city1             = fields["Work_City_1"]
        h1b.state1            = fields["Work_State_1"]
        h1b.pw_amount1        = fields["Prevailing_Wage_1"]
        h1b.pw_source1        = fields["Prevailing_Wage_Source_1"]
        h1b.pw_other_source1  = fields["Other_Wage_Source_1"]
        h1b.pw_published_year1= fields["Year_Source_Published_1"]

        h1b.city2             = fields["Work_City_2"]
        h1b.state2            = fields["Work_State_2"]
        h1b.pw_amount2        = fields["Prevailing_Wage_2"]
        h1b.pw_source2        = fields["Prevailing_Wage_Source_2"]
        h1b.pw_other_source2  = fields["Other_Wage_Source_2"]
        h1b.pw_published_year2= fields["Year_Source_Published_2"]

        h1b.salary1             = fields["Wage_Rate_From_1"]
        h1b.salary_unit1        = fields["Wage_Rate_Per_1"]
        h1b.salary_max1         = fields["Wage_Rate_To_1"]
        h1b.salary2             = fields["Wage_Rate_From_2"]
        h1b.salary_unit2        = fields["Wage_Rate_Per_2"]
        h1b.salary_max2         = fields["Wage_Rate_To_2"]

        h1b.requested_start_date  = fields["Begin_Date"].try(:to_date)
        h1b.requested_end_date    = fields["End_Date"].try(:to_date)

        h1b.approved_start_date  = fields["Certified_Begin_Date"].try(:to_date)
        h1b.approved_end_date    = fields["Certified_End_Date"].try(:to_date)

        h1b.job_title             = fields["Job_Title"]
        h1b.applied_on            = fields["Submitted_Date"].try(:to_date)
        h1b.decision_on           = fields["DOL_Decision_Date"].try(:to_date)
        h1b.case_status           = fields["Case_Status"]
        h1b.total_workers         = fields["Nbr_Immigrants"]
        h1b.full_time_position    = fields["Part_Time_1"].try(:=~,/n/i).present?
        h1b.withdrawn             = fields["Withdrawn"].try(:=~,/y/i).present?

        h1b.save
      end
    end

    task :h1b_2008 => :environment do
      unzip_to_temp("H1B_efile_FY08_text.zip")
      each_row_of_data do | row |

        fields = StrongHash.new(row.to_hash)
        employer_name   = fields["NAME"].try(:strip)
        next if fields.header? || employer_name.blank?

        employer_name   = fields["NAME"].strip

        address1  = fields["ADDRESS1"]
        address2  = fields["ADDRESS2"]
        city      = fields["CITY"]
        state     = fields["STATE"]
        zipcode   = fields["POSTAL_CODE"]

        unless company = Company.find_by_name(employer_name)
          company = Company.new(:name => employer_name)
          company.address1 = address1
          company.address2 = address2
          company.city     = city
          company.state    = state
          company.zip_code = zipcode
          company.save
        end

        case_no = fields["CASE_NO"]

        h1b  = company.h1bs.find_or_initialize_by_case_number(case_no)
        h1b.employer = employer_name
        h1b.year = 2008
        h1b.address1 = address1
        h1b.address2 = address2
        h1b.city     = city
        h1b.state    = state
        h1b.zip_code = zipcode


        h1b.city1             = fields["CITY_1"]
        h1b.state1            = fields["STATE_1"]
        h1b.pw_amount1        = fields["PREVAILING_WAGE_1"]
        h1b.pw_source1        = fields["WAGE_SOURCE_1"]
        h1b.pw_other_source1  = fields["OTHER_WAGE_SOURCE_1"]
        h1b.pw_published_year1= fields["YR_SOURCE_PUB_1"]

        h1b.city2             = fields["CITY_2"]
        h1b.state2            = fields["STATE_2"]
        h1b.pw_amount1        = fields["PREVAILING_WAGE_2"]
        h1b.pw_source2        = fields["WAGE_SOURCE_2"]
        h1b.pw_other_source2  = fields["OTHER_WAGE_SOURCE_2"]
        h1b.pw_published_year2= fields["YR_SOURCE_PUB_2"]

        h1b.salary1             = fields["WAGE_RATE_1"]
        h1b.salary_unit1        = fields["RATE_PER_1"]
        h1b.salary_max1         = fields["MAX_RATE_1"]
        h1b.salary2             = fields["WAGE_RATE_2"]
        h1b.salary_unit2        = fields["RATE_PER_2"]
        h1b.salary_max2         = fields["MAX_RATE_2"]

        h1b.requested_start_date  = fields["BEGIN_DATE"]
        h1b.requested_end_date    = fields["END_DATE"]

        h1b.approved_start_date  = fields["CERTIFIED_BEGIN_DATE"]
        h1b.approved_end_date    = fields["CERTIFIED_END_DATE"]

        h1b.job_title             = fields["JOB_TITLE"]
        h1b.job_code              = fields["JOB_CODE"]
        h1b.applied_on            = fields["SUBMITTED_DATE"].to_date
        h1b.decision_on           = fields["DOL_DECISION_DATE"].to_date
        h1b.case_status           = fields["APPROVAL_STATUS"]
        h1b.total_workers         = fields["NUM_IMMIGRANTS"]
        h1b.full_time_position    = fields["PART_TIME_1"].try(:=~,/n/i).present?

        h1b.save
      end
    end

    task :h1b_2009 => :environment do
      unzip_to_temp("H1B_efile_FY09_text.zip")
      each_row_of_data do | row |

        fields = StrongHash.new(row.to_hash)
        employer_name   = fields["EMPLOYER_NAME"].try(:strip)
        next if fields.header? || employer_name.blank?

        address1  = fields["EMPLOYER_ADDRESS1"]
        address2  = fields["EMPLOYER_ADDRESS2"]
        city      = fields["EMPLOYER_CITY"]
        state     = fields["EMPLOYER_STATE"]
        zipcode   = fields["EMPLOYER_POSTAL_CODE"]

        unless company = Company.find_by_name(employer_name)
          company = Company.new(:name => employer_name)
          company.address1 = address1
          company.address2 = address2
          company.city     = city
          company.state    = state
          company.zip_code = zipcode
          company.save
        end

        case_no = fields["CASE_NO"]

        h1b  = company.h1bs.find_or_initialize_by_case_number(case_no)
        h1b.employer = employer_name
        h1b.year = 2009
        h1b.address1 = address1
        h1b.city     = city
        h1b.state    = state
        h1b.zip_code = zipcode


        h1b.city1             = fields["CITY_1"]
        h1b.state1            = fields["STATE_1"]
        h1b.pw_amount1        = fields["PREVAILING_WAGE_1"]
        h1b.pw_source1        = fields["WAGE_SOURCE_1"]
        h1b.pw_other_source1  = fields["OTHER_WAGE_SOURCE_1"]
        h1b.pw_published_year1= fields["YR_SOURCE_PUB_1"]

        h1b.city2             = fields["CITY_2"]
        h1b.state2            = fields["STATE_2"]
        h1b.pw_amount2        = fields["PREVAILING_WAGE_2"]
        h1b.pw_source2        = fields["WAGE_SOURCE_2"]
        h1b.pw_other_source2  = fields["OTHER_WAGE_SOURCE_2"]
        h1b.pw_published_year2= fields["YR_SOURCE_PUB_1"]

        h1b.salary1             = fields["WAGE_RATE_1"]
        h1b.salary_max1         = fields["MAX_RATE_1"]
        h1b.salary_unit1        = fields["RATE_PER_1"]

        h1b.salary2             = fields["WAGE_RATE__2"]
        h1b.salary_max2         = fields["MAX_RATE_2"]
        h1b.salary_unit2        = fields["RATE_PER_2"]

        h1b.requested_start_date  = fields["BEGIN_DATE"]
        h1b.requested_end_date    = fields["END_DATE"]
        h1b.job_title             = fields["JOB_TITLE"]
        h1b.soc_code              = fields["OCCUPATIONAL_CODE"]
        h1b.soc_name              = fields["OCCUPATIONAL_TITLE"]
        h1b.applied_on            = fields["SUBMITTED_DATE"].to_date
        h1b.decision_on           = fields["DOL_DECISION_DATE"].to_date
        h1b.case_status           = fields["APPROVAL_STATUS"]
        h1b.total_workers         = fields["NBR_IMMIGRANTS"]
        h1b.full_time_position    = fields["PART_TIME_1"].try(:=~,/n/i).present?
        h1b.withdrawn             = fields["WITHDRAWN"].try(:=~,/y/i).present?

        h1b.save
      end
    end

    task :h1b_2010 => :environment do
      unzip_to_temp("H1B_2010_TEXT.zip")
      each_row_of_data do | row |
        fields = StrongHash.new(row.to_hash)
        employer_name   = fields["LCA_CASE_EMPLOYER_NAME"].try(:strip)
        next if fields.header? || employer_name.blank?

        employer_name   = fields["LCA_CASE_EMPLOYER_NAME"].strip

        address1  = fields["LCA_CASE_EMPLOYER_ADDRESS"]
        city      = fields["LCA_CASE_EMPLOYER_CITY"]
        state     = fields["LCA_CASE_EMPLOYER_STATE"]
        zipcode   = fields["LCA_CASE_EMPLOYER_POSTAL_CODE"]

        unless company = Company.find_by_name(employer_name)
          company = Company.new(:name => employer_name)
          company.address1 = address1
          company.city     = city
          company.state    = state
          company.zip_code = zipcode
          company.save
        end

        case_no = fields["LCA_CASE_NUMBER"]

        h1b  = company.h1bs.find_or_initialize_by_case_number(case_no)
        h1b.employer = employer_name
        h1b.year = 2010
        h1b.address1 = address1
        h1b.city     = city
        h1b.state    = state
        h1b.zip_code = zipcode


        h1b.city1         = fields["LCA_CASE_WORKLOC1_CITY"]
        h1b.city2         = fields["LCA_CASE_WORKLOC2_CITY"]
        h1b.pw_amount1    = fields["PW_1"]
        h1b.pw_unit1      = fields["PW_UNIT_1"]
        h1b.pw_source1    = fields["PW_SOURCE_1"]
        h1b.state1        = fields["LCA_CASE_WORKLOC1_STATE"]
        h1b.state2        = fields["LCA_CASE_WORKLOC2_STATE"]
        h1b.pw_amount2    = fields["PW_2"]
        h1b.pw_unit2      = fields["PW_UNIT_2"]
        h1b.pw_source2    = fields["PW_SOURCE_2"]
        h1b.salary1       = fields["LCA_CASE_WAGE_RATE_FROM"]
        h1b.salary_max1   = fields["LCA_CASE_WAGE_RATE_TO"]
        h1b.salary_unit1  = fields["LCA_CASE_WAGE_RATE_UNIT"]

        h1b.requested_start_date  = fields["LCA_CASE_EMPLOYMENT_START_DATE"]
        h1b.requested_end_date    = fields["LCA_CASE_EMPLOYMENT_END_DATE"]
        h1b.job_title             = fields["LCA_CASE_JOB_TITLE"]
        h1b.soc_code              = fields["LCA_CASE_SOC_CODE"]
        h1b.soc_name              = fields["LCA_CASE_SOC_NAME"]
        h1b.naics_name            = fields["LCA_CASE_NAICS_CODE"]
        h1b.applied_on            = fields["LCA_CASE_SUBMIT"].to_date
        h1b.decision_on           = fields["Decision_Date"].to_date
        h1b.pw_published_year1    = fields["YR_SOURCE_PUB_1"]
        h1b.pw_published_year2    = fields["YR_SOURCE_PUB_2"]


        h1b.visa_class       = fields["VISA_CLASS"]
        h1b.case_status      = fields["STATUS"]
        h1b.total_workers    = fields["TOTAL_WORKERS"]
        h1b.pw_other_source1 = fields["OTHER_WAGE_SOURCE_1"]
        h1b.pw_other_source2 = fields["OTHER_WAGE_SOURCE_2"]

        h1b.full_time_position    = fields["FULL_TIME_POS"].try(:=~,/y/i).present?
        h1b.save
      end
    end

    task :perm_2004 => :environment do
      unzip_to_temp("Perm_FY2004.zip")
      system `cd #{TMP_DIR} && mdb-export Perm_FY2004.mdb  Perm_external_FY2004  > target.txt`

      each_row_of_data do | row |

        fields = StrongHash.new(row.to_hash)
        employer_name   = fields["Emp_Name"].try(:strip)
        next if fields.header? || employer_name.blank?

        address1  = fields["Emp_Address_1"]
        address2  = fields["Emp_Address_2"]
        city      = fields["Emp_City"]
        state     = fields["Emp_State"]
        zipcode   = fields["Emp_Postal_Code"]

        unless company = Company.find_by_name(employer_name)
          company = Company.new(:name => employer_name)
          company.address1 = address1
          company.address2 = address2
          company.city     = city
          company.state    = state
          company.zip_code = zipcode
          company.save
        end

        case_no = fields["Case_Num"]

        perm  = company.perms.find_or_initialize_by_case_number(case_no)
        perm.employer = employer_name
        perm.year = 2004

        perm.address1 = address1
        perm.address2 = address2
        perm.city     = city
        perm.state    = state
        perm.zip_code = zipcode

        perm.job_state          = fields['Work_State']
        perm.application_type   = fields['Case_Type']
        perm.case_status        = fields["Last_Sig_Event"]
        decision_date = fields['Last_Event_Date'].to_date
        if !perm.new_record? && decision_date < perm.decision_on
          next
        end

        #2009 file has this as key

        perm.decision_on        = decision_date
        perm.pw_soc_code        = fields["Occ_Code"]
        perm.pw_soc_title       = fields["OCC_Title"]
        perm.pw_job_title       = fields["Prevailing_Wage_Job_Title"]
        perm.pw_unit            = fields['Unit_of_Pay_prev']
        perm.pw_amount          = fields["Prevail_Wage"]
        perm.offered_salary     = fields["Salary"].to_f
        perm.offered_salary_unit= fields["Unit_of_Pay"]
        perm.citizenship        = fields["Alien_Citizenship_Country"]
        perm.save
      end
    end

    task :perm_2005 => :environment do
      unzip_to_temp("Perm_FY2005.zip")

      system `cd #{TMP_DIR} && mdb-export PERM*.mdb  "PERM\ Disclosure\ Data"  > target.txt`

      each_row_of_data do | row |

        fields = StrongHash.new(row.to_hash)
        employer_name   = fields["Employer_Name"].try(:strip)
        next if fields.header? || employer_name.blank?

        address1  = fields["Employer_Address_1"]
        address2  = fields["Employer_Address_2"]
        city      = fields["Employer_City"]
        state     = fields["Employer_State"]
        zipcode   = fields["Employer_Postal_Code"]

        unless company = Company.find_by_name(employer_name)
          company = Company.new(:name => employer_name)
          company.address1 = address1
          company.address2 = address2
          company.city     = city
          company.state    = state
          company.zip_code = zipcode
          company.save
        end

        case_no = fields["Case_No"]

        perm  = company.perms.find_or_initialize_by_case_number(case_no)
        perm.employer = employer_name
        perm.year = 2005

        raise unless perm.new_record?
        perm.address1 = address1
        perm.address2 = address2
        perm.city     = city
        perm.state    = state
        perm.zip_code = zipcode

        perm.case_status        = fields["Final_Case_Status"]

        #2009 file has this as key
        perm.decision_on        = fields['Certified_Date'].try(:to_date)
        perm.pw_soc_code        = fields["Prevailing_Wage_SOC_CODE"]
        perm.pw_soc_title       = fields["Prevailing_Wage_SOC_Title"]
        perm.pw_job_title       = fields["Prevailing_Wage_Job_Title"]
        perm.pw_job_level       = fields["Prevailing_Wage_Level"]
        perm.pw_source_name     = fields["Prevailing_Wage_Source"]
        perm.pw_amount          = fields["Prevail_Wage"]
        perm.offered_salary     = fields["Wage_Offered_From"].to_f
        perm.offered_salary_unit= fields["Wage_Per"]
        perm.max_offered_salary = fields["Wage_Offered_To"].try(:to_f)
        perm.citizenship        = fields["Alien_Citizenship_Country"]
        perm.save
      end
    end

    task :perm_2006 => :environment do
      unzip_to_temp("Perm_FY2006_TEXT.zip")

      each_row_of_data do | row |

        fields = StrongHash.new(row.to_hash)
        employer_name   = fields["Employer_Name"].try(:strip)
        next if fields.header? || employer_name.blank?

        address1  = fields["Employer_Address_1"]
        address2  = fields["Employer_Address_2"]
        city      = fields["Employer_City"]
        state     = fields["Employer_State"]
        zipcode   = fields["Employer_Postal_Code"]

        unless company = Company.find_by_name(employer_name)
          company = Company.new(:name => employer_name)
          company.address1 = address1
          company.address2 = address2
          company.city     = city
          company.state    = state
          company.zip_code = zipcode
          company.save
        end

        case_no = fields["Case_No"]

        perm  = company.perms.find_or_initialize_by_case_number(case_no)
        perm.employer = employer_name
        perm.year = 2006

        raise unless perm.new_record?
        perm.address1 = address1
        perm.address2 = address2
        perm.city     = city
        perm.state    = state
        perm.zip_code = zipcode

        perm.case_status        = fields["Final_Case_Status"]

        #2009 file has this as key
        perm.decision_on        = (fields['Certified_Date'] || fields['Denied_Date']).to_date
        perm.pw_soc_code        = fields["Prevailing_Wage_SOC_CODE"]
        perm.pw_soc_title       = fields["Prevailing_Wage_SOC_Title"]
        perm.pw_job_title       = fields["Prevailing_Wage_Job_Title"]
        perm.pw_job_level       = fields["Prevailing_Wage_Level"]
        perm.pw_source_name     = fields["Prevailing_Wage_Source"]
        perm.pw_amount          = fields["Prevailing_Wage_Amount"]
        perm.offered_salary     = fields["Wage_Offered_From"].to_f
        perm.offered_salary_unit= fields["Wage_Per"]
        perm.max_offered_salary = fields["Wage_Offered_To"].try(:to_f)
        perm.citizenship        = fields["Alien_Citizenship_Country"]
        perm.save
      end
    end

    task :perm_2007 => :environment do
      unzip_to_temp("Perm_FY2007_TEXT.zip")
      system `mv #{TMP_DIR}/target.txt  #{TMP_DIR}/target`
      system `cat #{DATA_DIR}/2007_perm_headers.csv #{TMP_DIR}/target > #{TMP_DIR}/target.txt`

      each_row_of_data do | row |
        fields = StrongHash.new(row.to_hash)
        employer_name   = fields["EMPLOYER_NAME"].try(:strip)
        next if fields.header? || employer_name.blank?

        address1  = fields['EMPLOYER_ADDRESS_1']
        address2  = fields['EMPLOYER_ADDRESS_2']
        city      = fields['EMPLOYER_CITY']
        state     = fields['EMPLOYER_STATE']
        zipcode   = fields['EMPLOYER_POSTAL_CODE']

        unless company = Company.find_by_name(employer_name)
          company = Company.new(:name => employer_name)
          company.address1 = address1
          company.address2 = address2
          company.city     = city
          company.state    = state
          company.zip_code = zipcode
          company.save
        end

        case_no = fields['CASE_NO']

        perm  = company.perms.find_or_initialize_by_case_number(case_no)
        perm.employer = employer_name
        perm.year = 2007

        raise unless perm.new_record?
        perm.address1 = address1
        perm.address2 = address2
        perm.city     = city
        perm.state    = state
        perm.zip_code = zipcode

        perm.job_city           = fields['JOB_INFO_WORK_CITY']
        perm.job_state          = fields['JOB_INFO_WORK_STATE']
        perm.application_type   = fields['APPLICATION_TYPE']
        perm.case_status        = fields['CASE_STATUS']

        #2009 file has this as key
        perm.decision_on        = (fields['DECISION_DATE'] || fields['DECISION DATE']).to_date
        perm.sector             = fields['US_ECONOMIC_SECTOR']
        perm.naics_us_code      = fields['2007_NAICS_US_CODE']
        perm.naics_us_title     = fields['2007_NAICS_US_TITLE']
        perm.pw_soc_code        = fields['PW_SOC_CODE']
        perm.pw_job_title       = fields['PW_JOB_TITLE_9089']
        perm.pw_job_level       = fields['PW_LEVEL_9089']
        perm.pw_amount          = fields['PW_AMOUNT_9089']
        perm.pw_unit            = fields['PW_UNIT_OF_PAY_9089']
        perm.offered_salary     = fields['WAGE_OFFER_UNIT_OF_PAY_9089'].to_f
        perm.offered_salary_unit= fields['WAGE_OFFER_FROM_9089']
        perm.max_offered_salary = fields['WAGE_OFFER_TO_9089'].try(:to_f)
        perm.citizenship        = fields['COUNTRY_OF_CITZENSHIP']
        perm.current_visa       = fields['CLASS_OF_ADMISSION']
        perm.save
      end
    end

    task :perm_2008 => :environment do

      unzip_to_temp("Perm_FY2008_TEXT.zip")

      each_row_of_data do | row |

        fields = StrongHash.new(row.to_hash)
        employer_name   = fields["EMPLOYER_NAME"].try(:strip)
        next if fields.header? || employer_name.blank?

        employer_name   = fields['EMPLOYER_NAME'].strip

        address1  = fields['EMPLOYER_ADDRESS_1']
        address2  = fields['EMPLOYER_ADDRESS_2']
        city      = fields['EMPLOYER_CITY']
        state     = fields['EMPLOYER_STATE']
        zipcode   = fields['EMPLOYER_POSTAL_CODE']

        unless company = Company.find_by_name(employer_name)
          company = Company.new(:name => employer_name)
          company.address1 = address1
          company.address2 = address2
          company.city     = city
          company.state    = state
          company.zip_code = zipcode
          company.save
        end

        case_no = fields['CASE_NUMBER']

        perm  = company.perms.find_or_initialize_by_case_number(case_no)
        perm.employer = employer_name
        perm.year = 2008

        decision_date = fields['DECISION_DATE'].to_date

        if !perm.new_record? && decision_date < perm.decision_on
          next
        end
        perm.address1 = address1
        perm.address2 = address2
        perm.city     = city
        perm.state    = state
        perm.zip_code = zipcode

        perm.decision_on        = fields['DECISION_DATE'].to_date

        perm.job_city           = fields['JOB_INFO_WORK_CITY']
        perm.job_state          = fields['JOB_INFO_WORK_STATE']
        perm.application_type   = fields['APPLICATION_TYPE']
        perm.case_status        = fields['CASE_STATUS']

        perm.sector             = fields['US_ECONOMIC_SECTOR']
        perm.naics_us_code      = fields['2007_NAICS_US_CODE']
        perm.naics_us_title     = fields['2007_NAICS_US_TITLE']
        perm.pw_soc_code        = fields['PW_SOC_CODE']
        perm.pw_job_title       = fields['PW_JOB_TITLE_9089']
        perm.pw_job_level       = fields['PW_LEVEL_9089']
        perm.pw_amount          = fields['PW_AMOUNT_9089']
        perm.pw_unit            = fields['PW_UNIT_OF_PAY_9089']
        perm.offered_salary     = fields['WAGE_OFFER_UNIT_OF_PAY_9089'].to_f
        perm.offered_salary_unit= fields['WAGE_OFFER_FROM_9089']
        perm.max_offered_salary = fields['WAGE_OFFER_TO_9089'].try(:to_f)
        perm.citizenship        = fields['COUNTRY_OF_CITZENSHIP']
        perm.current_visa       = fields['CLASS_OF_ADMISSION']
        perm.save
      end
    end

    task :perm_2009 => :environment do
      unzip_to_temp("Perm_FY2009_TEXT.zip")

      each_row_of_data do | row |
        fields = StrongHash.new(row.to_hash)
        employer_name   = fields["EMPLOYER NAME"].try(:strip)
        next if fields.header? || employer_name.blank?

        address1  = fields['EMPLOYER ADDRESS_1']
        address2  = fields['EMPLOYER ADDRESS_2']
        city      = fields['EMPLOYER CITY']
        state     = fields['EMPLOYER STATE']
        zipcode   = fields['EMPLOYER POSTAL CODE']

        unless company = Company.find_by_name(employer_name)
          company = Company.new(:name => employer_name)
          company.address1 = address1
          company.address2 = address2
          company.city     = city
          company.state    = state
          company.zip_code = zipcode
          company.save
        end

        case_no = fields['CASE_NUMBER']

        perm  = company.perms.find_or_initialize_by_case_number(case_no)
        perm.employer = employer_name
        perm.year = 2009

        raise unless perm.new_record?
        perm.address1 = address1
        perm.address2 = address2
        perm.city     = city
        perm.state    = state
        perm.zip_code = zipcode

        perm.job_city           = fields['JOB INFO WORK CITY']
        perm.job_state          = fields['JOB INFO WORK STATE']
        perm.application_type   = fields['APPLICATION TYPE']
        perm.case_status        = fields['CASE STATUS']

        #2009 file has this as key
        perm.decision_on        = fields['DECISION DATE'].to_date
        perm.sector             = fields['US ECONOMIC SECTOR']
        perm.naics_us_code      = fields['2007 NAICS US CODE']
        perm.naics_us_title     = fields['2007 NAICS US TITLE']
        perm.pw_soc_code        = fields['PW SOC CODE']
        perm.pw_job_title       = fields['PW JOB TITLE 9089']
        perm.pw_amount          = fields['PW AMOUNT 9089']
        perm.pw_unit            = fields['PW UNIT OF PAY 9089']
        perm.offered_salary     = fields['WAGE OFFER UNIT OF PAY 9089'].to_f
        perm.offered_salary_unit= fields['WAGE OFFER FROM 9089']
        perm.max_offered_salary = fields['WAGE OFFER TO 9089'].try(:to_f)
        perm.citizenship        = fields['COUNTRY OF CITZENSHIP']
        perm.current_visa       = fields['CLASS OF ADMISSION']
        perm.save
      end
    end

    task :perm_2010 => :environment do
      unzip_to_temp("Perm_2010_TEXT.zip")

      each_row_of_data do | row |
        fields = StrongHash.new(row.to_hash)
        employer_name   = fields["EMPLOYER_NAME"].try(:strip)
        next if fields.header? || employer_name.blank?

        address1  = fields['EMPLOYER_ADDRESS_1']
        address2  = fields['EMPLOYER_ADDRESS_2']
        city      = fields['EMPLOYER_CITY']
        state     = fields['EMPLOYER_STATE']
        zipcode   = fields['EMPLOYER_POSTAL_CODE']

        unless company = Company.find_by_name(employer_name)
          company = Company.new(:name => employer_name)
          company.address1 = address1
          company.address2 = address2
          company.city     = city
          company.state    = state
          company.zip_code = zipcode
          company.save
        end

        case_no = fields['CASE_NO']

        perm  = company.perms.find_or_initialize_by_case_number(case_no)
        perm.employer = employer_name
        perm.year = 2010

        raise unless perm.new_record?
        perm.address1 = address1
        perm.address2 = address2
        perm.city     = city
        perm.state    = state
        perm.zip_code = zipcode

        perm.job_city           = fields['JOB_INFO_WORK_CITY']
        perm.job_state          = fields['JOB_INFO_WORK_STATE']
        perm.application_type   = fields['APPLICATION_TYPE']
        perm.case_status        = fields['CASE_STATUS']

        #2009 file has this as key
        perm.decision_on        = (fields['DECISION_DATE'] || fields['DECISION DATE']).to_date
        perm.sector             = fields['US_ECONOMIC_SECTOR']
        perm.naics_us_code      = fields['2007_NAICS_US_CODE']
        perm.naics_us_title     = fields['2007_NAICS_US_TITLE']
        perm.pw_soc_code        = fields['PW_SOC_CODE']
        perm.pw_soc_title       = fields['PW_SOC_TITLE']
        perm.pw_job_title       = fields['PW_JOB_TITLE_9089']
        perm.pw_job_level       = fields['PW_LEVEL_9089']
        perm.pw_source_name     = fields['PW_SOURCE_NAME_9089']
        perm.pw_amount          = fields['PW_AMOUNT_9089']
        perm.pw_unit            = fields['PW_UNIT_OF_PAY_9089']
        perm.offered_salary     = fields['WAGE_OFFER_UNIT_OF_PAY_9089'].to_f
        perm.offered_salary_unit= fields['WAGE_OFFER_FROM_9089']
        perm.max_offered_salary = fields['WAGE_OFFER_TO_9089'].try(:to_f)
        perm.citizenship        = fields['COUNTRY_OF_CITZENSHIP']
        perm.current_visa       = fields['CLASS_OF_ADMISSION']
        perm.save
      end
    end
  end
end
