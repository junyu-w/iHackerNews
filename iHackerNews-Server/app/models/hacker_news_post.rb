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

  has_and_belongs_to_many :users

  validates :url, presence:true, uniqueness:true
  validates :urlDomain, presence:true
  validates :title, presence:true

end
