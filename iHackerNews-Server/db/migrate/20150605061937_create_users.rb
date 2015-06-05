class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :username
      t.string :password
      t.string :profile_picture_url

      t.timestamps
    end
  end
end
