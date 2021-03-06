class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,:omniauthable,
         :recoverable, :rememberable, :trackable, :validatable, omniauth_providers: [:google_oauth2]
	def self.find_for_google_oauth2(access_token, signed_in_resource=nil)
    data = access_token.info
    user = User.where(:provider => access_token.provider, :uid => access_token.uid ).first
    if user
      return user
    else
      registered_user = User.where(:email => access_token.info.email).first
      if registered_user
        return registered_user
      else
        user = User.create(name: data["name"],
          provider:access_token.provider,
          email: data["email"],
          uid: access_token.uid ,
          password: Devise.friendly_token[0,20],
        )
      end
   end
	end

	def self.from_omniauth(auth, role)
    if user = User.where(email: auth['info']['email']).first
      user
    else
      where(provider: auth.provider, uid: auth.uid).first_or_create do |u|
        u.email = auth.info.email
        u.password = Devise.friendly_token[0, 20]
        u.name = auth.info.name
        u.save(validate: false)
      end
    end
  end
end
