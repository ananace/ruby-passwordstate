# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)
require 'passwordstate'

require 'minitest/reporters'
Minitest::Reporters.use! [
  Minitest::Reporters::ProgressReporter.new,
  Minitest::Reporters::JUnitReporter.new
]
require 'minitest/autorun'
require 'mocha/minitest'
