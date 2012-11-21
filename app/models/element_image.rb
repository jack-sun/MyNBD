class ElementImage < Element
  belongs_to :image, :dependent => :destroy
end
