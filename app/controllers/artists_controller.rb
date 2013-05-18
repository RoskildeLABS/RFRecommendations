class ArtistsController < ApplicationController
  inherit_resources
  actions :index, :show
  respond_to :json
  respond_to :html

  private

  def resource
    @artist ||= end_of_association_chain.includes(:similar_artists).find(params[:id])
  end

  def collection
    @artists ||= end_of_association_chain.includes(:similar_artists)
  end
end
