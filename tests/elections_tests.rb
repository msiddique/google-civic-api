# frozen_string_literal: true

require 'minitest/autorun'
require 'lib/civic-information'

describe CivicInformation do
  api_key = ''
  before do
    @civic_info = CivicInformation.new(api_key)
  end
end
