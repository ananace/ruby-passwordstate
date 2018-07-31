# Passwordstate

A ruby gem for communicating with a Passwordstate instance

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

```irb
irb(main):001:0> require 'passwordstate'
irb(main):002:0> client = Passwordstate::Client.new 'https://passwordstate', username: 'user', password: 'password'
irb(main):003:0> #        Passwordstate::Client.new 'https://passwordstate', apikey: 'key'
irb(main):004:0> client.folders
=> [#<Passwordstate::Resources::Folder:0x000055ed493636e8 @folder_name="Example", @folder_id=2, @tree_path="\\Example">, #<Passwordstate::Resources::Folder:0x000055ed49361fa0 @folder_name="Folder", @folder_id=3, @tree_path="\\Example\\Folder">]
irb(main):005:0> client.password_lists.get(7).passwords
=> [#<Passwordstate::Resources::Password:0x0000555fda8acdb8 @title="Webserver1", @user_name="test_web_account", @account_type_id=0, @password="[ REDACTED ]", @allow_export=false, @password_id=2>, #<Passwordstate::Resources::Password:0x0000555fda868640 @title="Webserver2", @user_name="test_web_account2", @account_type_id=0, @password="[ REDACTED ]", @allow_export=false, @password_id=3>, #<Passwordstate::Resources::Password:0x0000555fda84da48 @title="Webserver3", @user_name="test_web_account3", @account_type_id=0, @password="[ REDACTED ]", @allow_export=false, @password_id=4>]
irb(main):006:0> pw = client.password_lists.first.passwords.create title: 'example', user_name: 'someone', generate_password: true
=> #<Passwordstate::Resources::Password:0x0000555fdaf9ce98 @title="example", @user_name="someone", @account_type_id=0, @password="[ REDACTED ]", @allow_export=true, @password_id=12, @generate_password=true, @password_list_id=6>
irb(main):007:0> pw.password
=> "millionfE2rMrcb2LngBTHnDyxdpsGSmK3"
irb(main):008:0> pw.delete
=> true
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ananace/ruby-passwordstate
The project lives at https://gitlab.liu.se/ITI/ruby-passwordstate

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
