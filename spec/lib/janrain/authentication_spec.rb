require 'spec_helper'

# controller for testing only
class FoobarsController < ApplicationController
  before_filter :authenticate_user!, :only => 'reqular_login_required'
  before_filter :authenticate_admin_user!, :only => 'admin_login_required'
  before_filter :authenticate_super_user!, :only => 'super_login_required'

  def anonymous_allowed
    render :text => 'anonymous_allowed'
  end

  def reqular_login_required
    render :text => 'reqular_login_required'
  end

  def admin_login_required
    render :text => 'admin_login_required'
  end

  def super_login_required
    render :text => 'super_login_required'
  end
end

shared_examples "an admin user" do
  it "should be allowed admin access" do
    get :admin_login_required
    flash[:error].should be_blank
    response.should_not be_redirect
  end
end

shared_examples "a non admin user" do
  it "should not be allowed" do
    get :admin_login_required
    flash[:error].should_not be_blank
    controller.session[:origin].should == 'http://test.host/foobars/admin_login_required'
    response.should redirect_to new_janrain_session_url
  end
end

shared_examples "a super user" do
  it "should be allowed user user access" do
    get :super_login_required
    flash[:error].should be_blank
    response.should_not be_redirect
  end
end

shared_examples "a non super user" do
  it "should not be allowed" do
    get :super_login_required
    flash[:error].should_not be_blank
    controller.session[:origin].should == 'http://test.host/foobars/super_login_required'
    response.should redirect_to new_janrain_session_url
  end
end

shared_examples "a logged in user" do
  it "should be allowed basic access" do
    get :reqular_login_required
    flash[:error].should be_blank
    response.should_not be_redirect
  end
end

shared_examples "an expected to be logged in user" do
  it "should not be allowed" do
    get :reqular_login_required
    flash[:error].should_not be_blank
    controller.session[:origin].should == 'http://test.host/foobars/reqular_login_required'
    response.should redirect_to new_janrain_session_url
  end
end

shared_examples "a non logged in user" do
  it "should be allowed" do
    get :anonymous_allowed
    response.should_not be_redirect
    response.body.should == 'anonymous_allowed'
    response.should_not be_redirect
  end
end

describe FoobarsController, type: :controller do
  context "annonymous user" do
    it_behaves_like "a non logged in user"
    it_behaves_like "an expected to be logged in user"
    it_behaves_like "a non super user"
    it_behaves_like "a non admin user"
  end

  context "refresh authentication on current user fetch" do
    before :each do
      @user = TestUser.create(
        capture_id: 1,
        email: 'paul@hdawg.com',
        display_name: 'P-Dawg',
        access_token: 'expired',
        refresh_token: 'a_valid_code',
        expires_at: Time.now - 1.day,
      )
      sign_in_as @user
    end

    it "should renew authentication" do
      get :reqular_login_required
      controller.current_user.access_token.should == 'a_valid_token'
      response.should_not redirect_to new_janrain_session_url
    end
  end

  context "regular signed in user" do
    before :each do
      @user = TestUser.create(
        capture_id: 1,
        email: 'paul@hdawg.com',
        display_name: 'P-Dawg',
        refresh_token: 'a_valid_code',
        expires_at: Time.now + 1.year,
      )
      sign_in_as @user
    end

    it_behaves_like "a non logged in user"
    it_behaves_like "a logged in user"
    it_behaves_like "a non super user"
    it_behaves_like "a non admin user"
  end

  context "an admin user" do
    before :each do
      @user = TestUser.create(
        capture_id: 1,
        admin: true,
        email: 'paul@hdawg.com',
        display_name: 'P-Dawg',
        refresh_token: 'a_valid_code',
        expires_at: Time.now + 1.year,
      )
      sign_in_as @user
    end

    it_behaves_like "a non logged in user"
    it_behaves_like "a logged in user"
    it_behaves_like "an admin user"
    it_behaves_like "a non super user"
  end

  context "a super user" do
    before :each do
      @user = TestUser.create(
        capture_id: 1,
        admin: true,
        superuser: true,
        email: 'paul@hdawg.com',
        display_name: 'P-Dawg',
        refresh_token: 'a_valid_code',
        expires_at: Time.now + 1.year,
      )
      sign_in_as @user
    end

    it_behaves_like "a non logged in user"
    it_behaves_like "a logged in user"
    it_behaves_like "a super user"
    it_behaves_like "an admin user"
  end
end

