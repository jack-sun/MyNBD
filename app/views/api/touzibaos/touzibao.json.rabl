object @touzibao

attributes :t_index, :id

node(:created_at){|touzibao| (touzibao.created_at.to_i * 1000)}
node(:updated_at){|touzibao| (touzibao.updated_at.to_i * 1000)}

node :sections do |touzibao|
  valid_sections = {}
  valid_section_ids = {}
  if touzibao.t_index == @latest_touzibao.t_index and params[:action] == "latest"
    []
  else
    @touzibao_articles = touzibao.article_touzibaos.includes(:article => :pages).order("pos asc, section asc")
    @touzibao_articles = @touzibao_articles.group_by{|e| e.section}
    @touzibao_articles.each do |section ,temp_articles|
      articles = temp_articles.map(&:article).compact.find_all{|x| x.status == Article::PUBLISHED}
      next if articles.blank?
      valid_sections[section] = articles
      valid_section_ids[section] = articles.first.id
    end

    keys = valid_sections.keys
    valid_sections.map do |section, articles|
      content = articles.inject("") do |str, article|
        str + article.pages.map(&:content).map{|c|"<p>" + c + "</p>"}.join.html_safe
      end
      {
        :title => section,
        :id => valid_section_ids[section],
        :content => resp_section_content(section, articles.first.created_at, content),
        :pos => keys.index(section)
      }
    end
  end
end
