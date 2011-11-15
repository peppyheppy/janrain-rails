require 'spec_helper'

describe SessionController, type: :controller do

  context "signin / create" do
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

    it "should redirct to the return_to url passed in" do
      get :create, code: 'a_valid_code', return_to: 'http://localhost/yoyo.htm'
      response.should redirect_to 'http://localhost/yoyo.htm'
    end
  end

  context "signout / destroy" do
    before :each do
      @user = TestUser.create(capture_id: 1, email: 'paul@hdawg.com', display_name: 'P-Dawg')
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
      get :destroy, return_to: 'http://localhost/yoyo.htm'
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