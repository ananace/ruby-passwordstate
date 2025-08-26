# frozen_string_literal: true

module Passwordstate
  # A simple resource DSL helper
  #
  # rubocop:disable Metrics/ClassLength This DSL class will be large
  class Resource
    attr_reader :client

    # Update the object based off of up-to-date upstream data
    # @return [Resource] self
    def get(**query)
      set! self.class.get(client, send(self.class.index_field), **query)
    end

    # Push any unapplied changes to the object
    # @return [Resource] self
    def put(body = {}, **query)
      to_send = modified.merge(self.class.index_field => send(self.class.index_field))
      set! self.class.put(client, to_send.merge(body), **query).first
    end

    # Create the object based off of provided information
    # @return [Resource] self
    def post(body = {}, **query)
      set! self.class.post(client, attributes.merge(body), **query)
    end

    # Delete the object
    # @return [Resource] self
    def delete(**query)
      self.class.delete(client, send(self.class.index_field), **query)
    end

    def initialize(data)
      @client = data.delete :_client
      set! data
    end

    # Is the object stored on the Passwordstate server
    def stored?
      !send(self.class.index_field).nil?
    end

    # Check if the resource type is available on the connected Passwordstate server
    def self.available?(_client)
      true
    end

    # Retrieve all accessible instances of the resource type, requires the method :get
    def self.all(client, **query)
      raise NotAcceptableError, "Read is not implemented for #{self}" unless acceptable_methods.include? :get

      path = query.fetch(:_api_path, api_path)
      reason = query.delete(:_reason)
      query = passwordstateify_hash query.reject { |k| k.to_s.start_with? '_' }

      [client.request(:get, path, query: query, reason: reason)].flatten.map do |object|
        new object.merge(_client: client)
      end
    end

    # Retrieve a specific instance of the resource type, requires the method :get
    def self.get(client, object, **query)
      raise NotAcceptableError, "Read is not implemented for #{self}" unless acceptable_methods.include? :get

      object = object.send(object.class.send(index_field)) if object.is_a? Resource

      return new _client: client, index_field => object if query[:_bare]

      path = query.fetch(:_api_path, api_path)
      reason = query.delete(:_reason)
      query = passwordstateify_hash query.reject { |k| k.to_s.start_with? '_' }

      resp = client.request(:get, "#{path}/#{object}", query: query, reason: reason).map do |data|
        new data.merge(_client: client)
      end
      return resp.first if resp.one? || resp.empty?

      resp
    end

    # Create a new instance of the resource type, requires the method :post
    def self.post(client, data, **query)
      raise NotAcceptableError, "Create is not implemented for #{self}" unless acceptable_methods.include? :post

      path = query.fetch(:_api_path, api_path)
      reason = query.delete(:_reason)
      data = passwordstateify_hash data
      query = passwordstateify_hash query.reject { |k| k.to_s.start_with? '_' }

      new [client.request(:post, path, body: data, query: query, reason: reason)].flatten.first.merge(_client: client)
    end

    # Push new data to an instance of the resource type, requires the method :put
    def self.put(client, data, **query)
      raise NotAcceptableError, "Update is not implemented for #{self}" unless acceptable_methods.include? :put

      path = query.fetch(:_api_path, api_path)
      reason = query.delete(:_reason)
      data = passwordstateify_hash data
      query = passwordstateify_hash query.reject { |k| k.to_s.start_with? '_' }

      client.request :put, path, body: data, query: query, reason: reason
    end

    # Delete an instance of the resource type, requires the method :delete
    def self.delete(client, object, **query)
      raise NotAcceptableError, "Delete is not implemented for #{self}" unless acceptable_methods.include? :delete

      path = query.fetch(:_api_path, api_path)
      reason = query.delete(:_reason)
      query = passwordstateify_hash query.reject { |k| k.to_s.start_with? '_' }

      object = object.send(object.class.send(index_field)) if object.is_a? Resource
      client.request :delete, "#{path}/#{object}", query: query, reason: reason
    end

    # Get a hash of all active attributes on the resource instance
    #
    # @param ignore_redact [Boolean] Should any normally redacted fields be displayed in clear-text
    # @param atify [Boolean] Should the resulting hash be returned with instance variable names ('@'-prefixed)
    # @option opts nil_as_string [Boolean] (resource dependent) Should nil values be treated as the empty string
    def attributes(ignore_redact: true, atify: false, **opts)
      nil_as_string = opts.fetch(:nil_as_string, self.class.nil_as_string)
      (self.class.send(:accessor_field_names) + self.class.send(:read_field_names) + self.class.send(:write_field_names)).to_h do |field|
        redact = self.class.send(:field_options)[field]&.fetch(:redact, false) && !ignore_redact
        at_field = :"@#{field}"
        field = at_field if atify
        value = instance_variable_get(at_field) unless redact
        value = '[ REDACTED ]' if redact
        value = '' if value.nil? && nil_as_string
        [field, value]
      end.compact
    end

    def pretty_print(pp)
      pp.object_address_group(self) do
        attrs = attributes(atify: true, nil_as_string: false, ignore_redact: false).compact
        pp.seplist(attrs.keys.sort, -> { pp.text ',' }) do |v|
          pp.breakable
          v = v.to_s if v.is_a? Symbol
          pp.text v
          pp.text '='
          pp.group(1) do
            pp.breakable ''
            pp.pp(attrs[v.to_sym])
          end
        end
      end
    end

    def modified?(field = nil)
      return modified.any? unless field

      modified.include? field
    end

    protected

    def api_path
      self.class.instance_variable_get :@api_path
    end

    def modified
      @modified ||= {}
    end

    def set!(data, reset_modified = true)
      @modified = {} if reset_modified
      data = data.attributes if data.is_a? Passwordstate::Resource
      data.each do |key, value|
        field = self.class.passwordstate_to_ruby_field(key)
        opts = self.class.send(:field_options)[field]

        value = nil if value.is_a?(String) && value.empty?

        if !value.nil? && opts&.key?(:is)
          klass = opts.fetch(:is)
          parsed_value = klass.send :parse, value rescue nil if klass.respond_to?(:parse)
          parsed_value ||= klass.send :new, value rescue nil if klass.respond_to?(:new) && !klass.respond_to?(:parse)
        elsif !value.nil? && opts&.key?(:convert)
          convert = opts.fetch(:convert)
          parsed_value = convert.call(value, direction: :from)
        end

        instance_variable_set :"@#{field}", parsed_value || value
      end
      self
    end

    class << self
      alias search all

      # Get/Set the API path for the resource type
      def api_path(path = nil)
        @api_path = path unless path.nil?
        @api_path
      end

      # Get/Set the index field for the resource type
      def index_field(field = nil)
        @index_field = field unless field.nil?
        @index_field
      end

      # Get/Set whether the resource type requires nil values to be handled as the empty string
      def nil_as_string(opt = nil)
        @nil_as_string = opt unless opt.nil?
        @nil_as_string
      end

      # Get/Set acceptable CRUD methods for the resource type
      def acceptable_methods(*meths)
        if meths.empty?
          @acceptable_methods || %i[post get put delete]
        elsif meths.count == 1 && meths.to_s.upcase == meths.to_s
          @acceptable_methods = []
          meths = meths.first.to_s
          @acceptable_methods << :post if meths.include? 'C'
          @acceptable_methods << :get if meths.include? 'R'
          @acceptable_methods << :put if meths.include? 'U'
          @acceptable_methods << :delete if meths.include? 'D'
        else
          @acceptable_methods = meths
        end
      end

      # Convert a hash from Ruby syntax to Passwordstate syntax
      def passwordstateify_hash(hash)
        hash.transform_keys { |k| ruby_to_passwordstate_field(k) }
      end

      # Convert a Passwordstate field name into Ruby syntax
      def passwordstate_to_ruby_field(field)
        opts = send(:field_options).find { |(_k, v)| v[:name] == field }
        opts&.first || field.to_s.snake_case.to_sym
      end

      # Convert a Ruby field name into Passwordstate syntax
      def ruby_to_passwordstate_field(field)
        send(:field_options)[field]&.[](:name) || field.to_s.camel_case
      end

      protected

      def accessor_field_names
        @accessor_field_names ||= []
      end

      def read_field_names
        @read_field_names ||= []
      end

      def write_field_names
        @write_field_names ||= []
      end

      def field_options
        @field_options ||= {}
      end

      def read_only
        # TODO
      end

      def accessor_fields(*fields)
        fields.each do |field|
          if field.is_a? Symbol
            accessor_field_names << field
            attr_reader field
            build_writer_method field
          else
            field_options[accessor_field_names.last] = field
          end
        end
      end

      def read_fields(*fields)
        fields.each do |field|
          if field.is_a? Symbol
            read_field_names << field
            attr_reader field
          else
            field_options[read_field_names.last] = field
          end
        end
      end

      def write_fields(*fields)
        fields.each do |field|
          if field.is_a? Symbol
            write_field_names << field
            build_writer_method field
          else
            field_options[write_field_names.last] = field
          end
        end
      end

      private

      def build_writer_method(field)
        field = field.to_s.to_sym unless field.is_a? Symbol
        define_method(:"#{field}=") do |arg|
          return arg if send(field) == arg

          instance_variable_set "@#{field}", arg
          modified[field] = arg
        end
      end
    end
  end
  # rubocop:enable Metrics/ClassLength

  module Resources
    autoload :ActiveDirectory,             'passwordstate/resources/active_directory'
    autoload :AddressBook,                 'passwordstate/resources/address_book'
    autoload :Document,                    'passwordstate/resources/document'
    autoload :Folder,                      'passwordstate/resources/folder'
    autoload :FolderPermission,            'passwordstate/resources/folder'
    autoload :Host,                        'passwordstate/resources/host'
    autoload :Password,                    'passwordstate/resources/password'
    autoload :PasswordList,                'passwordstate/resources/password_list'
    autoload :PasswordListPermission,      'passwordstate/resources/password_list'
    autoload :PasswordHistory,             'passwordstate/resources/password'
    autoload :PasswordPermission,          'passwordstate/resources/password'
    autoload :PrivilegedAccount,           'passwordstate/resources/privileged_account'
    autoload :PrivilegedAccountPermission, 'passwordstate/resources/privileged_account'
    autoload :Permission,                  'passwordstate/resources/permission'
    autoload :Report,                      'passwordstate/resources/report'
  end
end
