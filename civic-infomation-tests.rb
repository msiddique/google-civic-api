# frozen_string_literal: true

require 'json'
require 'minitest/autorun'
require 'net/http'
require 'date'

class CivicInformation
  URL = 'https://www.googleapis.com/civicinfo/v2/'

  def initialize(api_key)
    @key = api_key
  end

  def list_elections
    make_request('elections')
  end

  def search_divisions(query)
    make_request('divisions', 'query': query)
  end

  private

  def make_request(resource = '', params = {})
    uri = URI(URL + resource)
    params.merge!(key: @key)
    uri.query = URI.encode_www_form(params)
    Net::HTTP.get_response(uri)
  end
end

# Tests
API_KEY = ENV['GOOGLE_API_KEY'] || ''

raise 'Please Enter API_KEY Above' if API_KEY == '' || API_KEY.nil?

describe CivicInformation do
  before do
    @civic_info = CivicInformation.new(API_KEY)
  end
  describe 'requesting elections info' do
    before do
      @response = @civic_info.list_elections
      @response_body = JSON(@response.body)
    end

    it 'must respond with a HTTP status 200' do
      _(@response.code).must_equal '200'
    end

    it 'must include the property kind in the response body' do
      _(@response_body.key?('kind')).must_equal true
      _(@response_body['kind']).must_equal 'civicinfo#electionsQueryResponse'
    end

    it 'must include array property elections in the response body' do
      _(@response_body.key?('elections')).must_equal true
      _(@response_body['elections']).must_be_kind_of Array
    end

    describe 'election object' do
      before do
        @election = @response_body['elections'].first
      end

      it 'must include name' do
        _(@election.key?('name')).must_equal true
        _(@election['name']).wont_be_empty
      end

      it 'must include id' do
        _(@election.key?('id')).must_equal true
        _(@election['id']).wont_be_empty
      end

      it 'must include election date' do
        _(@election.key?('electionDay')).must_equal true
        _(@election['electionDay']).wont_be_empty
        # Verify the date string is in the valid format
        _(@election['electionDay']).must_match /\d\d\d\d-\d\d-\d\d/
      end

      it 'must include ocdDivisionId' do
        _(@election.key?('ocdDivisionId')).must_equal true
        _(@election['ocdDivisionId']).wont_be_empty
      end
    end
  end

  describe 'searching for division' do
    before do
      @response = @civic_info.search_divisions('manhattan')
      @response_body = JSON(@response.body)
    end

    it 'must respond with a HTTP status of 200' do
      _(@response.code).must_equal '200'
    end

    it 'must include the property kind in the response body' do
      _(@response_body.key?('kind')).must_equal true
      _(@response_body['kind']).must_equal 'civicinfo#divisionSearchResponse'
    end

    it 'must include array property elections in the response body' do
      _(@response_body.key?('results')).must_equal true
      _(@response_body['results']).must_be_kind_of Array
    end

    describe 'result object' do
      before do
        @result = @response_body['results'].first
      end

      it 'must include name' do
        _(@result.key?('name')).must_equal true
        _(@result['name']).wont_be_empty
      end

      # Deliberately failing tests to see an failed scenario
      it 'must not include extra properties' do
        _(@result.keys).must_equal %w[ocdId name division]
      end
    end
  end
end

describe '#Requesting civic information with an invalid API key' do
  before do
    @civic_info = CivicInformation.new('Invalid Key')
    @response = @civic_info.list_elections
    @response_body = JSON(@response.body)
  end

  it 'must return a HTTP status of 400' do
    _(@response.code).must_equal '400'
  end

  it 'must include propery error' do
    _(@response_body.key?('error')).must_equal true
    _(@response_body['error']).must_be_kind_of Hash
  end

  it 'must include reason of keyInvalid' do
    _(@response_body['error']['errors'].first['reason']).must_equal 'keyInvalid'
  end
end
