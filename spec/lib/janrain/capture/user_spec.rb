require 'spec_helper'

describe TestUser do
  it { should respond_to :entity= }
  it { should respond_to :oauth= }

  before :each do
    @oauth_params = {
      'access_token' => 'yoyoyo',
      'refresh_token' => 'yayaya',
      'expires_in' => 3600,
    }
  end

  describe "authenticate" do
    it "should authenticate with a valid code" do
      TestUser.authenticate('a_valid_code').should be_a TestUser
    end

    it "should not authenticate with an invalid code" do
      TestUser.authenticate('an_invalid_code').should be_false
    end
  end

  describe "user session (oauth)" do
    before :each do
      @time = Time.now
      Time.stub(:now).and_return(@time) # ouch
      @user = TestUser.new(
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
          'id' => 7,
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
      @entity_result = @entity_params['result']
      @user = TestUser.find_or_initialize_by_capture_id(@entity_result['id'])
      @user.update_attributes(entity: @entity_params, oauth: @oauth_params)
    end

    it "should create or update user but the capture id should not override id" do
      @user.id.should_not == 7
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

