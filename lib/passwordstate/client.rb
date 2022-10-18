# frozen_string_literal: true

require 'json'

module Passwordstate
  class Client
    USER_AGENT = "RubyPasswordstate/#{Passwordstate::VERSION}"
    DEFAULT_HEADERS = {
      'accept' => 'application/json',
      'user-agent' => USER_AGENT
    }.freeze

    attr_accessor :server_url, :auth_data, :headers, :validate_certificate
    attr_reader :timeout
    attr_writer :api_type

    def initialize(url, options = {})
      @server_url = URI(url)
      @validate_certificate = true
      @headers = DEFAULT_HEADERS
      @auth_data = options.select { |k, _v| %i[apikey username password].include? k }
      @api_type = options.fetch(:api_type) if options.key? :api_type
      @timeout = options.fetch(:timeout, 15)
    end

    def logger
      @logger ||= Logging.logger[self]
    end

    def api_type
      @api_type || (auth_data.key?(:apikey) ? :api : :winapi)
    end

    def timeout=(sec)
      @timeout = sec
      @http.read_timeout = sec if @http
    end

    def address_book
      ResourceList.new Passwordstate::Resources::AddressBook,
                       client: self
    end

    def folders
      ResourceList.new Passwordstate::Resources::Folder,
                       client: self,
                       only: %i[all search post]
    end

    def hosts
      ResourceList.new Passwordstate::Resources::Host,
                       client: self,
                       except: %i[search put]
    end

    def passwords
      ResourceList.new Passwordstate::Resources::Password,
                       client: self
    end

    def password_lists
      ResourceList.new Passwordstate::Resources::PasswordList,
                       client: self,
                       except: %i[put delete]
    end

    def valid?
      version
      true
    rescue StandardError
      false
    end

    def version
      @version ||= begin
        html = request(:get, '', allow_html: true)
        version = html.find_line { |line| line.include? '<span>V</span>' }
        version = />(\d\.\d) \(Build (.+)\)</.match(version)
        "#{version[1]}.#{version[2]}" if version
      end
    end

    def version?(compare)
      if version.nil?
        logger.debug 'Unable to detect Passwordstate version, assuming recent enough.'
        return true
      end

      Gem::Dependency.new(to_s, compare).match?(to_s, version)
    end

    def require_version(compare)
      if version.nil?
        logger.debug 'Unable to detect Passwordstate version, assuming recent enough.'
        return true
      end

      raise "Your version of Passwordstate (#{version}) doesn't support the requested feature" unless version? compare
    end

    def request(method, api_path, query: nil, reason: nil, **options)
      uri = URI(server_url + "/#{api_type}/" + api_path)
      uri.query = URI.encode_www_form(query) unless query.nil?
      uri.query = nil if uri.query.nil? || uri.query.empty?

      req_obj = Net::HTTP.const_get(method.to_s.capitalize.to_sym).new uri
      if options.key? :body
        req_obj.body = options.fetch(:body)
        req_obj.body = req_obj.body.to_json unless req_obj.body.is_a?(String)
        req_obj['content-type'] = 'application/json'
      end

      req_obj.ntlm_auth(auth_data[:username], auth_data[:password]) if api_type == :winapi
      headers.each { |h, v| req_obj[h] = v }
      req_obj['APIKey'] = auth_data[:apikey] if api_type == :api
      req_obj['Reason'] = reason if !reason.nil? && version?('>= 8.4.8449')

      print_http req_obj
      res_obj = http.request req_obj
      print_http res_obj

      return true if res_obj.is_a? Net::HTTPNoContent

      data = JSON.parse(res_obj.body) rescue nil
      if data
        return data if res_obj.is_a? Net::HTTPSuccess

        # data = data.first if data.is_a? Array
        # parsed = data.fetch('errors', []) if data.is_a?(Hash) && data.key?('errors')
        parsed = [data].flatten

        raise Passwordstate::HTTPError.new_by_code(res_obj.code, req_obj, res_obj, parsed || [])
      else
        return res_obj.body if res_obj.is_a?(Net::HTTPSuccess) && options.fetch(:allow_html, true)

        raise Passwordstate::HTTPError.new_by_code(res_obj.code, req_obj, res_obj, [{ 'message' => res_obj.body }])
      end
    end

    def pretty_print_instance_variables
      instance_variables.reject { |k| %i[@auth_data @http @logger].include? k }.sort
    end

    def pretty_print(pp)
      pp.pp(self)
    end

    alias inspect pretty_print_inspect

    private

    def http
      @http ||= Net::HTTP.new server_url.host, server_url.port
      return @http if @http.active?

      @http.read_timeout = @timeout if @timeout
      @http.use_ssl = server_url.scheme == 'https'
      @http.verify_mode = validate_certificate ? ::OpenSSL::SSL::VERIFY_NONE : nil
      @http.start
    end

    def print_http(http, truncate: true)
      return unless logger.debug?

      if http.is_a? Net::HTTPRequest
        dir = '>'
        logger.debug "#{dir} Sending a #{http.method} request to `#{http.path}`:"
      else
        dir = '<'
        logger.debug "#{dir} Received a #{http.code} #{http.message} response:"
      end
      http.to_hash.map { |k, v| "#{k}: #{%w[authorization apikey].include?(k.downcase) ? '[redacted]' : v.join(', ')}" }.each do |h|
        logger.debug "#{dir} #{h}"
      end
      logger.debug dir

      return if http.body.nil?

      body_cleaner = lambda do |obj|
        obj.each { |k, v| v.replace('[ REDACTED ]') if k.is_a?(String) && %w[password apikey].include?(k.downcase) } if obj.is_a? Hash
      end

      clean_body = JSON.parse(http.body) rescue nil
      if clean_body
        if clean_body.is_a? Array
          clean_body.each { |val| body_cleaner.call(val) }
        else
          body_cleaner.call(clean_body)
        end
      else
        clean_body = http.body
      end

      clean_body = clean_body.slice(0..2000) + "... [truncated, #{clean_body.length} Bytes total]" if truncate && clean_body.length > 2000
      logger.debug "#{dir} #{clean_body}" if clean_body
    end
  end
end
