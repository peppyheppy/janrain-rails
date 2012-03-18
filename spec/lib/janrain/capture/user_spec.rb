require 'spec_helper'

describe TestUser do
  it { should respond_to :entity= }
  it { should respond_to :oauth= }
  it { should respond_to :admin? }
  it { should respond_to :failed? }
  it { should respond_to :superuser? }
  it { should respond_to :change_privileges }
  it { should respond_to :to_capture }
  it { should respond_to :persist_to_capture }

  before :each do
    @oauth_params = {
      'access_token' => 'yoyoyo',
      'refresh_token' => 'yayaya',
      'expires_in' => 3600,
    }
    @user_params = {
      capture_id: "1",
      about_me: "hi there",
      display_name: "my name",
      email: "newuser@valid.com",
      last_login: Time.now,
    }
  end

  context "password parser" do
    it "should return an empty hash if password is null" do
      pass = TestUser.password_parser(nil)
      pass.should be_a Hash
      pass.should be_blank
    end

    it "should return an empty hash if password is empty string" do
      pass = TestUser.password_parser('')
      pass.should be_a Hash
      pass.should be_blank
    end

    it "should return an empty hash if password is non json/yaml string" do
      pass = TestUser.password_parser('hello hello')
      pass.should be_a Hash
      pass.should be_blank
    end

    it "should return an empty hash if password is not valid json/yaml" do
      pass = TestUser.password_parser('{ :dddd => :qqqq }')

      puts "YYYYY: #{pass.inspect}"

      pass.should be_a Hash
      pass.should be_blank
    end

    it "should parse valid json" do
      pass = TestUser.password_parser('{ "a": "b"}')
      pass.should be_a Hash
      pass.should_not be_blank
      pass['a'].should == 'b'
    end

    it "should parse valid yaml" do
      pass = TestUser.password_parser("--- \nvalue: p8ssw0rd\ntype: password-rr\nsalt: lee\n")
      pass.should be_a Hash
      pass.should_not be_blank
      pass['value'].should == 'p8ssw0rd'
      pass['type'].should == 'password-rr'
    end
  end

  context "capture persistence" do
    context "new capture user" do

      it "should send all new attributes to capture" do
        user = TestUser.new(@user_params.merge(capture_id: nil))
        user.persist_to_capture.should == 978
      end

      it "should send all new attributes to capture" do
        user = TestUser.new(@user_params.merge(capture_id: nil, email: 'newuser@invalid.com'))
        user.persist_to_capture.should be_nil
      end

    end

    context "update existing user" do

      it "should call persist to capture on save" do
        TestUser.any_instance.should_receive(:persist_to_capture).with(only_changes = true, persist = false)
        TestUser.create(@user_params)
      end

      it "should not update capture if there are not any changes" do
        user = TestUser.create(@user_params)
        # Note: no changes have been made
        user.persist_to_capture(only_changes = true).should == 1
      end

      it "should send changed attributes to capture VALID" do
        user = TestUser.create(@user_params)
        user.email = 'existinguser@valid.com'
        user.persist_to_capture(only_changes = true).should == 1
      end

      it "should send changed attributes to capture INVALID" do
        user = TestUser.create(@user_params)
        user.email = 'existinguser@invalid.com'
        user.persist_to_capture(only_changes = true).should == 1
      end

      it "should set the failed attribute if update is unsuccessful" do
        user = TestUser.create(@user_params)
        user.email = 'existinguser@invalid.com'
        user.persist_to_capture(only_changes = true)
        user.should be_failed
      end

      it "should unset the failes attribute if update is successful" do
        user = TestUser.create(@user_params.merge(failed: true))
        user.failed.should be_true
        user.email = 'existinguser@valid.com'
        user.persist_to_capture(only_changes = true)
        user.failed.should be_false
      end

    end
  end

  context "from active record cache to_capture key/value pairs" do

    context "new capture user" do
      it "should return key/value pairs for capture schema for new records" do
        user = TestUser.new(@user_params.merge(capture_id: nil))
        attrs = user.to_capture
        attrs.should be_a Hash
        attrs.should have_key 'email'
        attrs['email'].should == @user_params[:email]
        attrs.should_not have_key 'id'
        attrs.should_not have_key 'capture_id'
      end
    end

    context "existing capture user" do

      before :each do
        @user = TestUser.create(@user_params)
        @attrs = @user.to_capture
      end

      it "should return key/value pairs for capture schema for existing records" do
        @attrs.should be_a Hash
        @attrs.should have_key 'email'
        @attrs['email'].should == @user_params[:email]
        # @attrs.should have_key 'id'
      end

      it "should exclude locally cached values" do
        @attrs.should_not have_key 'about_me'
        @attrs.should_not have_key 'aboutMe'
      end

      it "should convert case as expected (WITHOUT mapping specified)" do
        @attrs.should have_key 'last_login'
        @attrs.should_not have_key 'lastLogin'
      end

      it "should convert case as expected (WITH mapping specified)" do
        @attrs.should_not have_key 'display_name'
        @attrs.should have_key 'displayName'
      end

      it "should include mapped fields that require name conversion" do
        @attrs.should have_key 'birthday'
      end

      context "changes only" do

        it "should only returned changed fields" do
          @user.display_name = 'my newest name'
          @attrs = @user.to_capture(changed_attributes_only = true)
          @attrs.should have(1).items
          @attrs.should have_key('displayName')
        end

      end
    end
  end

  context "privelages/ permissions" do

    before :each do
      @user  = TestUser.create(@user_params)
      @admin = TestUser.create(@user_params.merge(admin: true))
      @super = TestUser.create(@user_params.merge(admin: true, superuser: true))
    end

    it "should ignore nil arguments" do
      @user.should_not be_admin
      @user.change_privileges(nil)
      @user.should_not be_admin
    end

    context "increase/up" do
      it "should make a user an admin" do
        @user.should_not be_admin
        @user.change_privileges(:up)
        @user.should be_admin
      end

      it "should make an admin a super user" do
        @admin.should be_admin
        @admin.should_not be_superuser
        @admin.change_privileges(:up)
        @admin.should be_superuser
      end
    end
    context "decrease/down" do
      it "should make an admin a user" do
        @admin.should be_admin
        @admin.change_privileges(:down)
        @admin.should_not be_admin
      end

      it "should make an super user an admin" do
        @super.should be_admin
        @super.should be_superuser
        @super.change_privileges(:down)
        @super.should be_admin
        @super.should_not be_superuser
      end
    end
  end

  describe "token expired" do
    it "should be expired if token is expired" do
      @user  = TestUser.create(
        @user_params.merge(
          expires_at: (Time.now - 500),
          refresh_token: 'a_valid_token',
        )
      )
      @user.should be_expired
    end

    it "should be expired if refresh token is nil" do
      @user  = TestUser.create(
        @user_params.merge(
          expires_at: (Time.now + 500),
          refresh_token: nil,
        )
      )
      @user.should be_expired
    end

    it "should not be expired if token is present and expires at date is in the future" do
      @user  = TestUser.create(
        @user_params.merge(
          expires_at: (Time.now + 500),
          refresh_token: 'a_valid_token',
        )
      )
      @user.expired?.should be_false
      @user.should_not be_expired
    end
  end

  describe "refresh authentication" do
    it "should refresh token if expired" do
      expired_at = (Time.now - 500)
      @user = TestUser.create(
        @user_params.merge(
          expires_at: expired_at,
          access_token: 'access_token',
          refresh_token: 'a_valid_code',
        )
      )
      TestUser.stub(:find_or_initialize_by_capture_id).and_return(@user)
      @user.refresh_authentication!.id.should == @user.id
      @user.access_token.should_not == 'access_token'
      @user.access_token.should == 'a_valid_token'
      @user.expires_at.should_not == expired_at
    end
  end

  describe "authenticate" do
    it "should override the host name with an options to authenticate"

    it "should authenticate with a valid code" do
      TestUser.authenticate('a_valid_code').should be_a TestUser
    end

    it "should not authenticate with an invalid code" do
      TestUser.authenticate('an_invalid_code').should be_false
    end

    context "post authenticate hooks" do

      before :each do
        class TestUser
          private
          def self.post_authentication_hook(user, entity, oauth)
            raise SecurityError.new("THIS IS RAISED FROM THE HOOK")
          end
        end
      end

      after :each do
        class TestUser
          private
          def self.post_authentication_hook(user, entity, oauth)
            user
          end
        end
      end

      it "should run post authenticate hooks" do
        expect {
          TestUser.authenticate('a_valid_code')
        }.to raise_error(SecurityError)
      end
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
          'permissions' => nil,
          'flags' => nil,
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

    it "should default the permissions and flags to zero" do
      @user.flags.should be_zero
      @user.permissions.should be_zero
    end

  end



end

