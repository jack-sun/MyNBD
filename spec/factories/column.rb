Factory.define(:root_column, :class => Column) do |f|
  f.name "news"
end

Factory.define(:children_column, :class => Column) do |f|
  f.name "hot"
  f.parent_id 1
end
