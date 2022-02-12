# Basic authorization example with CRUD permission based on :permission_type
# and :genre permission based on :album_genre in order to test index method scoping
# and more complex object attribute based authorization
class AlbumPolicy < ApplicationPolicy
  def index?
    user_has_action_permission?(:read)
  end

  def show?
    user_has_action_permission?(:read) && user_has_genre_permission?
  end

  def create?
    user_has_action_permission?(:create) && user_has_genre_permission?
  end

  def update?
    user_has_action_permission?(:update) && user_has_genre_permission?
  end

  def destroy?
    user_has_action_permission?(:destroy) && user_has_genre_permission?
  end

  private

  def user_has_genre_permission?
    user.album_genre == :all || record.genre.blank? || record.genre == user.album_genre.to_s
  end

  class Scope < Scope
    def resolve
      if Album.genres.key?(user.album_genre.to_s)
        scope.send(user.album_genre)
      elsif user.album_genre == :all
        scope.all
      else
        scope.none
      end
    end
  end
end
