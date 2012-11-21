Factory.define(:user) do |f|
  f.email "taijcjc@gmail.com"
  f.nickname "jason"
  f.password "woshi1989"
end

Factory.define(:user1, :class => User) do |f|
  f.email "tjcjc@qq.com"
  f.nickname "tai"
  f.password "woshi1989"
end
