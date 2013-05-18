class AddLastFmNameToArtists < ActiveRecord::Migration
  def change
    add_column :artists, :last_fm_name, :string
  end
end
