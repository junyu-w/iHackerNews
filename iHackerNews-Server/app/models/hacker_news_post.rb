# == Schema Information
#
# Table name: hacker_news_posts
#
#  id         :integer          not null, primary key
#  url        :string(255)
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

class HackerNewsPost < ActiveRecord::Base

  has_many :users_hacker_news_posts_joins
  has_many :users, :through => :users_hacker_news_posts_joins

  validates :url, presence:true, uniqueness:true

end
