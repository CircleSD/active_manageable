class Song < ApplicationRecord
  belongs_to :album, optional: true
  belongs_to :artist, optional: true
end
