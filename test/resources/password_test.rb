# frozen_string_literal: true

require 'test_helper'

class PasswordTest < Minitest::Test
  def setup
    Net::HTTP.any_instance.expects(:start).never

    @client = Passwordstate::Client.new 'http://passwordstate.example.com'
    @client.expects(:request)
           .with(:get, 'passwords/18075', query: {}, reason: nil)
           .returns(JSON.parse(File.read('test/fixtures/get_password.json')))

    @password = @client.passwords.get 18_075
  end

  # CRUD tests
  def test_create
    @client.expects(:request)
           .with(:post, 'passwords', query: {}, reason: nil, body:
                 {
                   'PasswordListID' => 100,
                   'Title' => 'borgdrone-4673615 @ Unimatrix Zero',
                   'UserName' => 'borgdrone-4673615',
                   'GeneratePassword' => true
                 })
           .returns(JSON.parse(File.read('test/fixtures/get_password.json')))

    @client.passwords.create password_list_id: 100,
                             title: 'borgdrone-4673615 @ Unimatrix Zero',
                             user_name: 'borgdrone-4673615',
                             generate_password: true
  end

  def test_read
    @client.expects(:request)
           .with(:get, 'passwords/18075', query: {}, reason: nil)
           .returns(JSON.parse(File.read('test/fixtures/get_password.json')))

    @password.get
  end

  def test_update
    @password.domain = '1c0389a1-6e63-4276-8500-1e595f0288e9.cube.collective'

    @client.expects(:request)
           .with(:put, 'passwords', query: {}, reason: nil, body:
                 {
                   'PasswordID' => 18_075,
                   'Domain' => @password.domain
                 })
           .returns(JSON.parse(File.read('test/fixtures/update_password.json')))

    @password.put

    assert_nil @password.status

    @client.expects(:request)
           .with(:put, 'passwords', query: {}, reason: nil, body:
                 {
                   'PasswordID' => 18_075,
                   'Password' => '<redacted>'
                 })
           .returns(JSON.parse(File.read('test/fixtures/update_password_managed.json')))

    @password.password = '<redacted>'
    @password.put

    refute_nil @password.status
    assert_equal '<redacted>', @password.new_password
    refute_equal '<redacted>', @password.current_password
  end

  def test_delete
    @client.expects(:request)
           .with(:delete, 'passwords/18075', query: { 'MoveToRecycleBin' => false }, reason: nil)
           .returns(true)

    @password.delete

    @client.expects(:request)
           .with(:get, 'passwords/18075', query: {}, reason: nil)
           .raises(Passwordstate::HTTPError.new_by_code(404, nil, nil))

    assert_raises(Passwordstate::NotFoundError) { @password.get }
  end

  # Functionality test
  def test_otp
    @client.expects(:request)
           .with(:get, 'onetimepassword/18075')
           .returns(JSON.parse(File.read('test/fixtures/get_password_otp.json')))

    assert_nil @password.otp
    assert_equal '123456', @password.otp!
  end

  def test_check_in
    @client.expects(:request)
           .with(:get, 'passwords/18075', query: { 'CheckIn' => nil })
           .returns(true)

    @password.check_in
  end
end
