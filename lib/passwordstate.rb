# frozen_string_literal: true

require 'logging'
require 'pp'
require 'passwordstate/version'
require 'passwordstate/client'
require 'passwordstate/errors'
require 'passwordstate/resource'
require 'passwordstate/resource_list'
require 'passwordstate/util'

module Passwordstate
  def self.debug!
    logger.level = :debug
  end

  def self.logger
    @logger ||= Logging.logger[self].tap do |logger|
      logger.add_appenders Logging.appenders.stdout
      logger.level = :warn
    end
  end
end
