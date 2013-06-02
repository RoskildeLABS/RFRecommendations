# == Schema Information
#
# Table name: artists
#
#  id                :integer          not null, primary key
#  rf_id             :integer
#  name              :string(255)
#  stage             :string(255)
#  description       :text
#  image_url         :string(255)
#  medium_image_url  :string(255)
#  link              :string(255)
#  short_description :text
#  timestamp         :string(255)
#  musicbrainz_id    :string(255)
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  last_fm_response  :text
#  last_fm_name      :string(255)
#  last_fm_images    :text
#  last_fm_tags      :text
#

class Artist < ActiveRecord::Base
  attr_accessible :description, :imageURL, :link, :mediumImageURL, :name, :short_description, :stage, :timestamp, :last_fm_tags, :last_fm_images, :last_fm_name, :last_fm_response, :musicbrainz_id

  has_many :similar_artists_association, class_name: "SimilarArtist"
  has_many :similar_artists, through: :similar_artists_association, source: :similar_artist

  serialize :last_fm_response
  serialize :last_fm_images

  scope :with_musicbrainz_id,
    where("musicbrainz_id IS NOT NULL")
  scope :by_name, order("name")

  def last_fm_url
    @last_fm_url ||= self.last_fm_response.try(:fetch, 'url')
  end

  def similar_artists_with_scores
    self.similar_artists_association.map do |assoc|
      { id: assoc.similar_artist.id, name: assoc.similar_artist.name, score: assoc.score }
    end
  end

  def as_json(opts = {})
    opts.merge! except: [:created_at, :updated_at, :last_fm_response]

    super opts
  end

  def to_xml(opts = {})
    opts.merge! except: [:created_at, :updated_at, :last_fm_response]

    super opts
  end

end
