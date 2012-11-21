xml.instruct! :xml, :version => "1.0", :encoding => :gb2312
xml.rss "version" => "2.0", "xmlns:dc" => "http://purl.org/dc/elements/1.1/" do
  xml.channel do
    xml.title "每日经济新闻"
    xml.description "每经网 | 新闻决定影响力 |《每日经济新闻》报社旗下网站"
    xml.link Settings.host

    @articles.map(&:article).each do|a|
      xml.item do
        xml.title raw(a.title)
        xml.link article_url(a)
        xml.description a.pages.map{|page| "<p>" + page.content + "</p>"}.join("").html_safe
        xml.pubDate a.created_at.to_s(:rfc822)
        xml.guid article_url(a)
      end
    end
  end
end