require 'spec_helper'

describe Janrain::Config do
  include Janrain

  context 'capture configuration' do
    it "should have env configuration" do
      Config.capture.should be_a OpenStruct
    end

    it "should have domain" do
      Config.capture.domain.should_not be_nil
    end

    it "should have secret" do
      Config.capture.client_secret.should_not be_nil
    end

    it "should have client id" do
      Config.capture.client_id.should_not be_nil
    end

    it "should have redirect url" do
      Config.capture.redirect_url.should_not be_nil
    end

    context "entity" do
      it "should have entity configuration" do
        Config.capture.entity.should be_a Hash
      end

      it "should have entity configuration ignore columns" do
        Config.capture.entity['ignore_columns'].should be_a Array
        Config.capture.entity['ignore_columns'].should include 'aboutMe'
        Config.capture.entity['ignore_columns'].should_not include 'emailVerified'
      end

      it "should have column mappings" do
        Config.capture.entity['mappings'].should be_a Hash
        Config.capture.entity['mappings']['birthday'].should == 'birthdate'
      end
    end
  end

end
