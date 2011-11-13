require 'spec_helper'

# controller for testing only
class FoobarsController < ApplicationController
  before_filter :authenticate_user!, :only => 'edit'

  def new
    render :text => 'new'
  end

  def edit
    render :text => 'edit'
  end
end

describe FoobarsController, type: :controller do
  context "not signed in" do
    it "should require signed in user for edt" do
      get :edit
      flash[:error].should_not be_blank
      response.should be_redirect
    end

    it "should not require signed in user for new" do
      get :new
      response.should_not be_redirect
      response.body.should == 'new'
    end
  end

  context "signed in" do
    before :each do
      @user = TestUser.create(capture_id: 1, email: 'paul@hdawg.com', display_name: 'P-Dawg')
      sign_in_as @user
    end

    it "should be able to access page that requires authentication" do
      get :edit
      flash[:error].should be_blank
      response.should_not be_redirect
    end
  end
end

