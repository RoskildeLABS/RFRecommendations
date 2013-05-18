# == Schema Information
#
# Table name: similar_artists
#
#  id                :integer          not null, primary key
#  artist_id         :integer
#  similar_artist_id :integer
#  score             :float
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class SimilarArtist < ActiveRecord::Base
  attr_accessible :artist_id, :similar_artist_id, :score
  belongs_to :artist
  belongs_to :similar_artist, class_name: "Artist"

  default_scope order("score DESC")
end
