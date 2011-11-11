require 'spec_helper'

class User < ActiveRecord::Base
  include Janrain::Capture::User
end

describe User do
  it { should respond_to :entity= }
  it { should respond_to :oauth= }

  describe "authenticate" do
    it "should authenticate with a valid code" do
      User.authenticate('a_valid_code').should be_a User
    end

    it "should not authenticate with an invalid code" do
      User.authenticate('an_invalid_code').should be_false
    end
  end

  describe "user session (oauth)" do
    before :each do
      @oauth_params = {
        'access_token' => 'yoyoyo',
        'refresh_token' => 'yayaya',
        'expires_in' => 3600,
      }

      @time = Time.now
      Time.stub(:now).and_return(@time) # ouch
      @user = User.new(
        oauth: @oauth_params
      )
    end

    it "should update user capture session cache for access_token" do
      @user.access_token.should == 'yoyoyo'
    end

    it "should update user capture session cache for refresh_token" do
      @user.refresh_token.should == 'yayaya'
    end

    it "should update user capture session cache for expires at" do
      @user.expires_at.should == @time + @oauth_params['expires_in'].seconds
    end

  end

  describe "user entity cache (entity)" do
    before :each do
      @time = Time.parse('2011-11-05 19:00:08.339082 +0000')
      @entity_params = {
        'result' => {
          'aboutMe' => 'hello',
          'birthday'=> '7/20/78',
          'created' => '2011-11-05 19:00:08.339082 +0000',
          'displayName' => 'Chuck Norris',
          'email' => 'chuck@1.com',
          'emailVerified' => '2011-11-05 19:00:08.339082 +0000',
          'lastLogin' => '2011-11-05 19:00:08.339082 +0000',
          'lastUpdated' => '2011-11-05 19:00:08.339082 +0000',
        }
      }
      @user = User.new(entity: @entity_params)
      @entity_result = @entity_params['result']
    end

    it "should import fields that map directly (simple case)" do
      @user.display_name.should == @entity_result['displayName']
    end

    it "should not import fields that do not map and dont exist" do
      @user.should_not respond_to :email_verified
    end

    it "should support field mapping overrides" do
      @user.birthdate.should == @entity_result['birthday']
    end

  end

end

