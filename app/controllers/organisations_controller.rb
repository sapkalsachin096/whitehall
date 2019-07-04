class OrganisationsController < PublicFacingController
  def index
    @content_item = Whitehall.content_store.content_item("/courts-tribunals")
    @courts = Organisation.courts.listable.ordered_by_name_ignoring_prefix
    @hmcts_tribunals = Organisation.hmcts_tribunals.listable.ordered_by_name_ignoring_prefix
    render :courts_index
  end

  # organisations#show is now redirected in routes.rb.  This is because the only requests that should hit
  # Whitehall for org pages are those that are caught by the /government prefix route.  Organisation pages
  # are now rendered by Collections
end
