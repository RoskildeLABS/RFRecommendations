class SimilarArtist < ActiveRecord::Base
  attr_accessible :artist_id, :similar_artist_id, :score
  belongs_to :artist
  belongs_to :similar_artist, class_name: "Artist"

  default_scope order("score DESC")
end
