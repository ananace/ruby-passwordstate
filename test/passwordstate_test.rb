# frozen_string_literal: true

require 'test_helper'

class PasswordstateTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Passwordstate::VERSION
  end

  def test_logging_setup
    assert_equal 2, Passwordstate.logger.level # :warn

    Passwordstate.debug!

    assert_equal 0, Passwordstate.logger.level # :debug

    Passwordstate.logger.level = :warn
  end
end
