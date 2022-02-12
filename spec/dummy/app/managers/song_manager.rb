class SongManager < ActiveManageable::Base
  manageable ActiveManageable::ALL_METHODS
  default_includes :album
end
