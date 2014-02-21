class ReaddScoreToSimilarArtists < ActiveRecord::Migration
  def change
    add_column :similar_artists, :score, :float
  end
end
