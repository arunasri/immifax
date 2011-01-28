class Company < ActiveRecord::Base

  has_many :h1bs
  has_many :perms

  before_create :add_code_from_name

  def self.retrieve_by_code(code_or_name)
    Company.find_by_code(codify(code_or_name))
  end

  private

  def add_code_from_name
    self.code = self.class.codify(name)
  end

  def self.codify( value )
    value.gsub(/[^0-9a-z]/i, '').downcase
  end
end
