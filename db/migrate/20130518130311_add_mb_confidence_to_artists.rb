class AddMbConfidenceToArtists < ActiveRecord::Migration
  def change
    add_column :artists, :musicbrainz_confidence, :integer, default: 0
  end
end
