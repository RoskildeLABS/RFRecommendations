class CreateSimilarArtists < ActiveRecord::Migration
  def change
    create_table :similar_artists do |t|
      t.integer :artist_id
      t.integer :similar_artist_id

      t.timestamps
    end
  end
end
