#encoding: utf-8
require 'nokogiri'

module ApplicationHelper
  
  def apply_form_for_options!(object_or_array, options) #:nodoc:
    object = object_or_array.is_a?(Array) ? object_or_array.last : object_or_array
    object = convert_to_model(object)

    html_options =
      if object.respond_to?(:persisted?) && object.persisted?
        { :class  => options[:as] ? "#{options[:as]}_edit" : dom_class(object, :edit),
          :id => options[:as] ? "#{options[:as]}_edit" : dom_id(object, :edit),
          :method => :put }
      else
        { :class  => options[:as] ? "#{options[:as]}_new" : dom_class(object, :new),
          :id => options[:as] ? "#{options[:as]}_new" : dom_id(object),
          :method => :post }
      end

    options[:html] ||= {}
    options[:html].reverse_merge!(html_options)
    options[:url] ||= options[:format] ? \
      polymorphic_url(object_or_array, :format => options.delete(:format)) : \
      polymorphic_url(object_or_array)
  end
  
  def customize_host_url(subdomain='www')
    Settings.host.gsub("www", subdomain)
  end
  
  def live_url(live)
    "#{Settings.weibo_host}/lives/#{live.created_at.strftime("%Y-%m-%d")}/#{live.id}"
  end
  
  def article_url(article, html_suffix = true)
    if article.redirect_to.present?
      article.redirect_to
    else
      url = "#{Settings.host}/articles/#{article.created_at.strftime("%Y-%m-%d")}/#{article.id}"
      url += ".html" if html_suffix
      url
    end
  end

  def article_url_mobile(article, html_suffix = true)
    if article.redirect_to.present?
      article.redirect_to
    else
      url = "#{Settings.host}/mobile/articles/#{article.created_at.strftime("%Y-%m-%d")}/#{article.id}"
      url += ".html" if html_suffix
      url
    end
  end

 def ntt_article_url(article, html_suffix = true)
     if article.redirect_to.present?
       article.redirect_to
     else
       url = "#{Settings.ntt_host}/articles/#{article.created_at.strftime("%Y-%m-%d")}/#{article.id}"
       url += ".html" if html_suffix
       url
   end
 end

 def west_article_url(article, html_suffix = true)
     if article.redirect_to.present?
       article.redirect_to
     else
       url = "#{Settings.western_host}/articles/#{article.created_at.strftime("%Y-%m-%d")}/#{article.id}"
       url += ".html" if html_suffix
       url
   end
 end
  
  def article_thumbnail_path(article, version=nil)
    if article and article.image
        begin
          article.image.thumbnail_url(version)
        rescue
          "/images/default-#{version}.gif"
        end
    else
        "/images/default-#{version}.gif"
    end
  end

  def columnist_avatar_path(columnist, version = nil)
    if columnist and columnist.image
      path = columnist.image.columnist_url(version)
       if path.blank?
         "/images/avatar-default.gif"
       else
         path
       end
    else
      "/images/avatar-default.gif"
    end
  end
  
  def user_avatar_path(user, version=nil)
    if user and user.image
      path = user.image.avatar_url(version)
       if path.blank?
         "/images/avatar-default.gif"
       else
         path
       end
    else
      "/images/avatar-default.gif"
    end
  end
  
  def topic_image_path(topic, version=nil)
    if topic and topic.image
      topic.image.topic_url(version)
    else
      "/images/default-topic-#{version}.gif"
    end
  end

  def strip_html_tag(content, truncate_length=120, link=nil)
    content = Nokogiri::HTML(content).search('//text()').text
    content = if link
      truncate(content, :length => truncate_length, :omission => " #{link_to('...', link)}")
    else 
      truncate(content, :length => truncate_length)
    end
    content = content.sub(/[\u3000\s]+/, '')
    
    content
  end
  
  def nbd_truncate(content, truncate_length = 120)
    return "" if content.blank?
    return truncate(content, :length => trancate_length).sub(/[\u3000\s]+/, '')
  end

  def headline_font_size(title)
  	puts title.length
  	if title.length <= 30
  		return 'large'
  	elsif title.length <= 40
  		return 'medium'
  	else
  		return 'small'
  	end
  end

  def index_fragment_name(column)
    "index_page_#{column}_column"
  end
  
  def require_pikachoose
    
  end
  
  def nbd_time_f(time)
    return "" if !time
    time = Time.parse(time) if time.class == String
    if time > 1.hour.ago
      duration = Time.now - time
      range = (duration / 60).to_i
      if range == 0
        "#{duration.to_i}秒前"
      else
        range.to_s + "分钟前"
      end
    elsif time > 24.hour.ago and time < 1.hour.ago
      ((Time.now - time) / 3600 ).to_i.to_s + "小时前"
    else
      time.year == Time.now.year ? time.strftime('%m月%d日 %H:%M') : time.strftime('%Y年%m月%d日 %H:%M')
    end
  end
  
  def nbd_time_f2(time)
    return "" if !time
    time = Time.parse(time) if time.class == String
    time.strftime('%m月%d日 %H:%M')
  end

  def require_fileUpload
    content_for :header_js do
      javascript_include_tag 'jquery.tmpl.min.js', '/utilities/fileUpload/jquery.fileupload.js', '/utilities/fileUpload/jquery.fileupload-ui.js', '/utilities/fileUpload/jquery.iframe-transport.js'
    end
    content_for :header_css do
      stylesheet_link_tag "/utilities/fileUpload/jquery.fileupload-ui.css"
    end
  end

  def require_loopScroll
    content_for :header_js do
      javascript_include_tag '/utilities/loopScroll/loopScroll.js'
    end
  end
    
  def require_slideShow
    content_for :header_js do
      javascript_include_tag '/utilities/slideShow/slideShow.js'
    end
  end
  
  def require_fixedPosition
    content_for :header_js do
      javascript_include_tag '/utilities/fixedPosition/fixedPosition.js'
    end
  end
  
  def require_tinymce
    content_for :header_js do
      javascript_include_tag '/utilities/tiny_mce/jquery.tinymce.js', '/utilities/tiny_mce/tiny_mce.js'
    end
  end
  
  def require_tabs_and_slelects
    content_for :header_js do
      javascript_include_tag '/utilities/tabs/tabs.js', "chosen.jquery.min.js"
    end
    content_for :header_css do
      stylesheet_link_tag "chosen.css"
    end
  end
  
  def require_tabs
    content_for :header_js do
      javascript_include_tag '/utilities/tabs/tabs.js'
    end
  end
  
  def require_autoComplete
    content_for :header_css do
      stylesheet_link_tag '/utilities/autoComplete/autoComplete.css'
    end
    content_for :header_js do
      javascript_include_tag '/utilities/adjustElement/adjustElement.js', '/utilities/autoComplete/autoComplete.js'
    end
  end
  
  def require_popWin
    content_for :header_css do
      stylesheet_link_tag '/utilities/popWin/popWin.css'
    end
    content_for :header_js do
      javascript_include_tag '/utilities/popWin/popWin.js', '/utilities/popWin/popManager.js'
    end
  end
  
  
  def require_validator
    content_for :header_css do
      stylesheet_link_tag '/utilities/validator/validator.css'
    end
    content_for :header_js do
      javascript_include_tag '/utilities/validator/validator.js'
    end
  end
  
  def require_adjustElement
    content_for :header_js do
      javascript_include_tag '/utilities/adjustElement/adjustElement.js'
    end
  end
  
  def require_jqueryUI
    content_for :header_css do
      stylesheet_link_tag '/utilities/jqueryUI/jquery_ui_1.8.16.custom.css'
    end
    content_for :header_js do
      javascript_include_tag '/utilities/jqueryUI/jquery_ui.min.js', '/utilities/jqueryUI/jquery.ui.datepicker-zh-CN.js'
    end
  end
  
  def require_js(path)
    content_for :header_js do
      include_js_tag path
    end
  end
  
  def require_css(path)
    content_for :header_css do
      include_css_tag path
    end
  end
  
  def include_js_tag(path)
    if not path.starts_with?("http:")
      path = "/javascripts/" + path
    end
    javascript_include_tag path
  end
  
  def include_css_tag(path)
    if not path.starts_with?("http:")
      path = "/stylesheets/" + path
    end
    stylesheet_link_tag path
  end
  
  #	paginate分页样式
  #	作者：robert
  #	日期:  2011-8-2
  #	修改历史：
  #	修改日期    修改者     修改内容
  #
  #	@param str 记录集
  # return HTML
  def paginate_string str
    if str.present?
      will_paginate  str ,:prev_label   => 'preview', :next_label   => 'next'
    end
  end
  
  def article_paginate(article, page, options={})
    links_str = ""
    links_str << link_to("上一页", article_page_path(article, page.p_index - 1, options[:for_subdomain]), options) if page.p_index > 1
     (1..(article.pages.count)).each do |index|
      if page.p_index == index
        links_str << "<b>#{page.p_index}</b>".html_safe
      else
        links_str << link_to(index, article_page_path(article, index, options[:for_subdomain]), options)
        options.delete(:class)
      end
    end
    links_str << link_to("下一页", article_page_path(article, page.p_index + 1, options[:for_subdomain]), options) if page.p_index < article.pages.count
    
    return links_str.html_safe
  end  

  def gms_article_paginate(gms_article,article, page, options={})
    links_str = ""
    if article.pages.count == 1
      return links_str
    end
    if @show_type !='console'
      links_str << link_to("上一页", premium_gms_article_path(gms_article, :p_index => page.p_index - 1)) if page.p_index > 1
       (1..(article.pages.count)).each do |index|
        if page.p_index == index
          links_str << "<b>#{page.p_index}</b>".html_safe
        else
          links_str << link_to(index, premium_gms_article_path(gms_article, :p_index => index))
          options.delete(:class)
        end
      end
      links_str << link_to("下一页", premium_gms_article_path(gms_article,:p_index => page.p_index + 1)) if page.p_index < article.pages.count
    else
      links_str << link_to("上一页", console_premium_gms_article_path(gms_article, :p_index => page.p_index - 1)) if page.p_index > 1
         (1..(article.pages.count)).each do |index|
          if page.p_index == index
            links_str << "<b>#{page.p_index}</b>".html_safe
          else
            links_str << link_to(index, console_premium_gms_article_path(gms_article, :p_index => index))
            options.delete(:class)
          end
        end
        links_str << link_to("下一页", console_premium_gms_article_path(gms_article,:p_index => page.p_index + 1)) if page.p_index < article.pages.count
    end
    return links_str.html_safe
  end  
  
  def article_page_path(article, index, for_subdomain = false)
    return "#{article_url(article, false)}/page/#{index}" unless for_subdomain
    prefix = send("#{for_subdomain}_article_url", article, false)
    "#{prefix}/page/#{index}" 
  end
  
  def article_paginate_mobile(article, page, options={})
    links_str = ""
     (1..(article.pages.count)).each do |index|
      if page.p_index == index
        links_str << "<b>#{page.p_index}</b>".html_safe
      else
        links_str << link_to(index, article_page_path_mobile(article, index), options)
        options.delete(:class)
      end
    end
    
    return links_str.html_safe
  end
  
  def article_page_path_mobile(article, index)
    "#{article_url_mobile(article, false)}/page/#{index}"
  end
  

  def user_job(user)
    return "主持人" if user.is_compere_of?(@live)
    return "嘉宾" if @live and user.is_guest_of?(@live)
    return ""
  end

  def stats_class_helper(type,filter_type = 'none')
    return "class = 'current'" if filter_type == 'staff_type' and @staff_type == type
    return "class = 'current'" if filter_type == 'staff_status' and @stats_type == type

    if filter_type == 'none'
      if @stats_type == type or @filter_type == type
        return "class = 'current'"
      end
    end
  end

  def resp_article_content(article, content)
    content = sanitize_for_mobile(content)
    controller.render_to_string(:file => "mobile_server/_article_content.html.erb", :locals => {:article => article, :content => content.html_safe})
  end

  def resp_section_content(title, section_updated_time, content)
    content = sanitize_for_mobile(content)
    controller.render_to_string(:file => "mobile_server/_section_content.html.erb", :locals => {:section_title => title, :content => content.html_safe, :section_updated_time => section_updated_time})
  end

  def sanitize_for_mobile(content)
    tags = %w(a acronym b strong i em li ul ol h1 h2 h3 h4 h5 h6 blockquote br cite sub sup ins p)
    s = sanitize(content, :tags => tags, :attributes => %w(href title))
  end
  
  def number_percentage(current_count, total_count, precision)
    if current_count.to_i == 0
      number_to_percentage(0, :precision => 0)
    else
      number_to_percentage((1.0*(current_count)/(total_count==0 ? 1 : total_count))*100, :precision => precision)
    end
  end

  def minimal_percentage(value, default_value = 1)
    if value < (default_value) and value > 0
      return number_to_percentage(default_value, :precision => 3)
    else
      return number_to_percentage(value, :precision => 3)
    end
  end

  def feature_image_tag(url, image)
    content_tag "p" do
      if !url.blank?
        link_to image_tag((image.try(:feature_url) || ""), :class => "full_image", :alt => image.try(:desc)), url, :target => "_blank"
      else
        image_tag (image.try(:feature_url) || "")
      end
    end
  end

  def link_to_desc(desc, url)
    if desc.present?
      content_tag "div", :class => "imageDesc" do
        desc.html_safe
      end
    end
  end

  def nbd_cache(name = {}, proxyable = false, options = nil, &block)
    unless proxyable
      cache(name, options , &block)
    else
      yield
    end
  end
end
