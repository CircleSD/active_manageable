ActiveManageable.config do |config|
  config.authorization_library = :pundit
  config.search_library = :ransack
  config.pagination_library = :kaminari
end
