class PagesController < ApplicationController
  def home
    @title = "Strona główna"
    if signed_in?
      @gallery = Gallery.new
      @feed_items = current_user.feed.paginate(:page => params[:page])
    end
  end

  def contact
    @title = "Kontakt"
  end

end
