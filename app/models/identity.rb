class Identity < ActiveRecord::Base
  belongs_to :user

  def self.find_with_omniauth(auth)
    Identity.find_by(uid: auth['uid'], provider: auth['provider'])
  end

  def self.create_with_omniauth(auth)
    Identity.create(uid: auth['uid'], provider: auth['provider'])
  end
end
