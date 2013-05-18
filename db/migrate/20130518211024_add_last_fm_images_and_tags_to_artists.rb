class AddLastFmImagesAndTagsToArtists < ActiveRecord::Migration
  def change
    add_column :artists, :last_fm_images, :text
    add_column :artists, :last_fm_tags, :text
  end
end
