# Passwordstate

A ruby gem for communicating with a Passwordstate instance

The documentation for the development version can be found at https://iti.gitlab-pages.liu.se/ruby-passwordstate

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'passwordstate'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install passwordstate

## Usage example

```ruby
require 'passwordstate'
client = Passwordstate::Client.new 'https://passwordstate.example.com', username: 'user', password: 'password'
#        Passwordstate::Client.new 'https://passwordstate.example.com', apikey: 'key'
# #<Passwordstate::Client:0x0000559eb1fabec8
#  @headers=
#   {"accept"=>"application/json", "user-agent"=>"RubyPasswordstate/0.1.0"},
#  @server_url=#<URI::HTTPS https://passwordstate.it.liu.se>,
#  @timeout=15,
#  @validate_certificate=true>

client.folders
# [#<Passwordstate::Resources::Folder:0x000055ed493636e8
#   @folder_name="Example",
#   @folder_id=2,
#   @tree_path="\\Example">,
#  #<Passwordstate::Resources::Folder:0x000055ed49361fa0
#   @folder_name="Folder",
#   @folder_id=3,
#   @tree_path="\\Example\\Folder">]

client.password_lists.get(7).passwords
# [#<Passwordstate::Resources::Password:0x0000555fda8acdb8
#   @title="Webserver1",
#   @user_name="test_web_account",
#   @account_type_id=0,
#   @password="[ REDACTED ]",
#   @allow_export=false,
#   @password_id=2>,
#  #<Passwordstate::Resources::Password:0x0000555fda868640
#   @title="Webserver2",
#   @user_name="test_web_account2",
#   @account_type_id=0,
#   @password="[ REDACTED ]",
#   @allow_export=false,
#   @password_id=3>,
#  #<Passwordstate::Resources::Password:0x0000555fda84da48
#   @title="Webserver3",
#   @user_name="test_web_account3",
#   @account_type_id=0,
#   @password="[ REDACTED ]",
#   @allow_export=false,
#   @password_id=4>]

pw = client.password_lists.first.passwords.create title: 'example', user_name: 'someone', generate_password: true
# #<Passwordstate::Resources::Password:0x0000555fdaf9ce98
#  @title="example",
#  @user_name="someone",
#  @account_type_id=0,
#  @password="[ REDACTED ]",
#  @allow_export=true,
#  @password_id=12,
#  @generate_password=true,
#  @password_list_id=6>

pw.password
# "millionfE2rMrcb2LngBTHnDyxdpsGSmK3"

pw.delete
# true
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ananace/ruby-passwordstate
The project lives at https://gitlab.liu.se/ITI/ruby-passwordstate

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
