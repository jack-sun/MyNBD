object false
node(:code){0}
node(:msg){"success"}
child "result" => "result" do
  node(:status){1}
  child(@article){extends "api/articles/show"}
end
