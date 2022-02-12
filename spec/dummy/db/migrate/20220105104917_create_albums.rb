class CreateAlbums < ActiveRecord::Migration[7.0]
  def change
    create_table :albums do |t|
      t.string :name
      t.references :label, foreign_key: true
      t.references :artist, foreign_key: true
      t.integer :genre
      t.date :released_at
      t.decimal :length, precision: 5, scale: 2
      t.datetime :published_at

      t.timestamps
    end
  end
end
