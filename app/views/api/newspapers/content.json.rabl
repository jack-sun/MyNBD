object false

node :newspaper do
  {:id => @newspaper.id, 
  :n_index => @newspaper.n_index, 
  :created_at => @newspaper.created_at.to_i * 1000,
  :articles => partial("api/newspapers/article_section", :object => @newspaper.articles_newspapers.order('page ASC'))
  }
end

node :msg do
  "success"
end

node :code do
  1
end

node :msg do
  "success"
end

node :code do
  1
end
