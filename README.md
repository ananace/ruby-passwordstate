# Passwordstate

A ruby gem for communicating with a Password state instance

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'passwordstate'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install passwordstate

## Usage

```ruby
require 'passwordstate'

client = Passwordstate::Client.new 'https://passwordstate'
client.auth_data = { username: 'user', password: 'password' }

folders = Passwordstate::Resources::Folder.all(client)
=> [#<Passwordstate::Resources::Folder:0x000055ed493636e8 @folder_name="Example", @folder_id=2, @tree_path="\\Example">, #<Passwordstate::Resources::Folder:0x000055ed49361fa0 @folder_name="Folder", @folder_id=3, @tree_path="\\Example\\Folder">]
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/ananace/ruby-passwordstate
The project lives at https://gitlab.liu.se/ITI/ruby-passwordstate

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
