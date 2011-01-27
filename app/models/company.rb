class Company < ActiveRecord::Base
  has_many :h1bs
  has_many :perms
end
