module Passwordstate
  class ResourceList < Array
    Array.public_instance_methods(false).each do |method|
      next if %i[reject select slice clear inspect].include?(method.to_sym)
      class_eval <<-EVAL, __FILE__, __LINE__ + 1
        def #{method}(*args)
          lazy_load unless @loaded
          super
        end
      EVAL
    end

    %w[reject select slice].each do |method|
      class_eval <<-EVAL, __FILE__, __LINE__ + 1
        def #{method}(*args)
          lazy_load unless @loaded
          data = super
          self.clone.clear.concat(data)
        end
      EVAL
    end

    def inspect
      lazy_load unless @loaded
      super
    end

    attr_reader :client, :resource, :options

    def initialize(client, resource, options = {})
      @client = client
      @resource = resource
      @loaded = false
      @options = options
    end

    def clear
      @loaded = super
    end

    def reload
      clear && lazy_load
      self
    end

    def load(entries)
      clear && entries.each { |obj| self << obj }
      true
    end

    def new(data)
      resource.new options.fetch(:object_data, {}).merge(data).merge(_client: client)
    end

    def create(data)
      obj = resource.new options.fetch(:object_data, {}).merge(data).merge(_client: client)
      obj.post
      obj
    end

    def search(query = {})
      api_path = options.fetch(:search_path, resource.api_path)
      query = options.fetch(:search_query, {}).merge(query)

      resource.search(client, query.merge(_api_path: api_path))
    end

    def all(query = {})
      api_path = options.fetch(:all_path, resource.api_path)
      query = options.fetch(:all_query, {}).merge(query)

      load resource.all(client, query.merge(_api_path: api_path))
    end

    def get(id, query = {})
      api_path = options.fetch(:get_path, resource.api_path)
      query = options.fetch(:get_query, {}).merge(query)

      resource.get(client, id, query.merge(_api_path: api_path))
    end

    def post(data, query = {})
      api_path = options.fetch(:post_path, resource.api_path)
      query = options.fetch(:post_query, {}).merge(query)

      resource.post(client, data, query.merge(_api_path: api_path))
    end

    def put(data, query = {})
      api_path = options.fetch(:put_path, resource.api_path)
      query = options.fetch(:put_query, {}).merge(query)

      resource.put(client, data, query.merge(_api_path: api_path))
    end

    def delete(id, query = {})
      api_path = options.fetch(:delete_path, resource.api_path)
      query = options.fetch(:delete_query, {}).merge(query)

      resource.delete(client, id, query.merge(_api_path: api_path))
    end

    private

    def lazy_load
      all
    end
  end
end
