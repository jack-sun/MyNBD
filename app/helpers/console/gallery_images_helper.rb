module Console::GalleryImagesHelper

  def gallery_status(status)
    Gallery::STATUS_TYPE[status]
  end

end
