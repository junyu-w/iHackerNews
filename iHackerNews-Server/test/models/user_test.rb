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

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
