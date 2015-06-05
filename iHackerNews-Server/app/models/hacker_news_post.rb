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

  belongs_to :User

  validates :url, presence:true, uniqueness:true

end
