Factory.define(:mention) do |f|
  f.association :user
  f.target :ori_weibo
end
