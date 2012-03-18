require 'spec_helper'

describe ApplicationController, "url helpers", type: :controller do

  before :each do
    get 'index'
  end

  it "should have janrain signin url" do
    controller.janrain_signin_url(host: 'mysite.com').should == "https://asite.dev.janraincapture.com/oauth/signin?response_type=code&redirect_uri=http%3A%2F%2Fmysite.com%2Fauth&client_id=kjhgkjhgdw7qd8qw873yrgukegw&xd_receiver=http%3A//test.host/xdcomm.html"
  end

  it "should have janrain signup url" do
    controller.janrain_signup_url(host: 'mysite.com').should == 'https://asite.dev.janraincapture.com/oauth/legacy_register?response_type=code&redirect_uri=http%3A%2F%2Fmysite.com%2Fauth&client_id=kjhgkjhgdw7qd8qw873yrgukegw&xd_receiver=http%3A//test.host/xdcomm.html'
  end

  it "should have janrain edit profile url" do
    controller.janrain_edit_profile_url(TestUser.new).should == 'https://asite.dev.janraincapture.com/oauth/profile?access_token=&callback=CAPTURE.closeProfileEditor&xd_receiver=http%3A//test.host/xdcomm.html'
  end

  it "should have logout url from routes" do
    janrain_signout_url.should == 'http://test.host/session/signout'
  end

end
