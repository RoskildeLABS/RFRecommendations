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
      a.medium_image_url = artist.search("mediumimageUrl").text
      a.link = "http://roskilde-festival.dk/" + artist.search("link").text
      a.rf_id = artist.search("id").text.to_i
      print a.name + ", "
      a.save && a
    end
    puts ""
    puts "Done (#{artists.count})"
  end

  desc "MusicBrainz"
  task :musicbrainz => [:environment] do
    puts ""
    Artist.where("musicbrainz_id IS NULL").all.in_groups_of(15).each do |group|
      group.each do |artist|
        begin
          print artist.name + " => "
          url = "http://www.musicbrainz.org/ws/2/artist/?limit=1&query=artist:#{URI.encode artist.name.gsub("/"," ").gsub("&", "and")}"
          brainz = Nokogiri::XML(open(url, {'User-Agent' => 'RoskildeLabs/1.0 (roskildelabs@gmail.com)'}))
          b = brainz.search("artist").first
          mb_name = b.search("name").first.text
          artist.update_attribute :musicbrainz_id, b.attr("id").presence

          confidence = 0
          if artist.name.downcase == mb_name.downcase
            confidence = 10
          elsif artist.name.match /#{mb_name}/i
            confidence = 5
          end

          artist.update_attribute(:musicbrainz_confidence, confidence)

          print mb_name + " (#{b.attr("id")}) Confidence:#{confidence}\n"
        rescue Exception => e
          print "No artist found for -- #{e.inspect}'\n"
        end
      end
      puts "Sleeping"
      sleep 10
    end
    puts ""
  end

  task :last_fm => [:environment] do
    puts "Fetching similar artists from last.fm"
    Artist.all.each do |artist|
      print artist.name + " => "
      url = "http://ws.audioscrobbler.com/2.0/?method=artist.getinfo&artist=#{CGI.escape artist.name}&autocorrect=1&api_key=cc2f6ef14dfc15aa8b5be688eb33a704&format=json"
      json = JSON.parse(open(url).read)
      lastfm = json['artist']
      if !lastfm
        print "Nothing found ...\n"
        next
      end

      artist.update_attribute :musicbrainz_id, lastfm['mbid'].presence
      artist.update_attribute :last_fm_response, lastfm

      print "#{lastfm['name']} (#{lastfm['mbid']})\n"
    end
  end
  
  namespace :last_fm do
    desc "Similar"
    task :similar => [:environment] do
      Artist.with_musicbrainz_id.each do |artist|
        SimilarArtist.delete_all(["artist_id = ?", artist.id])
        url = "http://ws.audioscrobbler.com/2.0/?method=artist.getsimilar&mbid=#{CGI.escape artist.musicbrainz_id}&autocorrect=1&api_key=cc2f6ef14dfc15aa8b5be688eb33a704&format=json"
        json = JSON.parse(open(url).read)
        lastfm = json['similarartists']['artist']

        puts artist.name
        begin
          lastfm.each do |similar|
            if record = Artist.find_by_musicbrainz_id(similar['mbid'])
              s = SimilarArtist.create artist_id: artist.id, similar_artist_id: record.id, score: similar['match']
              puts "- #{s.similar_artist.name}: #{s.score}"
            end
          end
        rescue Exception => e
          puts e.inspect
        end
      end
    end
  end

  task :all => [:artists, :last_fm, :musicbrainz, 'last_fm:similar']
end

def mb_search_url(artist_name)
end
