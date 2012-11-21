object false
node(:access_token){@current_user.try(:valid_access_token) || ""}
child(@touzibao) do
  extends "api/touzibaos/touzibao"
end
