object false
child @lives do
  attributes :title, :id
  node(:status){|live| live.live_status}
  node(:image){|live| ""}
  node(:type){|live| live.l_type}
  node(:user_name){|live| live.user.nickname}
  node(:status){|live| live.live_status}
  node(:start_at){|live| live.start_at.to_i*1000}
  node(:end_at){|live| (live.end_at.to_i*1000)}
end
