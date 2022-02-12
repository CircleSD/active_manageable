class AlbumManager < ActiveManageable::Base
  manageable ActiveManageable::ALL_METHODS
  # manageable :index, :new, :create, model_class: Album

  has_unique_search
  # has_unique_search if: -> { make_search_unique }

  default_order :name, :created_at # "name DESC"

  default_page_size 5

  default_scopes :electronic
  # default_scopes :rock, :electronic, {released_in_year: "1980"}
  # default_scopes -> { index_scopes }

  default_includes :songs
  # default_includes :songs, methods: :show
  # default_includes :songs, methods: [:index, :edit], loading_method: :eager_load
  # default_includes -> { method_includes }

  # default_select :id, :name

  default_attribute_values -> { {genre: "electronic", published_at: Date.current} }
  # default_attribute_values genre: "electronic"
  # default_attribute_values genre: "pop", released_at: Date.current, methods: :new
  # default_attribute_values -> { default_attrs }
  # default_attribute_values -> { default_attrs }, methods: [:new, :create]

  def index_scopes
    [{released_in_year: "1970"}, {released_in_year: "1990"}, "indie"]
  end

  def default_attrs
    {genre: "pop", released_at: Date.current}
  end

  def make_search_unique
    options[:unique] == true
  end

  def method_includes
    case current_method
    when :index
      {songs: :artist}
    when :show
      [:label, :songs]
    when :edit, :update
      [:label, songs: :artists]
    else
      :songs
    end
  end
end
