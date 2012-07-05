require 'spec_helper'

describe Janrain::Config do
  include Janrain

  context 'capture configuration' do
    it "should have env configuration" do
      Config.capture.should be_a OpenStruct
    end

    it "should have model as class" do
      Config.model.should == TestUser
    end

    it "should have controller as string" do
      Config.controller.should == 'session'
    end

    it "should have a within iframe flag" do
      Config.should be_within_iframe
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

    context "redirect_url" do

      it "should have redirect url" do
        Config.capture.redirect_url.should_not be_nil
      end

      it "should have redirect url that takes a hostname as an optional override" do
        Config.redirect_url(host:'www.other.host.com').should include '://www.other.host.com'
      end

      it "should have redirect url that takes a origin parameter as an option" do
        Config.redirect_url(origin:'http://www.other.host.com/?a=1#b=2').should include 'http://mysite.com/auth?origin=http%3A%2F%2Fwww.other.host.com%2F%3Fa%3D1%23b%3D2'
      end
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

      it "should have entity schema type name" do
        Config.capture.entity['schema_type_name'].should == 'user'
      end
    end
  end

end
