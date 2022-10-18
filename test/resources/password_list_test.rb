# frozen_string_literal: true

require 'test_helper'

class PasswordListTest < Minitest::Test
  def setup
    Net::HTTP.any_instance.expects(:start).never

    @client = Passwordstate::Client.new 'http://passwordstate.example.com'
    @client.expects(:request)
           .with(:get, 'passwordlists/100', query: {}, reason: nil)
           .returns(JSON.parse(File.read('test/fixtures/get_password_list.json')))

    @list = @client.password_lists.get 100
  end

  # CRUD tests
  def test_create
    @client.expects(:request)
           .with(:post, 'passwordlists', query: {}, reason: nil, body:
                 {
                   'PasswordList' => 'Managed Passwords',
                   'Description' => "Someone's managed passwords",
                   'NestUnderFolderID' => 23
                 })
           .returns(JSON.parse(File.read('test/fixtures/get_password_list.json')))

    @client.password_lists.create password_list: 'Managed Passwords',
                                  description: "Someone's managed passwords",
                                  nest_under_folder_id: 23
  end

  def test_read
    @client.expects(:request)
           .with(:get, 'passwordlists/100', query: {}, reason: nil)
           .returns(JSON.parse(File.read('test/fixtures/get_password_list.json')))

    @list.get
  end

  def test_update
    assert_raises(Passwordstate::NotAcceptableError) { @list.put }
  end

  def test_delete
    assert_raises(Passwordstate::NotAcceptableError) { @list.delete }
  end

  # Functionality test
  def test_parsed
    refute_nil @list.nil?

    assert_equal 100, @list.password_list_id

    assert_equal false, @list.hide_passwords.view
    assert_equal true, @list.hide_passwords.modify
    assert_equal false, @list.hide_passwords.admin

    assert_equal '/Shared/Somewhere/Managed Passwords', @list.full_path(unix: true)
  end

  def test_search
    @client.expects(:request)
           .with(:get, 'searchpasswordlists', query: { 'SiteID' => 0 }, reason: nil)
           .returns([JSON.parse(File.read('test/fixtures/get_password_list.json'))])

    assert_equal @list.attributes, @client.password_lists.search(site_id: 0).first.attributes
  end

  def test_password_search
    @client.expects(:request)
           .with(:get, 'searchpasswords/100', query: { 'Description' => 'borg' }, reason: nil)
           .returns(JSON.parse(File.read('test/fixtures/password_list_search_passwords.json')))

    passwords = @list.passwords.search description: 'borg'

    assert_equal 2, passwords.count
    assert_equal 'borgdrone-4673615', passwords.first.user_name
    assert_equal 'borgdrone-9342756', passwords.last.user_name
  end
end
