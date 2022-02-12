class Album < ApplicationRecord
  before_destroy { throw(:abort) unless can_destroy? }

  belongs_to :label, optional: true
  belongs_to :artist, optional: true
  has_many :songs, dependent: :destroy
  accepts_nested_attributes_for :artist
  accepts_nested_attributes_for :songs, allow_destroy: true

  enum genre: {
    electronic: 0,
    dance: 1,
    rock: 2,
    indie: 3,
    pop: 4
  }

  validates :name, presence: true

  scope :released_in_1970s, lambda { where("released_at >= ? AND released_at <= ?", "1970-01-01", "1979-12-31") }
  scope :released_in_1980s, lambda { where("released_at >= ? AND released_at <= ?", "1980-01-01", "1989-12-31") }
  scope :released_in_1990s, lambda { where("released_at >= ? AND released_at <= ?", "1990-01-01", "1999-12-31") }
  scope :released_in_2000s, lambda { where("released_at >= ? AND released_at <= ?", "2000-01-01", "2009-12-31") }
  scope :released_in_2010s, lambda { where("released_at >= ? AND released_at <= ?", "2010-01-01", "2019-12-31") }
  scope :released_in_year, ->(year) { where("strftime('%Y', released_at) = ?", year.to_s) }
  scope :genre_and_released_in_year, ->(genre, year) { where(genre: genre).released_in_year(year) }

  def can_destroy?
    if rock?
      errors.add(:base, "You cannot delete a rock album")
      false
    else
      true
    end
  end
end
