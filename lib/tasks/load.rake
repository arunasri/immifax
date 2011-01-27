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
      Dir.glob("#{TMP_DIR}/data/*.csv").sort.each do | csv |
        FasterCSV.foreach(csv, :headers => :first_row, :row_sep => :auto, :col_sep => ",") do | row |
          yield(row)
          putc '.'
        end

      end
      system `rm -rf #{TMP_DIR}`
    end

    task :perm_2004 => :environment do
      unzip_to_temp("Perm_FY2004.zip")
      system `cd #{TMP_DIR} && mdb-export Perm_FY2004.mdb  Perm_external_FY2004  > target.txt`

      each_row_of_data do | row |

        fields    = row.to_hash
        next if fields.keys == fields.values
        employer_name   = fields["Emp_Name"]

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

        fields    = row.to_hash
        next if fields.keys == fields.values
        employer_name   = fields["Employer_Name"]

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

        fields    = row.to_hash
        next if fields.keys == fields.values
        employer_name   = fields["Employer_Name"]

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
        fields    = row.to_hash
        next if fields.keys == fields.values
        employer_name   = fields['EMPLOYER_NAME']

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

    task :perm_2008 => :environment do

      unzip_to_temp("Perm_FY2008_TEXT.zip")

      each_row_of_data do | row |

        fields    = row.to_hash
        next if fields.keys == fields.values

        employer_name   = fields['EMPLOYER_NAME']

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
        perm.decision_on        = fields['DECISION_DATE'].to_date
        perm.sector             = fields['US_ECONOMIC_SECTOR']
        perm.naics_us_code      = fields['2007_NAICS_US_CODE']
        perm.naics_us_title     = fields['2007_NAICS_US_TITLE']
        perm.pw_soc_code        = fields['PW_SOC_CODE']
        perm.pw_soc_title       = fields['PW_SOC_TITLE']
        perm.pw_job_title       = fields['PW_JOB_TITLE_9089']
        perm.pw_job_level       = fields['PW_JOB_LEVEL_9089']
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

    task :perm_2009 => :environment do
      unzip_to_temp("Perm_FY2009_TEXT.zip")

      each_row_of_data do | row |
        fields    = row.to_hash
        next if fields.keys == fields.values

        employer_name   = fields['EMPLOYER NAME']

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
        perm.pw_soc_title       = fields['PW SOC TITLE']
        perm.pw_job_title       = fields['PW JOB TITLE 9089']
        perm.pw_job_level       = fields['PW JOB LEVEL 9089']
        perm.pw_source_name     = fields['PW SOURCE NAME 9089']
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
        fields    = row.to_hash
        next if fields.keys == fields.values
        employer_name   = fields['EMPLOYER_NAME']

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


#Perm_FY2005

#Perm_FY2006_TEXT
#

#

=begin



unzip_to_temp("Perm_FY2007_TEXT.zip")

#
=end

#process_efile('H1B_efile_FY09_text.zip')
#process_efile('H1B_efile_FY09_text.zip')
#system `script/chop tmp/target.txt tmp`
