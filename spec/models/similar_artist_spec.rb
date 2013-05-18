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

require 'spec_helper'

describe SimilarArtist do
  pending "add some examples to (or delete) #{__FILE__}"
end
