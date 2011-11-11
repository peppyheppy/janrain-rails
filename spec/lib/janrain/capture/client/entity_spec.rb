require 'spec_helper'

describe Janrain::Capture::Client::Entity do
  include Janrain::Capture::Client

  describe "entity by Authorization Oauth header" do
    it 'should return entity with a valid access token' do
      Entity.by_token('a_valid_token').should be_a Hash
      Entity.by_token('a_valid_token')['stat'].should == 'ok'
    end

    it 'should not return an entity of the access token is invalid' do
      Entity.by_token('an_invalid_token').should be_a Hash
      Entity.by_token('an_invalid_token')['stat'].should == 'error'
    end
  end

end
