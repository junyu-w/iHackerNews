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

  has_many :hacker_news_posts, :through => :users_hacker_news_posts_joins
  has_many :users_hacker_news_posts_joins

  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create }

end
