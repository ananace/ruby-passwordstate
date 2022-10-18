# frozen_string_literal: true

module Passwordstate
  class ResourceList
    include Enumerable

    attr_reader :client, :resource, :options

    def initialize(resource, client:, **options)
      @client = client
      @resource = resource
      @loaded = false
      @options = options
      @data = []

      options[:only] = [options[:only]].flatten if options.key? :only
      options[:except] = [options[:except]].flatten if options.key? :except
    end

    def pretty_print_instance_variables
      instance_variables.reject { |k| %i[@client @data].include? k }.sort
    end

    def pretty_print(pp)
      return pp.pp self if respond_to? :mocha_inspect

      pp.pp_object(self)
    end

    alias inspect pretty_print_inspect

    def each(&block)
      lazy_load unless @loaded

      return to_enum(__method__) { @data.size } unless block_given?

      @data.each(&block)
    end

    def [](index)
      @data[index]
    end

    def clear
      @data = []
      @loaded = false
    end

    def reload
      clear && lazy_load
      self
    end

    def load(entries)
      clear
      entries.tap do |loaded|
        loaded.sort! { |a, b| a.send(a.class.index_field) <=> b.send(b.class.index_field) } if options.fetch(:sort, true)
      end
      entries.each { |obj| @data << obj }
      @loaded = true
      self
    end

    def operation_supported?(operation)
      return nil unless %i[search all get post put delete].include?(operation)
      return false if options.key?(:only) && !options[:only].include?(operation)
      return false if options.key?(:except) && options[:except].include?(operation)

      !options.fetch("#{operation}_path".to_sym, '').nil?
    end

    def new(data)
      resource.new options.fetch(:object_data, {}).merge(data).merge(_client: client)
    end

    def create(data)
      raise 'Operation not supported' unless operation_supported?(:post)

      obj = resource.new options.fetch(:object_data, {}).merge(data).merge(_client: client)
      obj.post
      obj
    end

    def search(**query)
      raise 'Operation not supported' unless operation_supported?(:search)

      api_path = options.fetch(:search_path, resource.api_path)
      query = options.fetch(:search_query, {}).merge(query)

      resource.search(client, **query.merge(_api_path: api_path))
    end

    def all(**query)
      raise 'Operation not supported' unless operation_supported?(:all)

      api_path = options.fetch(:all_path, resource.api_path)
      query = options.fetch(:all_query, {}).merge(query)

      load resource.all(client, **query.merge(_api_path: api_path))
    end

    def get(id, **query)
      raise 'Operation not supported' unless operation_supported?(:get)

      if query.empty? && !@data.empty?
        existing = @data.find do |entry|
          entry.send(entry.class.index_field) == id
        end
        return existing if existing
      end

      api_path = options.fetch(:get_path, resource.api_path)
      query = options.fetch(:get_query, {}).merge(query)

      resource.get(client, id, **query.merge(_api_path: api_path))
    end

    def post(data, **query)
      raise 'Operation not supported' unless operation_supported?(:post)

      api_path = options.fetch(:post_path, resource.api_path)
      query = options.fetch(:post_query, {}).merge(query)

      resource.post(client, data, **query.merge(_api_path: api_path))
    end

    def put(data, **query)
      raise 'Operation not supported' unless operation_supported?(:put)

      api_path = options.fetch(:put_path, resource.api_path)
      query = options.fetch(:put_query, {}).merge(query)

      resource.put(client, data, **query.merge(_api_path: api_path))
    end

    def delete(id, **query)
      raise 'Operation not supported' unless operation_supported?(:delete)

      api_path = options.fetch(:delete_path, resource.api_path)
      query = options.fetch(:delete_query, {}).merge(query)

      resource.delete(client, id, **query.merge(_api_path: api_path))
    end

    private

    def lazy_load
      all
    end
  end
end
