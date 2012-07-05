require 'spec_helper'

describe SessionController, type: :controller do

  context "signin / create" do
    context "without iframe" do

      before :each do
        Janrain::Config.stub(:within_iframe?) { false }
      end

      it "should create a new local user from a newly captured user" do
        get :create, code: 'a_valid_code'
        assigns(:test_user).should_not be_new_record
        flash[:notice].should_not be_blank
        controller.should be_user_signed_in
        response.should redirect_to root_url
      end

      it "should authenticate an existing user" do
        get :create, code: 'an_invalid_code'
        assigns(:test_user).should be_false
        flash[:error].should_not be_blank
        controller.should_not be_user_signed_in
        response.should redirect_to root_url
      end

      it "should redirct to the origin url passed in" do
        get :create, code: 'a_valid_code', origin: 'http://localhost/yoyo.htm'
        response.should redirect_to 'http://localhost/yoyo.htm'
      end
    end

    it "should render javascript redirect if configured in modal" do
      get :create, code: 'a_valid_code', origin: 'http://localhost/yoyo.htm'
      response.body.should include("parent.location = 'http://localhost/yoyo.htm'")
    end
  end

  context "signout / destroy" do
    before :each do
      @user = TestUser.create(
        capture_id: 1,
        email: 'paul@hdawg.com',
        display_name: 'P-Dawg',
        refresh_token: 'a_valid_code',
        expires_at: Time.now + 1.year,
      )
      sign_in_as @user
      controller.should be_user_signed_in
    end

    it "should sign the user out and redirect to root url" do
      get :destroy
      flash[:notice].should_not be_blank
      controller.should_not be_user_signed_in
      response.should redirect_to root_url
    end

    it "should sign the user out and redirect to return to url" do
      get :destroy, origin: 'http://localhost/yoyo.htm'
      controller.should_not be_user_signed_in
      response.should redirect_to 'http://localhost/yoyo.htm'
    end
  end

  context "signup / new" do
    it "should show the signup/signin page" do
      get :new
      response.should_not be_redirect
    end
  end
end
