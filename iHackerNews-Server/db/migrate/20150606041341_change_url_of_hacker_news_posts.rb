class ChangeUrlOfHackerNewsPosts < ActiveRecord::Migration
  def change
    add_index :hacker_news_posts, :url
  end
end
