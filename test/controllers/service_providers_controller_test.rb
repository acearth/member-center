require 'test_helper'

class ServiceProvidersControllerTest < ActionDispatch::IntegrationTest
  setup do
    @service_provider = service_providers(:one)
  end
end
