class CreateHackerNewsPosts < ActiveRecord::Migration
  def change
    create_table :hacker_news_posts do |t|
      t.string :url
      t.integer :user_id

      t.timestamps
    end
  end
end
