# == Schema Information
#
# Table name: artists
#
#  id                     :integer          not null, primary key
#  rf_id                  :integer
#  name                   :string(255)
#  stage                  :string(255)
#  description            :text
#  image_url              :string(255)
#  medium_image_url       :string(255)
#  link                   :string(255)
#  short_description      :text
#  timestamp              :string(255)
#  musicbrainz_id         :string(255)
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  musicbrainz_confidence :integer          default(0)
#  last_fm_response       :text
#

class Artist < ActiveRecord::Base
  attr_accessible :description, :imageURL, :link, :mediumImageURL, :name, :short_description, :stage, :timestamp

  has_many :similar_artists_association, class_name: "SimilarArtist"
  has_many :similar_artists, through: :similar_artists_association, source: :similar_artist

  serialize :last_fm_response

  scope :with_musicbrainz_id,
    where("musicbrainz_id IS NOT NULL")

  def last_fm_name
    @last_fm_name ||= self.last_fm_response.try(:fetch, 'name')
  end

  def last_fm_url
    @last_fm_url ||= self.last_fm_response.try(:fetch, 'url')
  end

  def as_json(opts = {})
    opts.merge! except: [:created_at, :updated_at, :last_fm_response]
    opts.merge! methods: [:similar_artists_as_json] unless opts[:skip_similar]

    super opts
  end

  def similar_artists_as_json
    self.similar_artists_association.map(&:similar_artist_id).map do |id|
      Artist.find(id).as_json(skip_similar: true)
    end
  end
end
