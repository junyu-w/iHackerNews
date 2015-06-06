class CreateUsersHackerNewsPostsJoins < ActiveRecord::Migration
  def change
    create_table :users_hacker_news_posts_joins do |t|
      t.integer :user_id
      t.integer :post_id

      t.timestamps
    end
  end
end
