class UsersController < ApplicationController
  respond_to :html
  respond_to :json
  respond_to :xml

  helper_method :collection

  def show
    @artists = last_fm_artists_for_user(params[:username]).page(params[:page])
    respond_to do |format|
      format.html { render 'artists/index' }
      format.json { respond_with @artists }
      format.xml { respond_with @artists }
    end
  end

  private

  def collection
    @artists
  end

  def last_fm_artists_for_user(username)
    names = []
    Artist.select([:last_fm_name, :name]).all.in_groups_of(100, false) do |artists|
      url = match_url(username, artists)
      Rails.logger.info "GET: #{url}"
      json = JSON.parse(open(url).read)
      next if json['error']
      artists = json['comparison']['result']['artists']['artist']
      artists = [artists] if artists.is_a?(Hash)
      if artists
        names += artists.map { |a| a['name'] }
      end
    end
    Artist.where("last_fm_name IN (?)", names)
  end

  def match_url(user, artists)
    artist_names = artists.map { |a| a.last_fm_name || a.name }
    "http://ws.audioscrobbler.com/2.0/?method=tasteometer.compare&type1=user&type2=artists&value1=#{user}&value2=#{artist_names.map { |n| CGI.escape n }.join(",") }&api_key=cc2f6ef14dfc15aa8b5be688eb33a704&format=json&limit=100"
  end
end
