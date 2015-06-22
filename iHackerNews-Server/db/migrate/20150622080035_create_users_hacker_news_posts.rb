class CreateUsersHackerNewsPosts < ActiveRecord::Migration
  def change
    create_table :hacker_news_posts_users do |t|
    	t.integer :user_id
    	t.integer :hacker_news_post_id
    end
  end
end
