#encoding: utf-8
class FlashTouzibaoFilter
  def self.filter(controller)
    controller.flash[:action_from] = 'touzibao'
  end
end
