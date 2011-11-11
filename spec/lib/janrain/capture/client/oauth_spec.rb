require 'spec_helper'

describe Janrain::Capture::Client::Oauth do
  include Janrain::Capture::Client

  context "valid code" do
    it "should get the janrain auth token" do
      Oauth.token('a_valid_code').should be_a Hash
    end

    it "should get the json response" do
      Oauth.token('a_valid_code')['stat'].should == 'ok'
    end
  end

  context "invalid" do
    it "should get the json response" do
      Oauth.token('an_invalid_code').should be_a Hash
    end

    it "should get the json response" do
      Oauth.token('an_invalid_code')['stat'].should == 'error'
    end
  end

end
