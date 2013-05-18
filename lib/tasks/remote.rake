# encoding: utf-8
require 'open-uri'

namespace :data do
  desc "Generate artist data from feed"
  task :artists => [:environment] do
    puts "Removing old artists"
    Artist.delete_all

    puts "Fetching feed"
    feedURL = 'http://roskilde-festival.dk/typo3conf/ext/tcpageheaderobjects/xml/bandobjects_251_uk.xml'
    feed = Nokogiri::XML(open(feedURL))
    puts "Generating artists: "
    artists = feed.search("item").collect do |artist|
      a = Artist.new
      a.name = artist.search("artistName").text
      a.stage = artist.search("scene").text
      a.timestamp = artist.search("original_timestamp").text
      a.description = ActionView::Base.full_sanitizer.sanitize(artist.search("description").text)
      a.short_description = artist.search("text").text
      a.image_url = artist.search("imageUrl").text
      a.medium_image_url = rf_url + artist.search("mediumimageUrl").text
      a.link = rf_url + artist.search("link").text
      a.rf_id = artist.search("id").text.to_i
      print a.name + ", "
      a.save && a
    end
    puts ""
    puts "Done (#{artists.count})"
  end

  task :last_fm => [:environment] do
    puts "Fetching similar artists from last.fm"
    Artist.all.each do |artist|
      print artist.name + " => "
      url = "http://ws.audioscrobbler.com/2.0/?method=artist.getinfo&artist=#{escape artist.name}&api_key=cc2f6ef14dfc15aa8b5be688eb33a704&format=json"
      json = JSON.parse(open(url).read)
      lastfm = json['artist']

      if !lastfm || lastfm['error']
        print "Nothing found ...\n"
        next
      end

      images = lastfm['image'] && lastfm['image'].inject({}) do |hash, image|
        hash.merge image['size'].to_sym => image["#text"]
      end

      if lastfm['tags'].is_a?(Hash)
        tags = lastfm['tags']['tag']
        tags = [tags] unless tags.is_a?(Array)
        tags = tags.inject([]) do |array, tag|
          array << tag['name']
        end.join(", ")
      else
        tags = nil
      end

      artist.update_attributes(
        :musicbrainz_id => lastfm['mbid'].presence,
        :last_fm_name => lastfm['name'].presence,
        :last_fm_response => lastfm,
        :last_fm_images => images,
        :last_fm_tags => tags
      )

      print "#{lastfm['name']} (#{lastfm['mbid']})\n"
    end
  end

  namespace :last_fm do
    desc "Similar"
    task :similar => [:environment] do
      Artist.all.each do |artist|
        puts artist.name
        SimilarArtist.delete_all(["artist_id = ?", artist.id])
        json = JSON.parse(open(last_fm_similar_url_for_artist(artist)).read)
        lastfm = json['similarartists'].try(:fetch, 'artist')

        if !lastfm.is_a?(Array)
          next
        end

        lastfm.each do |similar|
          if record = Artist.find_by_musicbrainz_id(similar['mbid'])
            s = SimilarArtist.create artist_id: artist.id, similar_artist_id: record.id, score: similar['match']
            puts "- #{s.similar_artist.name}: #{s.score}"
          end
        end
      end
    end
  end

  task :all => [:artists, :last_fm, 'last_fm:similar']
end

def last_fm_similar_url_for_artist(artist)
  url = "http://ws.audioscrobbler.com/2.0/?method=artist.getsimilar"
  url << "&artist=#{escape (artist.last_fm_name || artist.name)}"
  url + "&api_key=cc2f6ef14dfc15aa8b5be688eb33a704&format=json"
end

def escape(str)
  CGI.escape(str)
end

def rf_url
  "http://roskilde-festival.dk/"
end
