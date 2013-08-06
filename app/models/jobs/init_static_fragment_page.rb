require 'rubygems'
require 'fileutils'
require 'chinese_pinyin'
require 'nbd/utils'
require 'action_pack'
require './app/helpers/application_helper'
require 'static_page/util'
# include Rails.application.routes.url_helpers
include ActionView::Helpers::TagHelper
include StaticPage::Util
include NBD::RemoteSsh
include ApplicationHelper
class Jobs::InitStaticFragmentPage

  @queue = :article_fragment_static_page

  def self.perform
    init_fragmet_job
  end
end
