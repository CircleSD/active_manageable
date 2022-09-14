# frozen_string_literal: true

require "rails_helper"
require "support/shared_examples/default_attribute_values"
require "support/shared_examples/normalize_attributes"

module ActiveManageable
  module Methods
    RSpec.describe Create do
      before do
        ActiveManageable.configuration = ActiveManageable::Configuration.new
      end

      include_examples ".default_attribute_values", :create

      describe "#create" do
        let(:artist) { FactoryBot.create(:artist, name: "Massive Attack") }

        before do
          test_class = Class.new(ActiveManageable::Base) do
            manageable :create, model_class: Album
          end

          stub_const("TestClass", test_class)
        end

        it "sets the :target variable" do
          tc = TestClass.new
          tc.instance_variable_set(:@target, Album.first)
          tc.create(attributes: {name: "Blue Lines"})
          expect(tc.target).to be_a(ApplicationRecord)
        end

        it "exposes the :target variable via the #object method" do
          tc = TestClass.new
          tc.create(attributes: {name: "Blue Lines"})
          expect(tc.object).to eq(tc.target)
        end

        it "sets the :current_method variable" do
          tc = TestClass.new
          tc.create(attributes: {name: "Blue Lines"})
          expect(tc.current_method).to eq(:create)
        end

        context "when the attributes argument is a Hash" do
          it "sets the :attributes variable to an ActiveSupport::HashWithIndifferentAccess" do
            tc = TestClass.new
            attributes = {name: "Blue Lines", genre: Album.genres[:electronic], released_at: "1991-06-01"}
            tc.create(attributes: attributes)
            expect(tc.attributes).to be_a(ActiveSupport::HashWithIndifferentAccess)
            expect(tc.attributes).to eq({name: "Blue Lines", genre: Album.genres[:electronic], released_at: Date.parse("1991-06-01")}.with_indifferent_access)
            expect(tc.attributes.object_id).not_to eq(attributes.object_id)
            attributes[:original] = true
            expect(tc.attributes).not_to be_key(:original)
          end
        end

        context "when the attributes argument is an ActiveSupport::HashWithIndifferentAccess" do
          it "sets the :attributes variable to a duplicate ActiveSupport::HashWithIndifferentAccess" do
            tc = TestClass.new
            attributes = {name: "Blue Lines", genre: Album.genres[:electronic], released_at: "1991-06-01"}.with_indifferent_access
            tc.create(attributes: attributes)
            expect(tc.attributes).to be_a(ActiveSupport::HashWithIndifferentAccess)
            expect(tc.attributes).to eq({name: "Blue Lines", genre: Album.genres[:electronic], released_at: Date.parse("1991-06-01")}.with_indifferent_access)
            expect(tc.attributes.object_id).not_to eq(attributes.object_id)
            attributes[:original] = true
            expect(tc.attributes).not_to be_key(:original)
          end
        end

        context "when the attributes argument is an ActionController::Parameters" do
          it "sets the :attributes variable to an ActiveSupport::HashWithIndifferentAccess" do
            tc = TestClass.new
            attributes = ActionController::Parameters.new(name: "Blue Lines", genre: Album.genres[:electronic], released_at: "1991-06-01").permit(:name, :genre, :released_at)
            tc.create(attributes: attributes)
            expect(tc.attributes).to be_a(ActiveSupport::HashWithIndifferentAccess)
            expect(tc.attributes).to eq({name: "Blue Lines", genre: Album.genres[:electronic], released_at: Date.parse("1991-06-01")}.with_indifferent_access)
          end

          it "sets the :attributes variable including only permitted parameters" do
            tc = TestClass.new
            attributes = ActionController::Parameters.new(name: "Blue Lines", genre: Album.genres[:electronic], artist_attributes: {name: "Massive Attack", published_at: "2022-02-22"}).permit(:name, artist_attributes: [:name])
            tc.create(attributes: attributes)
            expect(tc.attributes).to be_a(ActiveSupport::HashWithIndifferentAccess)
            expect(tc.attributes).to eq({name: "Blue Lines", artist_attributes: {name: "Massive Attack"}}.with_indifferent_access)
          end

          it "sets the :attributes variable including a permitted nested parameters ActionController::Parameters" do
            tc = TestClass.new
            # build params so that the artist_attributes value is an ActionController::Parameters
            attributes = ActionController::Parameters.new(name: "Blue Lines", artist_attributes: {name: "Massive Attack"}).permit(:name, artist_attributes: [:name])
            tc.create(attributes: attributes)
            expect(tc.attributes).to be_a(ActiveSupport::HashWithIndifferentAccess)
            expect(tc.attributes).to eq({name: "Blue Lines", artist_attributes: {name: "Massive Attack"}}.with_indifferent_access)
          end

          it "sets the :attributes variable including a permitted nested parameters hash" do
            tc = TestClass.new
            # build params & permit then update the artist_attributes value to a Hash
            # to ensure that the method does not result in an ActiveModel::ForbiddenAttributesError
            attributes = ActionController::Parameters.new(name: "Blue Lines", artist_attributes: {name: "Massive Attack"}).permit(:name, artist_attributes: [:name])
            attributes[:artist_attributes] = {name: "Massive Attack"}
            tc.create(attributes: attributes)
            expect(tc.attributes).to be_a(ActiveSupport::HashWithIndifferentAccess)
            expect(tc.attributes).to eq({name: "Blue Lines", artist_attributes: {name: "Massive Attack"}}.with_indifferent_access)
            expect(tc.attributes.object_id).not_to eq(attributes.object_id)
            attributes[:original] = true
            expect(tc.attributes).not_to be_key(:original)
          end
        end

        context "when the attributes argument is not a Hash or ActionController::Parameters" do
          it "raises an error when assigning attributes" do
            expect { TestClass.new.create(attributes: ["boom!"]) }.to raise_error(ArgumentError)
          end
        end

        it "initializes the :options variable to an empty ActiveSupport::HashWithIndifferentAccess" do
          tc = TestClass.new
          tc.instance_variable_set(:@options, {name: "test"})
          tc.create(attributes: {name: "Blue Lines"})
          expect(tc.options).to be_a(ActiveSupport::HashWithIndifferentAccess)
          expect(tc.options).to eq({})
        end

        include_examples "#normalize_attributes", :create

        context "when the creation of the record succeeds" do
          it "returns true" do
            expect(TestClass.new.create(attributes: {name: "Blue Lines"})).to be(true)
          end

          it "sets the :target variable" do
            tc = TestClass.new
            tc.create(attributes: {name: "Blue Lines"})
            expect(tc.target).to be_a(Album)
            expect(tc.target).to be_persisted
          end
        end

        context "when the creation of the record fails" do
          it "returns false" do
            expect(TestClass.new.create(attributes: {genre: Album.genres[:electronic]})).to be(false)
          end

          it "sets the :target variable making the errors accessible" do
            tc = TestClass.new
            tc.create(attributes: {genre: Album.genres[:electronic]})
            expect(tc.target).to be_a(Album)
            expect(tc.target).not_to be_persisted
            expect(tc.target.errors[:name][0]).to eq(I18n.t("errors.messages.blank"))
          end
        end

        context "with an attributes hash of symbol keys and data type values" do
          it "creates a record and associated records" do
            tc = TestClass.new
            attributes = {name: "Blue Lines", released_at: Date.new(1991, 4, 8), length: BigDecimal("45.04"), published_at: Time.zone.now.change(sec: 0), artist_attributes: {name: "Massive Attack", published_at: Time.zone.now.change(sec: 0)}, songs_attributes: [{name: "Safe From Harm", length: Float("5.18"), published_at: Time.zone.now.change(sec: 0)}, {name: "Unfinished Sympathy", length: Float("5.08"), published_at: Time.zone.now.change(sec: 0)}]}
            expect(tc.create(attributes: attributes)).to be(true)
            expect(tc.object).to be_persisted
            expect(tc.object).to have_attributes(attributes.slice(:name, :released_at, :length, :published_at))
            check_belongs_to(tc.object, :artist, attributes[:artist_attributes])
            check_has_many(tc.object, :songs, 2, attributes[:songs_attributes])
          end
        end

        context "with an attributes hash of string keys and values" do
          it "creates a record and associated records" do
            tc = TestClass.new
            attributes = {"name" => "Blue Lines", "released_at" => "1991-04-08", "length" => "45.04", "published_at" => "2022-01-26 14:21", "artist_attributes" => {"name" => "Massive Attack", "published_at" => "2022-01-26 14:21"}, "songs_attributes" => [{"name" => "Safe From Harm", "length" => "5.18", "published_at" => "2022-01-26 14:21"}, {"name" => "Unfinished Sympathy", "length" => "5.08", "published_at" => "2022-01-26 14:21"}]}
            expect(tc.create(attributes: attributes)).to be(true)
            # album
            attributes = attributes.with_indifferent_access
            attributes[:released_at] = Date.parse(attributes[:released_at])
            attributes[:length] = BigDecimal(attributes[:length])
            attributes[:published_at] = Time.zone.parse(attributes[:published_at])
            expect(tc.object).to be_persisted
            expect(tc.object).to have_attributes(attributes.slice(:name, :released_at, :length, :published_at))
            # artist
            attributes[:artist_attributes][:published_at] = Time.zone.parse(attributes[:artist_attributes][:published_at])
            check_belongs_to(tc.object, :artist, attributes[:artist_attributes])
            # songs
            attributes[:songs_attributes].each_with_index do |attrs, i|
              attrs[:length] = Float(attrs[:length])
              attrs[:published_at] = Time.zone.parse(attrs[:published_at])
            end
            check_has_many(tc.object, :songs, 2, attributes[:songs_attributes])
          end
        end

        context "with an attributes hash containing date, datetime, decimal and float values that need to be normalized" do
          it "creates a record and associated records" do
            tc = TestClass.new
            attributes = {"name" => "Blue Lines", "released_at" => "8-4-91", "length" => "45,04", "published_at" => "26.1.22 14.21", "artist_attributes" => {"name" => "Massive Attack", "published_at" => "26.1.22 14.21"}, "songs_attributes" => [{"name" => "Safe From Harm", "length" => "5,18", "published_at" => "26.1.22 14.21"}, {"name" => "Unfinished Sympathy", "length" => "5,08", "published_at" => "26.1.22 14.21"}]}
            I18n.with_locale(:nl) do
              expect(tc.create(attributes: attributes)).to be(true)
            end
            # album
            attributes = attributes.with_indifferent_access
            attributes[:released_at] = Date.parse("1991-04-08")
            attributes[:length] = BigDecimal(attributes[:length].tr(",", "."))
            attributes[:published_at] = Time.zone.parse("2022-01-26 14:21")
            expect(tc.object).to be_persisted
            expect(tc.object).to have_attributes(attributes.slice(:name, :released_at, :length, :published_at))
            # artist
            attributes[:artist_attributes][:published_at] = Time.zone.parse("2022-01-26 14:21")
            check_belongs_to(tc.object, :artist, attributes[:artist_attributes])
            # songs
            attributes[:songs_attributes].each_with_index do |attrs, i|
              attrs[:length] = Float(attrs[:length].tr(",", "."))
              attrs[:published_at] = Time.zone.parse("2022-01-26 14:21")
            end
            check_has_many(tc.object, :songs, 2, attributes[:songs_attributes])
          end
        end

        context "with an attributes params containing date, datetime, decimal and float values that need to be normalized" do
          it "creates a record and associated records" do
            tc = TestClass.new
            attributes = ActionController::Parameters.new(name: "Blue Lines", released_at: "8-4-91", length: "45,04", published_at: "26.1.22 14.21", artist_attributes: {name: "Massive Attack", published_at: "26.1.22 14.21"}, songs_attributes: [{name: "Safe From Harm", length: "5,18", published_at: "26.1.22 14.21"}, {name: "Unfinished Sympathy", length: "5,08", published_at: "26.1.22 14.21"}]).permit(:name, :released_at, :length, :published_at, artist_attributes: [:name, :published_at], songs_attributes: [:name, :length, :published_at])
            I18n.with_locale(:nl) do
              expect(tc.create(attributes: attributes)).to be(true)
            end
            # album
            attributes[:released_at] = Date.parse("1991-04-08")
            attributes[:length] = BigDecimal(attributes[:length].tr(",", "."))
            attributes[:published_at] = Time.zone.parse("2022-01-26 14:21")
            expect(tc.object).to be_persisted
            expect(tc.object).to have_attributes(attributes.slice(:name, :released_at, :length, :published_at).to_h)
            # artist
            attributes[:artist_attributes][:published_at] = Time.zone.parse("2022-01-26 14:21")
            check_belongs_to(tc.object, :artist, attributes[:artist_attributes].to_h)
            # songs
            attributes[:songs_attributes].each_with_index do |attrs, i|
              attrs[:length] = Float(attrs[:length].tr(",", "."))
              attrs[:published_at] = Time.zone.parse("2022-01-26 14:21")
            end
            check_has_many(tc.object, :songs, 2, attributes[:songs_attributes].map(&:to_h))
          end
        end

        def check_belongs_to(object, association, attributes)
          expect(object.send(association)).to be_present
          expect(object.send(association)).to be_persisted
          expect(object.send(association)).to have_attributes(attributes)
        end

        def check_has_many(object, association, size, attributes)
          expect(object.send(association)).to be_present
          expect(object.send(association).size).to eq(size)
          (0..size - 1).each do |idx|
            expect(object.send(association)[idx]).to be_persisted
            expect(object.send(association)[idx]).to have_attributes(attributes[idx])
          end
        end

        describe "#model_attributes" do
          context "without class default attributes" do
            context "without :attributes argument" do
              it "fails to to create a record and returns false" do
                expect(TestClass.new.create(attributes: {})).to be(false)
              end
            end

            context "with :attributes argument" do
              it "creates a record with :attributes argument and returns true" do
                tc = TestClass.new
                attributes = {name: "Blue Lines", artist_id: artist.id, genre: "electronic", released_at: Date.new(1991, 6, 1)}
                expect(tc.create(attributes: attributes)).to be(true)
                expect(tc.object).to be_persisted
                expect(tc.object).to have_attributes(attributes)
                expect(Album.find(tc.object.id)).to have_attributes(attributes)
              end
            end
          end

          context "with a class default attributes containing a hash" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :create, model_class: Album
                default_attribute_values name: "Dark Side of the Moon", genre: "rock"
              end

              stub_const("TestClass", test_class)
            end

            context "without :attributes argument" do
              it "creates a record with class default attributes and returns true" do
                tc = TestClass.new
                expect(tc.create(attributes: {})).to be(true)
                expect(tc.object).to be_persisted
                attributes = {name: "Dark Side of the Moon", genre: "rock"}
                expect(tc.object).to have_attributes(attributes)
                expect(Album.find(tc.object.id)).to have_attributes(attributes)
              end
            end

            context "with :attributes argument" do
              it "creates a record with :attributes argument and returns true" do
                tc = TestClass.new
                attributes = {name: "Blue Lines", artist_id: artist.id, genre: "electronic", released_at: Date.new(1991, 6, 1)}
                expect(tc.create(attributes: attributes)).to be(true)
                expect(tc.object).to be_persisted
                expect(tc.object).to have_attributes(attributes)
                expect(Album.find(tc.object.id)).to have_attributes(attributes)
              end

              it "creates a record with merged :attributes argument and class default attributes and returns true" do
                tc = TestClass.new
                attributes = {name: "Wish You Were Here", released_at: Date.new(1975, 9, 12)}
                expect(tc.create(attributes: attributes)).to be(true)
                expect(tc.object).to be_persisted
                attributes = {name: "Wish You Were Here", released_at: Date.new(1975, 9, 12), genre: "rock"}
                expect(tc.object).to have_attributes(attributes)
                expect(Album.find(tc.object.id)).to have_attributes(attributes)
              end
            end
          end

          context "with a class default attributes containing a hash for the method" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :new, :create, model_class: Album
                default_attribute_values genre: "electronic", methods: :new
                default_attribute_values name: "Dark Side of the Moon", genre: "rock", methods: :create
              end

              stub_const("TestClass", test_class)
            end

            context "without :attributes argument" do
              it "creates a record with class default attributes and returns true" do
                tc = TestClass.new
                expect(tc.create(attributes: {})).to be(true)
                expect(tc.object).to be_persisted
                attributes = {name: "Dark Side of the Moon", genre: "rock"}
                expect(tc.object).to have_attributes(attributes)
                expect(Album.find(tc.object.id)).to have_attributes(attributes)
              end
            end

            context "with :attributes argument" do
              it "creates a record with :attributes argument and returns true" do
                tc = TestClass.new
                attributes = {name: "Blue Lines", artist_id: artist.id, genre: "electronic", released_at: Date.new(1991, 6, 1)}
                expect(tc.create(attributes: attributes)).to be(true)
                expect(tc.object).to be_persisted
                expect(tc.object).to have_attributes(attributes)
                expect(Album.find(tc.object.id)).to have_attributes(attributes)
              end

              it "creates a record with merged :attributes argument and class default attributes and returns true" do
                tc = TestClass.new
                attributes = {name: "Wish You Were Here", released_at: Date.new(1975, 9, 12)}
                expect(tc.create(attributes: attributes)).to be(true)
                expect(tc.object).to be_persisted
                attributes = {name: "Wish You Were Here", released_at: Date.new(1975, 9, 12), genre: "rock"}
                expect(tc.object).to have_attributes(attributes)
                expect(Album.find(tc.object.id)).to have_attributes(attributes)
              end
            end
          end

          context "with a class default attributes containing a lambda that returns a hash" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :create, model_class: Album
                default_attribute_values -> { create_attributes }

                def create_attributes
                  {name: "Dark Side of the Moon", genre: "rock"}
                end
              end

              stub_const("TestClass", test_class)
            end

            context "without :attributes argument" do
              it "creates a record with class default attributes and returns true" do
                tc = TestClass.new
                expect(tc.create(attributes: {})).to be(true)
                expect(tc.object).to be_persisted
                attributes = {name: "Dark Side of the Moon", genre: "rock"}
                expect(tc.object).to have_attributes(attributes)
                expect(Album.find(tc.object.id)).to have_attributes(attributes)
              end
            end

            context "with :attributes argument" do
              it "creates a record with :attributes argument and returns true" do
                tc = TestClass.new
                attributes = {name: "Blue Lines", artist_id: artist.id, genre: "electronic", released_at: Date.new(1991, 6, 1)}
                expect(tc.create(attributes: attributes)).to be(true)
                expect(tc.object).to be_persisted
                expect(tc.object).to have_attributes(attributes)
                expect(Album.find(tc.object.id)).to have_attributes(attributes)
              end

              it "creates a record with merged :attributes argument and class default attributes and returns true" do
                tc = TestClass.new
                attributes = {name: "Wish You Were Here", released_at: Date.new(1975, 9, 12)}
                expect(tc.create(attributes: attributes)).to be(true)
                expect(tc.object).to be_persisted
                attributes = {name: "Wish You Were Here", released_at: Date.new(1975, 9, 12), genre: "rock"}
                expect(tc.object).to have_attributes(attributes)
                expect(Album.find(tc.object.id)).to have_attributes(attributes)
              end
            end
          end

          context "with a class default attributes containing a proc that returns a hash" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :create, model_class: Album
                default_attribute_values proc { create_attributes }

                def create_attributes
                  {name: "Dark Side of the Moon", genre: "rock"}
                end
              end

              stub_const("TestClass", test_class)
            end

            context "without :attributes argument" do
              it "creates a record with class default attributes and returns true" do
                tc = TestClass.new
                expect(tc.create(attributes: {})).to be(true)
                expect(tc.object).to be_persisted
                attributes = {name: "Dark Side of the Moon", genre: "rock"}
                expect(tc.object).to have_attributes(attributes)
                expect(Album.find(tc.object.id)).to have_attributes(attributes)
              end
            end

            context "with :attributes argument" do
              it "creates a record with :attributes argument and returns true" do
                tc = TestClass.new
                attributes = {name: "Blue Lines", artist_id: artist.id, genre: "electronic", released_at: Date.new(1991, 6, 1)}
                expect(tc.create(attributes: attributes)).to be(true)
                expect(tc.object).to be_persisted
                expect(tc.object).to have_attributes(attributes)
                expect(Album.find(tc.object.id)).to have_attributes(attributes)
              end

              it "creates a record with merged :attributes argument and class default attributes and returns true" do
                tc = TestClass.new
                attributes = {name: "Wish You Were Here", released_at: Date.new(1975, 9, 12)}
                expect(tc.create(attributes: attributes)).to be(true)
                expect(tc.object).to be_persisted
                attributes = {name: "Wish You Were Here", released_at: Date.new(1975, 9, 12), genre: "rock"}
                expect(tc.object).to have_attributes(attributes)
                expect(Album.find(tc.object.id)).to have_attributes(attributes)
              end
            end
          end

          context "with a class default attributes containing a lambda for the method" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :new, :create, model_class: Album
                default_attribute_values -> { new_attributes }, methods: :new
                default_attribute_values -> { create_attributes }, methods: :create

                def new_attributes
                  {genre: "electronic"}
                end

                def create_attributes
                  {name: "Dark Side of the Moon", genre: "rock"}
                end
              end

              stub_const("TestClass", test_class)
            end

            context "without :attributes argument" do
              it "creates a record with class default attributes and returns true" do
                tc = TestClass.new
                expect(tc.create(attributes: {})).to be(true)
                expect(tc.object).to be_persisted
                attributes = {name: "Dark Side of the Moon", genre: "rock"}
                expect(tc.object).to have_attributes(attributes)
                expect(Album.find(tc.object.id)).to have_attributes(attributes)
              end
            end

            context "with :attributes argument" do
              it "creates a record with :attributes argument and returns true" do
                tc = TestClass.new
                attributes = {name: "Blue Lines", artist_id: artist.id, genre: "electronic", released_at: Date.new(1991, 6, 1)}
                expect(tc.create(attributes: attributes)).to be(true)
                expect(tc.object).to be_persisted
                expect(tc.object).to have_attributes(attributes)
                expect(Album.find(tc.object.id)).to have_attributes(attributes)
              end

              it "creates a record with merged :attributes argument and class default attributes and returns true" do
                tc = TestClass.new
                attributes = {name: "Wish You Were Here", released_at: Date.new(1975, 9, 12)}
                expect(tc.create(attributes: attributes)).to be(true)
                expect(tc.object).to be_persisted
                attributes = {name: "Wish You Were Here", released_at: Date.new(1975, 9, 12), genre: "rock"}
                expect(tc.object).to have_attributes(attributes)
                expect(Album.find(tc.object.id)).to have_attributes(attributes)
              end
            end
          end

          context "with a class default attributes containing a lambda that returns nil" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :create, model_class: Album
                default_attribute_values -> { create_attributes }

                def create_attributes
                  nil
                end
              end

              stub_const("TestClass", test_class)
            end

            context "without :attributes argument" do
              it "fails to to create a record and returns false" do
                expect(TestClass.new.create(attributes: {})).to be(false)
              end
            end

            context "with :attributes argument" do
              it "creates a record with :attributes argument and returns true" do
                tc = TestClass.new
                attributes = {name: "Blue Lines", artist_id: artist.id, genre: "electronic", released_at: Date.new(1991, 6, 1)}
                expect(tc.create(attributes: attributes)).to be(true)
                expect(tc.object).to be_persisted
                expect(tc.object).to have_attributes(attributes)
                expect(Album.find(tc.object.id)).to have_attributes(attributes)
              end
            end
          end

          context "with a class default attributes containing a lambda that returns an empty hash" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :create, model_class: Album
                default_attribute_values -> { create_attributes }

                def create_attributes
                  {}
                end
              end

              stub_const("TestClass", test_class)
            end

            context "without :attributes argument" do
              it "fails to to create a record and returns false" do
                expect(TestClass.new.create(attributes: {})).to be(false)
              end
            end

            context "with :attributes argument" do
              it "creates a record with :attributes argument and returns true" do
                tc = TestClass.new
                attributes = {name: "Blue Lines", artist_id: artist.id, genre: "electronic", released_at: Date.new(1991, 6, 1)}
                expect(tc.create(attributes: attributes)).to be(true)
                expect(tc.object).to be_persisted
                expect(tc.object).to have_attributes(attributes)
                expect(Album.find(tc.object.id)).to have_attributes(attributes)
              end
            end
          end
        end

        context "when using the pundit authorization library" do
          before do
            ActiveManageable.configuration.authorization_library = :pundit
            test_class = Class.new(ActiveManageable::Base) do
              manageable :create, model_class: Album
            end

            stub_const("TestClass", test_class)
          end

          describe "#authorize" do
            context "when the current_user has no permissions" do
              it "raises Pundit::NotAuthorizedError error" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :none, album_genre: :all)
                expect { TestClass.new.create(attributes: {name: "Blue Lines"}) }.to raise_error(Pundit::NotAuthorizedError)
              end
            end

            context "when the current_user does not have create permission" do
              it "raises Pundit::NotAuthorizedError error" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :update, album_genre: :all)
                expect { TestClass.new.create(attributes: {name: "Blue Lines"}) }.to raise_error(Pundit::NotAuthorizedError)
              end
            end

            context "when the current_user has manage permission" do
              it "creates a record and returns true" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :manage, album_genre: :all)
                tc = TestClass.new
                expect(tc.create(attributes: {name: "Blue Lines"})).to be(true)
                expect(tc.object).to be_persisted
              end
            end

            context "when the current_user has create permission" do
              it "creates a record and returns true" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :create, album_genre: :all)
                tc = TestClass.new
                expect(tc.create(attributes: {name: "Blue Lines"})).to be(true)
                expect(tc.object).to be_persisted
              end
            end

            context "when the current_user does not have permission for the genre" do
              it "raises Pundit::NotAuthorizedError error" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :create, album_genre: :rock)
                expect { TestClass.new.create(attributes: {name: "Blue Lines", genre: Album.genres[:electronic]}) }.to raise_error(Pundit::NotAuthorizedError)
              end
            end

            context "when the current_user has permission for all genres" do
              it "creates a record and returns true" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :create, album_genre: :all)
                tc = TestClass.new
                expect(tc.create(attributes: {name: "Blue Lines", genre: Album.genres[:electronic]})).to be(true)
                expect(tc.object).to be_persisted
              end
            end

            context "when the current_user has permission for the genre" do
              it "creates a record and returns true" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :create, album_genre: :electronic)
                tc = TestClass.new
                expect(tc.create(attributes: {name: "Blue Lines", genre: Album.genres[:electronic]})).to be(true)
                expect(tc.object).to be_persisted
              end
            end
          end
        end

        context "when using the cancancan authorization library" do
          before do
            ActiveManageable.configuration.authorization_library = :cancancan
            test_class = Class.new(ActiveManageable::Base) do
              manageable :create, model_class: Album
            end

            stub_const("TestClass", test_class)
          end

          describe "#authorize" do
            context "when the current_user has no permissions" do
              it "raises CanCan::AccessDenied error" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :none, album_genre: :all)
                expect { TestClass.new.create(attributes: {name: "Blue Lines"}) }.to raise_error(CanCan::AccessDenied)
              end
            end

            context "when the current_user does not have create permission" do
              it "raises CanCan::AccessDenied error" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :update, album_genre: :all)
                expect { TestClass.new.create(attributes: {name: "Blue Lines"}) }.to raise_error(CanCan::AccessDenied)
              end
            end

            context "when the current_user has manage permission" do
              it "creates a record and returns true" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :manage, album_genre: :all)
                tc = TestClass.new
                expect(tc.create(attributes: {name: "Blue Lines"})).to be(true)
                expect(tc.object).to be_persisted
              end
            end

            context "when the current_user has create permission" do
              it "creates a record and returns true" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :create, album_genre: :all)
                tc = TestClass.new
                expect(tc.create(attributes: {name: "Blue Lines"})).to be(true)
                expect(tc.object).to be_persisted
              end
            end

            context "when the current_user does not have permission for the genre" do
              it "raises CanCan::AccessDenied error" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :create, album_genre: :rock)
                expect { TestClass.new.create(attributes: {name: "Blue Lines", genre: Album.genres[:electronic]}) }.to raise_error(CanCan::AccessDenied)
              end
            end

            context "when the current_user has permission for all genres" do
              it "creates a record and returns true" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :create, album_genre: :all)
                tc = TestClass.new
                expect(tc.create(attributes: {name: "Blue Lines", genre: Album.genres[:electronic]})).to be(true)
                expect(tc.object).to be_persisted
              end
            end

            context "when the current_user has permission for the genre" do
              it "creates a record and returns true" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :create, album_genre: :electronic)
                tc = TestClass.new
                expect(tc.create(attributes: {name: "Blue Lines", genre: Album.genres[:electronic]})).to be(true)
                expect(tc.object).to be_persisted
              end
            end
          end
        end

        context "when including all methods" do
          before do
            ActiveManageable.configuration.authorization_library = :pundit
            ActiveManageable.configuration.search_library = :ransack
            ActiveManageable.configuration.pagination_library = :kaminari
            test_class = Class.new(ActiveManageable::Base) do
              manageable ActiveManageable::ALL_METHODS, model_class: Album
            end

            stub_const("TestClass", test_class)
          end

          it "creates a record using the :attributes and returns true" do
            ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :create, album_genre: :all)
            tc = TestClass.new
            attributes = {name: "Blue Lines", artist_id: artist.id, genre: "electronic", released_at: Date.new(1991, 6, 1)}
            expect(tc.create(attributes: attributes)).to be(true)
            expect(tc.object).to be_persisted
            expect(tc.object).to have_attributes(attributes)
            expect(Album.find(tc.object.id)).to have_attributes(attributes)
          end

          context "when the :attributes contain string keys and values" do
            it "creates a record using the :attributes and returns true" do
              ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :create, album_genre: :all)
              tc = TestClass.new
              attributes = {"name" => "Blue Lines", "artist_id" => artist.id.to_s, "genre" => "electronic", "released_at" => "1991-06-01"}
              expect(tc.create(attributes: attributes)).to be(true)
              expect(tc.object).to be_persisted
              attributes["artist_id"] = artist.id
              attributes["released_at"] = Date.new(1991, 6, 1)
              expect(tc.object).to have_attributes(attributes)
              expect(Album.find(tc.object.id)).to have_attributes(attributes)
            end
          end
        end

        context "when overriding the instance methods and calling super" do
          before do
            ActiveManageable.configuration.authorization_library = :pundit
            test_class = Class.new(ActiveManageable::Base) do
              manageable ActiveManageable::ALL_METHODS, model_class: Album

              def create(attributes:)
                super
              end

              def authorize(record:, action: nil)
                super
              end
            end

            stub_const("TestClass", test_class)
          end

          it "creates a record using the :attributes and returns true" do
            ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :create, album_genre: :all)
            tc = TestClass.new
            attributes = {name: "Blue Lines", artist_id: artist.id, genre: "electronic", released_at: Date.new(1991, 6, 1)}
            expect(tc.create(attributes: attributes)).to be(true)
            expect(tc.object).to be_persisted
            expect(tc.object).to have_attributes(attributes)
            expect(Album.find(tc.object.id)).to have_attributes(attributes)
          end

          context "when the current_user has no permissions" do
            it "raises Pundit::NotAuthorizedError error" do
              ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :none, album_genre: :all)
              expect { TestClass.new.create(attributes: {name: "Blue Lines"}) }.to raise_error(Pundit::NotAuthorizedError)
            end
          end
        end
      end
    end
  end
end
