class CreateSongs < ActiveRecord::Migration[7.0]
  def change
    create_table :songs do |t|
      t.string :name
      t.references :album, foreign_key: true
      t.references :artist, foreign_key: true
      t.float :length
      t.datetime :published_at

      t.timestamps
    end
  end
end
