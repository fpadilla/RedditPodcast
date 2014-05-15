class CreatePosts < ActiveRecord::Migration
  def change
    create_table :posts do |t|
      t.string :redditId
      t.string :url
      t.string :vbProjectId
      t.string :vbReadUrl

      t.timestamps
    end
  end
end
