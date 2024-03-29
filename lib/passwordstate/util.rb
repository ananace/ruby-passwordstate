# frozen_string_literal: true

require 'net/http'
require 'net/ntlm'

module Net
  # NTLM header extension
  #
  # @example Setting NTLM auth
  #   req = Net::HTTP::Get.new URI('https://example.com')
  #   req.ntlm_auth 'username', 'password'
  module HTTPHeader
    attr_reader :ntlm_auth_information, :ntlm_auth_options

    def ntlm_auth(username, password, domain = nil, workstation = nil)
      @ntlm_auth_information = {
        user: username,
        password: password
      }
      @ntlm_auth_information[:domain] = domain unless domain.nil?
      @ntlm_auth_options = {
        ntlmv2: true
      }
      @ntlm_auth_options[:workstation] = workstation unless workstation.nil?
    end
  end
end

class String
  # Convert a snake_case string to CamelCase
  def camel_case
    split('_').collect(&:capitalize).join
  end

  # Convert a CamelCase string to snake_case
  def snake_case
    gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
      .gsub(/([a-z\d])([A-Z])/, '\1_\2')
      .tr('-', '_')
      .downcase
  end

  # Find a specific line in a block of text
  def find_line(&_block)
    raise ArgumentError, 'No block given' unless block_given?

    each_line do |line|
      return line if yield line
    end
  end
end

module Passwordstate
  # Extensions on Net::HTTP to allow NTLM digest auth
  #
  # @example Using NTLM auth
  #   uri = URI('https://example.com/some_object')
  #   Net::HTTP.start uri.host, uri.port { |http|
  #     req = Net::HTTP::Get.new uri
  #     req.ntlm_auth 'username', 'password'
  #
  #     http.request req
  #   }
  module NetHTTPExtensions
    def request(req, body = nil, &block)
      return super(req, body, &block) if req.ntlm_auth_information.nil?

      unless started?
        @last_body = req.body
        req.body = nil
        start do
          req.delete('connection')
          return request(req, body, &block)
        end
      end

      type1 = Net::NTLM::Message::Type1.new
      req['authorization'] = "NTLM #{type1.encode64}"
      res = super(req, body)

      challenge = res['www-authenticate'][/(?:NTLM|Negotiate) (.+)/, 1]

      if challenge && res.code == '401'
        type2 = Net::NTLM::Message.decode64 challenge
        type3 = type2.response(req.ntlm_auth_information, req.ntlm_auth_options.dup)

        req['authorization'] = "NTLM #{type3.encode64}"
        req.body_stream.rewind if req.body_stream
        req.body = @last_body if @last_body

        super(req, body, &block)
      else
        yield res if block_given?
        res
      end
    end
  end
end

Net::HTTP.prepend Passwordstate::NetHTTPExtensions unless Net::HTTP.ancestors.include? Passwordstate::NetHTTPExtensions
