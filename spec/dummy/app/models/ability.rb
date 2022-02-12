# frozen_string_literal: true

class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new

    # Basic authorization example with CRUD permission based on :permission_type
    # and Album :genre permission based on :album_genre in order to test index method scoping
    # and more complex object attribute based authorization
    case user.permission_type
    when :none
      cannot :manage, :all
    when :manage
      can :create, Album, genre: nil
      can :manage, Album, genre: allowed_genres(user)
      can :manage, [Song, Artist]
    when :read
      can :read, Album, genre: allowed_genres(user)
      can :read, [Song, Artist]
    when :create
      can :create, Album, genre: nil
      can :create, Album, genre: allowed_genres(user)
      can :create, [Song, Artist]
    when :update
      can :update, Album, genre: allowed_genres(user)
      can :update, [Song, Artist]
    when :destroy
      can :destroy, Album, genre: allowed_genres(user)
      can :destroy, [Song, Artist]
    end

    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  end

  def allowed_genres(user)
    if user.album_genre == :all
      Album.genres.keys
    else
      user.album_genre.to_s
    end
  end
end
