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

require 'spec_helper'

describe Artist do
  pending "add some examples to (or delete) #{__FILE__}"
end
