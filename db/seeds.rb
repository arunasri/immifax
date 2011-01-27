def chop_to_pieces(filename)
  file = Rails.root.join('data').to_s + "/#{filename}"
  tmp  = Rails.root.join('tmp').to_s
  system `rm -rf #{tmp}`
  system `mkdir #{tmp}`
  system `unzip #{file} -d #{tmp}`
  system `mv #{tmp}/*.txt #{tmp}/target.txt`
  system `#{Rails.root}/script/chop #{tmp}/target.txt #{tmp}/data`

  Dir.glob("#{Rails.root}/tmp/data/*.csv").sort.each do | csv |
    FasterCSV.foreach(csv, :headers => :first_row, :row_sep => :auto, :col_sep => ",") do | row |
      yield(row)
    end
  end

  system `rm -rf #{tmp}`
end

def process_efile(filename)
  chop_to_pieces(filename)
  csv   = Dir.glob("#{Rails.root}/tmp/data/*.csv").sort[0]
  FasterCSV.foreach(csv, :headers => :first_row, :row_sep => :auto, :col_sep => ",") do | row |
    next if row.headers == row.fields
  end
end

def process_perm_file(filename)
  chop_to_pieces(filename) do | row |
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

    case_no = fields['CASE_NUMBER'] || fields['CASE_NO']

    perm  = company.perms.find_or_initialize_by_case_number(case_no)

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

    putc '.'
  end
end
#Perm_FY2005
#Perm_FY2006_TEXT
#Perm_FY2007_TEXT
perms_before_2005 = %w(Perm_FY2008_TEXT Perm_FY2009_TEXT Perm_2010_TEXT)
perms_before_2005.each { |f| process_perm_file("#{f}.zip") }

#process_efile('H1B_efile_FY09_text.zip')
#process_efile('H1B_efile_FY09_text.zip')
#system `script/chop tmp/target.txt tmp`
