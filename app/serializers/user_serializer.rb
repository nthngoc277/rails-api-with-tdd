class UserSerializer < ActiveModel::Serializer
  attributes :id, :login, :name, :url, :avatar_url
end
