object @article

attributes :is_rolling_news, :pos

node(:title){|article| article.list_title}

node(:digest){|article| article.show_digest}

node(:url){|article| article_url(article) }

node(:created_at){|article| (article.created_at.to_i*1000).to_s }

if @column
  node(:column_id){|a|@column.id}
end

node(:columnist_id){|a| a.c_id}

node(:id){|article| article.id }

node :content do |article|
  content = ""
  article.pages.each do |p|
    content += "<p>" + p.content + "</p>"
  end
  resp_article_content(article, content)
end

node :image do |article|
  if article.image
    if article.head_article?
      article.image.thumbnail_url(:x_large)
    else
      article.image.thumbnail_url(:middle)
    end
  end
end

# node :images do |article|
#   images_array = []
#   article.pages.each do |p|
#     if p.image
#       if @column and @column.id == 2
#         images_array << p.image.article_url(:x_large)
#       else
#         images_array << p.image.article_url(:middle)
#       end
#     end
#   end
#   images_array
# end
