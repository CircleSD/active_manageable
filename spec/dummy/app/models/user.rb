class User < ApplicationRecord
  validates :name, :email, presence: true

  # :none, :manage, :read, :create, :update, :destroy
  attr_writer :permission_type

  def permission_type
    @permission_type ||= :manage
  end

  attr_writer :album_genre

  # :all plus any of the album genre keys
  def album_genre
    @album_genre ||= :all
  end
end
