# Load RAILS_ROOT/config/config.yml file which is an application wide configuration file
#
# Usage: AppConfig.base_url
#
require 'ostruct'
require 'yaml'

appconfig       = OpenStruct.new(YAML.load_file("#{Rails.root}/config/app_config.yml"))
env_config      = appconfig.send(Rails.env) rescue nil

appconfig.common.update(env_config) unless env_config.nil?

AppConfig       = OpenStruct.new(appconfig.common)
