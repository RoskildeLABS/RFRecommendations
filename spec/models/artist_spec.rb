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

require 'spec_helper'

describe Artist do
  pending "add some examples to (or delete) #{__FILE__}"
end
