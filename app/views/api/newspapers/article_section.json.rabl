attributes :section, :page

node(:id){|article_newspaper| article_newspaper.article_id}

node(:title){|article_newspaper| article_newspaper.article.title}

node(:digest){|article_newspaper| article_newspaper.article.digest}

node(:content) do |article_newspaper|

  article = article_newspaper.article

  content = ""

  article.pages.each do |p|

    content += "<p>" + p.content + "</p>"

  end

  resp_article_content(article, content)

end

node(:is_rolling_news){|article_newspaper| article_newspaper.article.is_rolling_news}

node(:url){|article_newspaper| article_newspaper.article.send(:article_url, article_newspaper.article)}

node(:column_id){|article_newspaper| article_newspaper.article.columns.first.id}

node(:pos){|article_newspaper| ArticlesColumn.where("article_id = ? and column_id = ?", article_newspaper.article_id, article_newspaper.article.columns.first.id).first.pos}

node(:image){|article_newspaper| article_newspaper.article.image.try(:thumbnail_url)}

node(:created_at){|article_newspaper| (article_newspaper.article.created_at.to_i * 1000)}