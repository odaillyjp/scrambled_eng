class User < ActiveRecord::Base
  validates :uid, presence: true, uniqueness: { scope: :provider }
  validates :provider, presence: true
  validates :name, presence: true

  def self.find_or_create_from_auth_hash(auth_hash)
    self.create_with(name: auth_hash['info']['name'])
      .create_with(image: auth_hash['info']['image'])
      .find_or_create_by(uid: auth_hash['uid'], provider: auth_hash['provider'])
  end
end
