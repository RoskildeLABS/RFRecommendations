class AddLastFmResponseToArtists < ActiveRecord::Migration
  def change
    add_column :artists, :last_fm_response, :text
  end
end
