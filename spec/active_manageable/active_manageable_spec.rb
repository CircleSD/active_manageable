# frozen_string_literal: true

require "rails_helper"

RSpec.describe ActiveManageable do
  it "has a version number" do
    expect(ActiveManageable::VERSION).not_to be_nil
  end
end
