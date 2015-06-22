class AddColumnsToHackerNewsPosts < ActiveRecord::Migration
  def change
    add_column :hacker_news_posts, :title, :string
    add_column :hacker_news_posts, :urlDomain, :string
  end
end
