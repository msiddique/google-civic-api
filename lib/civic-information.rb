# frozen_string_literal: true

require 'net/http'

class CivicInformation
  URL = 'https://www.googleapis.com/civicinfo/v2/'

  def initialize(api_key)
    @key = api_key
  end

  def list_elections
    make_request('elections')
  end

  private

  def make_request(resource = '', params = {})
    uri = URI(URL + resource)
    params.merge!(key: @key)
    uri.query = URI.encode_www_form(params)

    res = Net::HTTP.get_response(uri)
    puts res.code
    puts res.body.to_json
    puts res.body if res.is_a?(Net::HTTPSuccess)
  end
end
