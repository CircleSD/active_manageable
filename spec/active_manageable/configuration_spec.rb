# frozen_string_literal: true

require "rails_helper"

module ActiveManageable
  RSpec.describe Configuration do
    before do
      ActiveManageable.configuration = ActiveManageable::Configuration.new
    end

    describe ".configuration" do
      it "returns a ActiveManageable::Configuration instance" do
        expect(ActiveManageable.configuration).to be_a_kind_of(ActiveManageable::Configuration)
      end

      it "defaults the authorization library to nil" do
        expect(ActiveManageable.configuration.authorization_library).to be_nil
      end

      it "defaults the search library to nil" do
        expect(ActiveManageable.configuration.search_library).to be_nil
      end

      it "defaults the pagination library to nil" do
        expect(ActiveManageable.configuration.pagination_library).to be_nil
      end

      it "defaults the loading method to :includes" do
        expect(ActiveManageable.configuration.default_loading_method).to eq(:includes)
      end

      it "defaults the subclass suffix to Manager" do
        expect(ActiveManageable.configuration.subclass_suffix).to eq("Manager")
      end

      describe "#authorization_library" do
        it "returns the default authorization library" do
          expect(ActiveManageable.configuration.authorization_library).to be_nil
        end

        it "sets the authorization library to :pundit" do
          ActiveManageable.configuration.authorization_library = :pundit
          expect(ActiveManageable.configuration.authorization_library).to eq(:pundit)
        end

        it "sets the authorization library to :cancancan" do
          ActiveManageable.configuration.authorization_library = :cancancan
          expect(ActiveManageable.configuration.authorization_library).to eq(:cancancan)
        end

        it "converts the authorization library to a symbol" do
          ActiveManageable.configuration.authorization_library = "pundit"
          expect(ActiveManageable.configuration.authorization_library).to eq(:pundit)
        end

        it "raises an error when the authorization library is an invalid string" do
          expect { ActiveManageable.configuration.authorization_library = "boom!" }.to raise_error(ArgumentError)
        end

        it "raises an error when the authorization library is an empty string" do
          expect { ActiveManageable.configuration.authorization_library = "" }.to raise_error(ArgumentError)
        end

        it "raises an error when the authorization library is nil" do
          expect { ActiveManageable.configuration.authorization_library = nil }.to raise_error(ArgumentError)
        end

        it "raises an error when the authorization library is an invalid symbol" do
          expect { ActiveManageable.configuration.authorization_library = :ransack }.to raise_error(ArgumentError)
        end
      end

      describe "#search_library" do
        it "returns the default search library" do
          expect(ActiveManageable.configuration.search_library).to be_nil
        end

        it "sets the search library to :ransack" do
          ActiveManageable.configuration.search_library = :ransack
          expect(ActiveManageable.configuration.search_library).to eq(:ransack)
        end

        it "converts the search library to a symbol" do
          ActiveManageable.configuration.search_library = "ransack"
          expect(ActiveManageable.configuration.search_library).to eq(:ransack)
        end

        it "raises an error when the search library is an invalid string" do
          expect { ActiveManageable.configuration.search_library = "boom!" }.to raise_error(ArgumentError)
        end

        it "raises an error when the search library is an empty string" do
          expect { ActiveManageable.configuration.search_library = "" }.to raise_error(ArgumentError)
        end

        it "raises an error when the search library is nil" do
          expect { ActiveManageable.configuration.search_library = nil }.to raise_error(ArgumentError)
        end

        it "raises an error when the search library is an invalid symbol" do
          expect { ActiveManageable.configuration.search_library = :pundit }.to raise_error(ArgumentError)
        end
      end

      describe "#pagination_library" do
        it "returns the default pagination library" do
          expect(ActiveManageable.configuration.pagination_library).to be_nil
        end

        it "sets the pagination library to :kaminari" do
          ActiveManageable.configuration.pagination_library = :kaminari
          expect(ActiveManageable.configuration.pagination_library).to eq(:kaminari)
        end

        it "converts the pagination library to a symbol" do
          ActiveManageable.configuration.pagination_library = "kaminari"
          expect(ActiveManageable.configuration.pagination_library).to eq(:kaminari)
        end

        it "raises an error when the pagination library is an invalid string" do
          expect { ActiveManageable.configuration.pagination_library = "boom!" }.to raise_error(ArgumentError)
        end

        it "raises an error when the pagination library is an empty string" do
          expect { ActiveManageable.configuration.pagination_library = "" }.to raise_error(ArgumentError)
        end

        it "raises an error when the pagination library is nil" do
          expect { ActiveManageable.configuration.pagination_library = nil }.to raise_error(ArgumentError)
        end

        it "raises an error when the pagination library is an invalid symbol" do
          expect { ActiveManageable.configuration.pagination_library = :pundit }.to raise_error(ArgumentError)
        end
      end

      describe "#default_loading_method" do
        it "returns the default loading method" do
          expect(ActiveManageable.configuration.default_loading_method).to eq(:includes)
        end

        it "sets the loading method to :includes" do
          ActiveManageable.configuration.default_loading_method = :includes
          expect(ActiveManageable.configuration.default_loading_method).to eq(:includes)
        end

        it "sets the loading method to :preload" do
          ActiveManageable.configuration.default_loading_method = :preload
          expect(ActiveManageable.configuration.default_loading_method).to eq(:preload)
        end

        it "sets the loading method to :eager_load" do
          ActiveManageable.configuration.default_loading_method = :eager_load
          expect(ActiveManageable.configuration.default_loading_method).to eq(:eager_load)
        end

        it "converts the loading method to a symbol" do
          ActiveManageable.configuration.default_loading_method = "preload"
          expect(ActiveManageable.configuration.default_loading_method).to eq(:preload)
        end

        it "raises an error when the loading method is an invalid string" do
          expect { ActiveManageable.configuration.default_loading_method = "boom!" }.to raise_error(ArgumentError)
        end

        it "raises an error when the loading method is an empty string" do
          expect { ActiveManageable.configuration.default_loading_method = "" }.to raise_error(ArgumentError)
        end

        it "raises an error when the loading method is nil" do
          expect { ActiveManageable.configuration.default_loading_method = nil }.to raise_error(ArgumentError)
        end

        it "raises an error when the loading method is an invalid symbol" do
          expect { ActiveManageable.configuration.default_loading_method = :pundit }.to raise_error(ArgumentError)
        end
      end

      describe "#subclass_suffix" do
        it "returns the default subclass suffix" do
          expect(ActiveManageable.configuration.subclass_suffix).to eq("Manager")
        end

        it "sets the subclass suffix" do
          ActiveManageable.configuration.subclass_suffix = "Concern"
          expect(ActiveManageable.configuration.subclass_suffix).to eq("Concern")
        end
      end
    end

    describe ".config" do
      it "yields the ActiveManageable::Configuration instance" do
        ActiveManageable.configuration.authorization_library = :pundit
        expect(ActiveManageable.config { |config| config.authorization_library }).to eq(:pundit)
      end

      it "sets the configuration options" do
        ActiveManageable.config do |config|
          config.authorization_library = :pundit
          config.search_library = :ransack
        end
        expect(ActiveManageable.configuration.authorization_library).to eq(:pundit)
        expect(ActiveManageable.configuration.search_library).to eq(:ransack)
      end
    end
  end
end
