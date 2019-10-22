module Passwordstate
  # A simple resource DSL
  class Resource
    attr_reader :client

    def get(query = {})
      set! self.class.get(client, send(self.class.index_field), query)
    end

    def put(body = {}, query = {})
      to_send = modified.merge(self.class.index_field => send(self.class.index_field))
      set! self.class.put(client, to_send.merge(body), query).first
    end

    def post(body = {}, query = {})
      set! self.class.post(client, attributes.merge(body), query)
    end

    def delete(query = {})
      self.class.delete(client, send(self.class.index_field), query)
    end

    def initialize(data)
      @client = data.delete :_client
      set! data, false
      old
    end

    def stored?
      !send(self.class.index_field).nil?
    end

    def self.available?(_client)
      true
    end

    def self.all(client, query = {})
      path = query.fetch(:_api_path, api_path)
      query = passwordstateify_hash query.reject { |k| k.to_s.start_with? '_' }

      [client.request(:get, path, query: query)].flatten.map do |object|
        new object.merge(_client: client)
      end
    end

    def self.get(client, object, query = {})
      object = object.send(object.class.send(index_field)) if object.is_a? Resource

      if query[:_bare]
        return new _client: client, index_field => object
      end

      path = query.fetch(:_api_path, api_path)
      query = passwordstateify_hash query.reject { |k| k.to_s.start_with? '_' }

      resp = client.request(:get, "#{path}/#{object}", query: query).map do |data|
        new data.merge(_client: client)
      end
      return resp.first if resp.one? || resp.empty?
      resp
    end

    def self.post(client, data, query = {})
      path = query.fetch(:_api_path, api_path)
      data = passwordstateify_hash data
      query = passwordstateify_hash query.reject { |k| k.to_s.start_with? '_' }

      new [client.request(:post, path, body: data, query: query)].flatten.first.merge(_client: client)
    end

    def self.put(client, data, query = {})
      path = query.fetch(:_api_path, api_path)
      data = passwordstateify_hash data
      query = passwordstateify_hash query.reject { |k| k.to_s.start_with? '_' }

      client.request :put, path, body: data, query: query
    end

    def self.delete(client, object, query = {})
      path = query.fetch(:_api_path, api_path)
      query = passwordstateify_hash query.reject { |k| k.to_s.start_with? '_' }

      object = object.send(object.class.send(index_field)) if object.is_a? Resource
      client.request :delete, "#{path}/#{object}", query: query
    end

    def self.passwordstateify_hash(hash)
      Hash[hash.map  { |k, v| [ruby_to_passwordstate_field(k), v] }]
    end

    def api_path
      self.class.instance_variable_get :@api_path
    end

    def attributes(opts = {})
      ignore_redact = opts.fetch(:ignore_redact, true)
      nil_as_string = opts.fetch(:nil_as_string, self.class.nil_as_string)
      Hash[(self.class.send(:accessor_field_names) + self.class.send(:read_field_names) + self.class.send(:write_field_names)).map do |field|
        redact = self.class.send(:field_options)[field]&.fetch(:redact, false) && !ignore_redact
        value = instance_variable_get("@#{field}".to_sym) unless redact
        value = '[ REDACTED ]' if redact
        value = '' if value.nil? && nil_as_string
        [field, value]
      end].reject { |_k, v| v.nil? }
    end

    def inspect
      "#{to_s[0..-2]} #{attributes(nil_as_string: false, ignore_redact: false).reject { |_k, v| v.nil? }.map { |k, v| "@#{k}=#{v.inspect}" }.join(', ')}>"
    end

    protected

    def modified
      attribs = attributes
      attribs.reject { |field| old[field] == attribs[field] }
    end

    def modified?(field)
      modified.include? field
    end

    def old
      @old ||= attributes.dup
    end

    def set!(data, store_old = true)
      @old = attributes.dup if store_old
      data = data.attributes if data.is_a? Passwordstate::Resource
      data.each do |key, value|
        field = self.class.passwordstate_to_ruby_field(key)
        opts = self.class.send(:field_options)[field]

        value = nil if value.is_a?(String) && value.empty?

        if !value.nil? && opts&.key?(:is)
          klass = opts.fetch(:is)
          parsed_value = klass.send :parse, value rescue nil if klass.respond_to? :parse
          parsed_value ||= klass.send :new, value rescue nil if klass.respond_to? :new
        end

        instance_variable_set "@#{field}".to_sym, parsed_value || value
      end
      self
    end

    class << self
      alias search all

      def api_path(path = nil)
        @api_path = path unless path.nil?
        @api_path
      end

      def index_field(field = nil)
        @index_field = field unless field.nil?
        @index_field
      end

      def nil_as_string(opt = nil)
        @nil_as_string = opt unless opt.nil?
        @nil_as_string
      end

      def passwordstate_to_ruby_field(field)
        opts = send(:field_options).find { |(_k, v)| v[:name] == field }
        opts&.first || field.to_s.snake_case.to_sym
      end

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
            attr_accessor field
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
            attr_writer field
          else
            field_options[write_field_names.last] = field
          end
        end
      end
    end
  end

  module Resources
    autoload :Document,               'passwordstate/resources/document'
    autoload :Folder,                 'passwordstate/resources/folder'
    autoload :FolderPermission,       'passwordstate/resources/folder'
    autoload :Host,                   'passwordstate/resources/host'
    autoload :PasswordList,           'passwordstate/resources/password_list'
    autoload :PasswordListPermission, 'passwordstate/resources/password_list'
    autoload :Password,               'passwordstate/resources/password'
    autoload :PasswordHistory,        'passwordstate/resources/password'
    autoload :PasswordPermission,     'passwordstate/resources/password_list'
    autoload :Permission,             'passwordstate/resources/permission'
    autoload :Report,                 'passwordstate/resources/report'
  end
end
