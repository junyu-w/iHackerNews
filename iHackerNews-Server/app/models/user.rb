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

  has_secure_password

  has_and_belongs_to_many :hacker_news_posts

  validates :email, format: { with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\z/i, on: :create }
  validates :username, presence:true, uniqueness:true
  validates :email, presence:true, uniqueness: true
  validates :facebook_id, uniqueness: { allow_blank: true, case_sensitive: false }

  scope :posts_of_user, -> (user) { user.hacker_news_posts }

  def posts
    self.hacker_news_posts
  end

  def different_dates_of_posts
    self.posts.pluck(:created_at).map{ |x| x.strftime("%b %d. %Y") }.uniq.reverse
  end

  def posts_with_dates
    result = {}
    posts = self.posts
    posts.each do |p|
      date_of_post = p.created_at.strftime("%b %d. %Y")
      result[date_of_post].nil? ? result[date_of_post] = [p] : result[date_of_post] += [p]
    end
    Hash[result.to_a.reverse]
  end

end
