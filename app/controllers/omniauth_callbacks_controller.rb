class OmniauthCallbacksController < Devise::OmniauthCallbacksController   
def google_oauth2
    auth = request.env["omniauth.auth"]
    user = User.find_by_provider_and_uid(auth["provider"], auth["uid"]) || User.from_omniauth(auth,request.env['omniauth.params'])
    if user.persisted?
      sign_in_and_redirect user, event: :authentication
    else
      session["devise.google_data"] = oauth_response.except(:extra)
      params[:error] = :account_not_found
      do_failure_things
    end
  end
end
