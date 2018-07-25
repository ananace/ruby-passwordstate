require 'json'

module Passwordstate
  class Client
    BASE_API = '/winapi/'.freeze

    USER_AGENT = "RubyPasswordstate/#{Passwordstate::VERSION}".freeze
    DEFAULT_HEADERS = {
      'content-type' => 'application/json',
      'accept'       => 'application/json',
      'user-agent'   => USER_AGENT
    }.freeze

    attr_accessor :server_url, :auth_data, :headers, :validate_certificate

    def initialize(url, options = {})
      @server_url = URI(url)
      @validate_certificate = true
      @headers = DEFAULT_HEADERS
      @auth_data = options.select { |k, _v| %i[username password].include? k }
    end

    def logger
      @logger ||= Logging.logger['Passwordstate::Client']
    end

    def request(method, api_path, options = {})
      uri = URI(server_url + BASE_API + api_path)
      uri.query = URI.encode_www_form(options.fetch(:query)) if options.key? :query
      uri.query = nil if uri.query&.empty?

      req_obj = Net::HTTP.const_get(method.to_s.capitalize.to_sym).new uri
      if options.key? :body
        req_obj.body = options.fetch(:body)
        req_obj.body = req_obj.body.to_json unless req_obj.body.is_a?(String)
      end

      req_obj.ntlm_auth(auth_data[:username], auth_data[:password])
      headers.each { |h, v| req_obj[h] = v }

      print_http req_obj
      res_obj = http.request req_obj
      print_http res_obj

      return true if res_obj.is_a? Net::HTTPNoContent

      data = JSON.parse(res_obj.body) rescue nil

      return data if res_obj.is_a? Net::HTTPSuccess
      data = data&.first
      raise Passwordstate::HTTPError.new(res_obj.code, data&.fetch('errors', []) || [])
    end

    private

    def http
      @http ||= Net::HTTP.new server_url.host, server_url.port
      return @http if @http.active?

      @http.use_ssl = server_url.scheme == 'https'
      @http.verify_mode = validate_certificate ? ::OpenSSL::SSL::VERIFY_NONE : nil
      @http.start
    end

    def print_http(http)
      return unless logger.debug?

      if http.is_a? Net::HTTPRequest
        dir = '>'
        logger.debug "#{dir} Sending a #{http.method} request to `#{http.path}`:"
      else
        dir = '<'
        logger.debug "#{dir} Received a #{http.code} #{http.message} response:"
      end
      http.to_hash.map { |k, v| "#{k}: #{k == 'authorization' ? '[redacted]' : v.join(', ')}" }.each do |h|
        logger.debug "#{dir} #{h}"
      end
      logger.debug dir

      return if http.body.nil?
      clean_body = JSON.parse(http.body) rescue nil
      if clean_body
        clean_body = clean_body.each { |k, v| v.replace('[redacted]') if %w[password access_token].include? k }.to_json if http.body
      else
        clean_body = http.body
      end
      logger.debug "#{dir} #{clean_body.length < 200 ? clean_body : clean_body.slice(0..200) + "... [truncated, #{clean_body.length} Bytes]"}" if clean_body
    end
  end
end
