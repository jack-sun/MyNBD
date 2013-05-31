class GeneralController < ApplicationController

	layout 'site'

  def about
  end

  def privacy
  end

  def mobile_newspaper_privacy
    render :layout => "touzibao"
  end

  def gms_privacy
    render :layout => "touzibao"
  end  

  def copyright
  end

  def advertisement
  end

  def contact
  end

  def links
  end

  def sitemap
  end

end
