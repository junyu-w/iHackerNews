# == Schema Information
#
# Table name: users
#
#  id                  :integer          not null, primary key
#  username            :string(255)
#  password            :string(255)
#  profile_picture_url :string(255)
#  created_at          :datetime
#  updated_at          :datetime
#  facebook_id         :string(255)
#  facebook_auth_token :string(255)
#  email               :string(255)
#

class User < ActiveRecord::Base

  has_and_belongs_to_many :hacker_news_posts

  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create }
  validates :username, presence:true, uniqueness:true
  validates :email, presence:true

  scope :posts_of_user, -> (user) { user.hacker_news_posts }

end
