class <%= controller_name.camelize %>Controller < ApplicationController
  def new
  end

  def create
    # XXX: features to add:
    # 1) code auth with render close fancybox
    if @<%= name %> = <%= class_name %>.authenticate(params[:code])
      sign_in @<%= name %>
      flash[:notice] = 'You are now signed in'
    else
      flash[:error] = 'Unable to sign you in, try again'
    end
    redirect_to params[:return_to] || root_url
  end

  def destroy
    # XXX: sign the user out
    sign_out!
    flash[:notice] = 'You are now signed out'
    redirect_to params[:return_to] || root_url
  end
end
