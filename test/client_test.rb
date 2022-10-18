# frozen_string_literal: true

require 'test_helper'

class ClientTest < Minitest::Test
  def setup
    Net::HTTP.any_instance.expects(:start).never

    @client = Passwordstate::Client.new 'http://passwordstate.example.com'
  end

  def test_version
    @client.expects(:request).with(:get, '', allow_html: true).returns <<~HTML
    <html>
    Lorem ipsum
    <div><span>V</span>9.3 (Build 9200)</div>
    </html>
    HTML

    assert_equal '9.3.9200', @client.version
    assert @client.version? '~> 9.3'
  end

  # Passwordstate version 9.6 has started doing stupid things.
  # There are no longer any available method to see the version.
  def test_broken_version
    @client.stubs(:request).with(:get, '', allow_html: true).returns <<~HTML



     <script>
         window.location.href = '/help/manuals/api/index.html';
    </script>
    HTML

    assert_nil @client.version
    assert @client.version? '~> 9.3'
  end
end
