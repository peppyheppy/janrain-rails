require 'spec_helper'

ActionController::Base.prepend_view_path 'spec/fixtures'

describe "views/session/new.html.erb" do
  it "renders with janrain signin url" do
    render
    rendered.should =~ /\/oauth\/signin/
  end
end

describe "views/session/new.html.erb" do
  it "renders with janrain signup url" do
    render
    rendered.should =~ /\/oauth\/legacy_register/
  end
end

describe "views/session/new.html.erb" do
  it "renders with janrain edit profile url" do
    render
    rendered.should =~ /\/oauth\/profile/
  end
end


