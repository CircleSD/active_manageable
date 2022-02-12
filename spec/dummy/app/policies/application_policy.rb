# frozen_string_literal: true

# Basic authorization example with CRUD permission based on :permission_type
class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    user_has_action_permission?(:read)
  end

  def show?
    index?
  end

  def create?
    user_has_action_permission?(:create)
  end

  def new?
    create?
  end

  def update?
    user_has_action_permission?(:update)
  end

  def edit?
    update?
  end

  def destroy?
    user_has_action_permission?(:destroy)
  end

  private

  def user_has_action_permission?(action)
    [:manage, action].include?(user.permission_type)
  end

  class Scope
    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      scope.all
    end

    private

    attr_reader :user, :scope
  end
end
