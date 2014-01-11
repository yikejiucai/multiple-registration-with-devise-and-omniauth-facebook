class AuthenticationsController < ApplicationController
  def facebook
    omni = request.env["omniauth.auth"]
    authentication = Authentication.find_by_provider_and_uid(omni['provider'],omni['uid'])
    if authentication
      flash[:notice] = "Logged in Successfully"
      sign_in_and_redirect User.find(authentication.user_id)
    elsif user = User.find_by(email: omni['extra']['raw_info'].email)
      user.authentications.create!(provider:omni['provider'], 
                            uid:omni['uid'])
      flash[:notice] = "Authentication for registered user is Successfull"
      sign_in_and_redirect user
    else
      user = User.new
      user.password = Devise.friendly_token[0,20]
      user.email = omni['extra']['raw_info'].email
      user.authentications.build(provider:omni['provider'], 
                            uid:omni['uid'])
      if user.save
        flash[:notice] = "Logged in."
        sign_in_and_redirect User.find(user.id)
      else
        session[:omniauth] = omni.except('extra')
        redirect_to new_user_registration_path
      end
    end
  end
end
