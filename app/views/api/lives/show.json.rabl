object false
child @live do
  attributes :title, :id
  node(:status){|live| live.live_status}
  node(:start_at){|live| live.start_at.to_i*1000}
  node(:end_at){|live| (live.end_at.to_i*1000)}
  node(:image){|live| live.image.try(:feature_url)}
  node(:type){|live| live.l_type}
  child @live_talks => :talks do
    attributes :id, :type
    node(:user_name){|t| t.weibo.owner.nickname }
    node(:content){|t| t.weibo.content }
    node(:avatar){|t| user_avatar_path(t.weibo.owner)}
    node(:created_at){|t| (t.created_at.to_i * 1000)}
    node(:answers){|t| []}
#   child :live_answers => :answers do
#     attributes :id
#     node(:user_name){|t| t.weibo.owner.nickname }
#     node(:content){|t| t.weibo.content }
#     node(:avatar){|t| user_avatar_path(t.weibo.owner)}
#     node(:created_at){|t| (t.created_at.to_i * 1000)}
#   end
  end
end
