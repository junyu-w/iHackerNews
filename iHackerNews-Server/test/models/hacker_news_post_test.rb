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

require 'test_helper'

class HackerNewsPostTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
