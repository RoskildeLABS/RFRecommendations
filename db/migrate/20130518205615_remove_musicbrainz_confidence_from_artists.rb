class RemoveMusicbrainzConfidenceFromArtists < ActiveRecord::Migration
  def up
    remove_column :artists, :musicbrainz_confidence
  end

  def down
    add_column :artists, :musicbrainz_confidence, :integer, default: 0
  end
end
