class ConsultationsController < DocumentsController
  def index
    filter_params = params.permit(:publication_filter_option, :locale,
                                  departments: [], topics: [], world_locations: [])

    redirect_to publications_path(filter_params.merge(publication_filter_option: "consultations").to_h)
  end
end
