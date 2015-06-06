# == Schema Information
#
# Table name: users_hacker_news_posts_joins
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  post_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

class UsersHackerNewsPostsJoin < ActiveRecord::Base

  belongs_to :User
  belongs_to :HackerNewsPost

  validates :user_id, presence:true
  validates :post_id, presence:true

end
