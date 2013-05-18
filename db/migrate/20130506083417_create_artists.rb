class CreateArtists < ActiveRecord::Migration
  def change
    create_table :artists do |t|
      t.integer :rf_id
      t.string :name
      t.string :stage
      t.text :description
      t.string :image_url
      t.string :medium_image_url
      t.string :link
      t.text :short_description
      t.string :timestamp
      t.string :musicbrainz_id

      t.timestamps
    end
  end
end
