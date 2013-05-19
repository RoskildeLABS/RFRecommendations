class ArtistsController < ApplicationController
  respond_to :json, :html, :xml
  helper_method :collection, :resource

  def index
    respond_to do |format|
      format.html
      format.json { render json: {artists: collection} }
      format.xml { render xml: collection }
    end
  end

  def show
    respond_to do |format|
      format.html
      format.json { render json: {artist: resource} }
      format.xml { render xml: resource }
    end
  end

  def similar
    @artists = resource.similar_artists.page(params[:page])
    if params[:q]
      @artists = search(@artists, params[:q])
    end
    respond_to do |format|
      format.html { render :index }
      format.json { render json: {artists: collection} }
      format.xml { render xml: collection }
    end
  end

  private

  def resource
    @artist ||= Artist.includes(:similar_artists_association => :similar_artist).find(params[:id])
  end

  def collection
    return @artists if @artists

    arel = Artist.includes(:similar_artists_association => :similar_artist)
    if params[:q]
      arel = search(arel, params[:q])
    elsif params[:ids]
      arel = arel.where("id IN (?)", params[:ids].split(","))
    end
    @artists = arel.paginate(per_page: 20, page: params[:page])
  end

  def search(arel, q)
    arel.where("name LIKE ? OR last_fm_name LIKE ?", "%#{q}%", "%#{q}%")
  end
end
