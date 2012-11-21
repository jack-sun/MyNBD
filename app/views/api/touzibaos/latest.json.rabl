object false

node(:access_token){@current_user.try(:valid_access_token) || ""}
child @touzibaos do
  extends "api/touzibaos/touzibao"
end
