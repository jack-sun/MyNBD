class Stat
  def initialize(type, filter, page)
    case type
    when "staff"
      @_objects = Staff.page(page).includes(:articles_staffs => :articles)
    end
  end
end
