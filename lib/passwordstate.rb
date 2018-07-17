require 'logging'
require 'passwordstate/client'
require 'passwordstate/errors'
require 'passwordstate/resource'
require 'passwordstate/util'
require 'passwordstate/version'

module Passwordstate
  def self.debug!
    logger.level = :debug
  end

  def self.logger
    @logger ||= Logging.logger[name].tap do |logger|
      logger.add_appenders Logging.appenders.stdout
      logger.level = :warn
    end
  end
end
