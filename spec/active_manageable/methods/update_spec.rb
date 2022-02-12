# frozen_string_literal: true

require "rails_helper"
require "support/shared_examples/default_includes"
require "support/shared_examples/normalize_attributes"

module ActiveManageable
  module Methods
    RSpec.describe Update do
      before do
        ActiveManageable.configuration = ActiveManageable::Configuration.new
      end

      include_examples ".default_includes", :update

      describe "#update" do
        let(:artist) { FactoryBot.create(:artist, name: "New Order") }
        let(:album) { FactoryBot.create(:album, :with_songs, song_names: ["5 8 6", "Ecstacy"], name: "Power, Corruption & Lies", artist: artist, genre: Album.genres[:electronic], released_at: "1983-05-02") }
        let(:alternative_genre) { :rock }

        before do
          test_class = Class.new(ActiveManageable::Base) do
            manageable :update, model_class: Album
          end

          stub_const("TestClass", test_class)
        end

        it "sets the :target variable" do
          tc = TestClass.new
          tc.instance_variable_set(:@target, Album.first)
          tc.update(id: album.id, attributes: {name: "Power Corruption and Lies"})
          expect(tc.target).to be_a(ApplicationRecord)
        end

        it "exposes the :target variable via the #object method" do
          tc = TestClass.new
          tc.update(id: album.id, attributes: {name: "Power Corruption and Lies"})
          expect(tc.object).to eq(tc.target)
        end

        it "sets the :current_method variable" do
          tc = TestClass.new
          tc.update(id: album.id, attributes: {name: "Power Corruption and Lies"})
          expect(tc.current_method).to eq(:update)
        end

        context "when the attributes argument is a Hash" do
          it "sets the :attributes variable to an ActiveSupport::HashWithIndifferentAccess" do
            tc = TestClass.new
            attributes = {name: "Power Corruption and Lies", released_at: "1983-05-02"}
            tc.update(id: album.id, attributes: attributes)
            expect(tc.attributes).to be_a(ActiveSupport::HashWithIndifferentAccess)
            expect(tc.attributes).to eq({name: "Power Corruption and Lies", released_at: Date.parse("1983-05-02")}.with_indifferent_access)
            expect(tc.attributes.object_id).not_to eq(attributes.object_id)
            attributes[:original] = true
            expect(tc.attributes).not_to be_key(:original)
          end
        end

        context "when the attributes argument is an ActiveSupport::HashWithIndifferentAccess" do
          it "sets the :attributes variable to a duplicate ActiveSupport::HashWithIndifferentAccess" do
            tc = TestClass.new
            attributes = {name: "Power Corruption and Lies", released_at: "1983-05-02"}.with_indifferent_access
            tc.update(id: album.id, attributes: attributes)
            expect(tc.attributes).to be_a(ActiveSupport::HashWithIndifferentAccess)
            expect(tc.attributes).to eq({name: "Power Corruption and Lies", released_at: Date.parse("1983-05-02")}.with_indifferent_access)
            expect(tc.attributes.object_id).not_to eq(attributes.object_id)
            attributes[:original] = true
            expect(tc.attributes).not_to be_key(:original)
          end
        end

        context "when the attributes argument is an ActionController::Parameters" do
          it "sets the :attributes variable to an ActiveSupport::HashWithIndifferentAccess" do
            tc = TestClass.new
            attributes = ActionController::Parameters.new(name: "Power Corruption and Lies", released_at: "1983-05-02").permit(:name, :released_at)
            tc.update(id: album.id, attributes: attributes)
            expect(tc.attributes).to be_a(ActiveSupport::HashWithIndifferentAccess)
            expect(tc.attributes).to eq({name: "Power Corruption and Lies", released_at: Date.parse("1983-05-02")}.with_indifferent_access)
            expect(tc.attributes.object_id).not_to eq(attributes.object_id)
            attributes[:original] = true
            expect(tc.attributes).not_to be_key(:original)
          end

          it "sets the :attributes variable including only permitted parameters" do
            tc = TestClass.new
            attributes = ActionController::Parameters.new(name: "Blue Lines", genre: Album.genres[:electronic], artist_attributes: {name: "Massive Attack", published_at: "2022-02-22"}).permit(:name, artist_attributes: [:name])
            tc.update(id: album.id, attributes: attributes)
            expect(tc.attributes).to be_a(ActiveSupport::HashWithIndifferentAccess)
            expect(tc.attributes).to eq({name: "Blue Lines", artist_attributes: {name: "Massive Attack"}}.with_indifferent_access)
          end

          it "sets the :attributes variable including a permitted nested parameters ActionController::Parameters" do
            tc = TestClass.new
            # build params so that the artist_attributes value is an ActionController::Parameters
            attributes = ActionController::Parameters.new(name: "Blue Lines", artist_attributes: {name: "Massive Attack"}).permit(:name, artist_attributes: [:name])
            tc.update(id: album.id, attributes: attributes)
            expect(tc.attributes).to be_a(ActiveSupport::HashWithIndifferentAccess)
            expect(tc.attributes).to eq({name: "Blue Lines", artist_attributes: {name: "Massive Attack"}}.with_indifferent_access)
          end

          it "sets the :attributes variable including a permitted nested parameters hash" do
            tc = TestClass.new
            # build params & permit then update the artist_attributes value to a Hash
            # to ensure that the method does not result in an ActiveModel::ForbiddenAttributesError
            attributes = ActionController::Parameters.new(name: "Blue Lines", artist_attributes: {name: "Massive Attack"}).permit(:name, artist_attributes: [:name])
            attributes[:artist_attributes] = {name: "Massive Attack"}
            tc.update(id: album.id, attributes: attributes)
            expect(tc.attributes).to be_a(ActiveSupport::HashWithIndifferentAccess)
            expect(tc.attributes).to eq({name: "Blue Lines", artist_attributes: {name: "Massive Attack"}}.with_indifferent_access)
          end
        end

        context "when the attributes argument is not a Hash or ActionController::Parameters" do
          it "raises an error when assigning attributes" do
            expect { TestClass.new.update(id: album.id, attributes: "boom!") }.to raise_error(ArgumentError)
          end
        end

        it "sets the :options variable to an ActiveSupport::HashWithIndifferentAccess" do
          tc = TestClass.new
          options = {"includes" => ["songs"]}
          tc.update(id: album.id, attributes: {name: "Power Corruption and Lies"}, options: options)
          expect(tc.options).to be_a(ActiveSupport::HashWithIndifferentAccess)
          expect(tc.options).to eq(options.with_indifferent_access)
          options[:original] = true
          expect(tc.options).not_to be_key(:original)
        end

        include_examples "#normalize_attributes", :update

        context "when the update of the record succeeds" do
          it "returns true" do
            expect(TestClass.new.update(id: album.id, attributes: {name: "Power Corruption and Lies"})).to be(true)
          end

          it "sets the :target variable" do
            tc = TestClass.new
            tc.update(id: album.id, attributes: {name: "Power Corruption and Lies"})
            expect(tc.target).to be_a(Album)
            expect(tc.target.saved_changes).to be_present
          end

          it "updates record attributes" do
            tc = TestClass.new
            og_attributes = album.attributes
            attributes = {name: "Power Corruption and Lies", genre: "pop", released_at: Date.new(1983, 5, 1)}
            expect(tc.update(id: album.id, attributes: attributes)).to be(true)
            expect(tc.object.saved_change_to_attribute(:name)).to eq([og_attributes["name"], attributes[:name]])
            expect(tc.object.saved_change_to_attribute(:genre)).to eq([og_attributes["genre"], attributes[:genre]])
            expect(tc.object.saved_change_to_attribute(:released_at)).to eq([og_attributes["released_at"], attributes[:released_at]])
            expect(tc.object.saved_change_to_attribute?(:updated_at)).to be(true)
            expect(tc.object).to have_attributes(attributes)
            expect(Album.find(album.id)).to have_attributes(attributes)
          end
        end

        context "when the update of the record fails" do
          it "returns false" do
            expect(TestClass.new.update(id: album.id, attributes: {name: ""})).to be(false)
          end

          it "sets the :target variable making the errors accessible" do
            tc = TestClass.new
            tc.update(id: album.id, attributes: {name: ""})
            expect(tc.target).to be_a(Album)
            expect(tc.target.saved_changes).to be_empty
            expect(tc.target.errors[:name][0]).to eq(I18n.t("errors.messages.blank"))
          end

          it "does not update record attributes" do
            tc = TestClass.new
            og_attributes = album.attributes
            attributes = {name: ""}
            expect(tc.update(id: album.id, attributes: attributes)).to be(false)
            expect(tc.object.saved_change_to_attribute?(:name)).to be(false)
            expect(tc.object.saved_change_to_attribute?(:updated_at)).to be(false)
            expect(tc.object).to have_attributes(attributes)
            expect(Album.find(album.id)).to have_attributes(og_attributes)
          end
        end

        context "when a record does not exist for the id argument" do
          it "raises ActiveRecord::RecordNotFound error" do
            expect { TestClass.new.update(id: -1, attributes: {name: "Power Corruption and Lies"}) }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end

        context "with an attributes hash of symbol keys and data type values" do
          it "updates a record and associated records" do
            tc = TestClass.new
            attributes = {id: album.id, name: "Blue Lines", released_at: Date.new(1991, 4, 8), length: BigDecimal("45.04"), published_at: Time.zone.now.change(sec: 0), artist_attributes: {id: album.artist.id, name: "Massive Attack", published_at: Time.zone.now.change(sec: 0)}, songs_attributes: [{id: album.songs[0].id, name: "Safe From Harm", length: Float("5.18"), published_at: Time.zone.now.change(sec: 0)}, {id: album.songs[1].id, name: "Unfinished Sympathy", length: Float("5.08"), published_at: Time.zone.now.change(sec: 0)}]}
            expect(tc.update(id: album.id, attributes: attributes)).to be(true)
            expect(tc.object).to be_persisted
            expect(tc.object).to have_attributes(attributes.slice(:id, :name, :released_at, :length, :published_at))
            expect(tc.object.artist.id).to eq(album.artist.id)
            check_belongs_to(tc.object, :artist, attributes[:artist_attributes])
            expect(tc.object.songs.map(&:id)).to eq(album.songs.map(&:id))
            check_has_many(tc.object, :songs, 2, attributes[:songs_attributes])
          end

          it "updates a record and both creates, updates & destroys associated records" do
            tc = TestClass.new
            attributes = {"id" => album.id.to_s, "name" => "Blue Lines", "published_at" => "2022-01-26 14:21", "artist_attributes" => {"name" => "Massive Attack", "published_at" => "2022-01-26 14:21"}, "songs_attributes" => [{"id" => album.songs[0].id.to_s, "name" => "Safe From Harm", "published_at" => "2022-01-26 14:21"}, {"id" => album.songs[1].id.to_s, "_destroy" => "1"}, {"name" => "Unfinished Sympathy", "published_at" => "2022-01-26 14:21"}]}
            expect(tc.update(id: album.id, attributes: attributes)).to be(true)
            # album
            attributes = attributes.with_indifferent_access
            attributes[:id] = attributes[:id].to_i
            attributes[:published_at] = Time.zone.parse(attributes[:published_at])
            expect(tc.object).to be_persisted
            expect(tc.object).to have_attributes(attributes.slice(:id, :name, :released_at, :length, :published_at))
            # artist
            attributes[:artist_attributes][:published_at] = Time.zone.parse(attributes[:artist_attributes][:published_at])
            expect(tc.object.artist.id).not_to eq(album.artist.id)
            check_belongs_to(tc.object, :artist, attributes[:artist_attributes])
            # songs
            songs_attributes = [attributes[:songs_attributes][0], attributes[:songs_attributes][2]]
            songs_attributes.each_with_index do |attrs, i|
              attrs[:id] = attrs[:id].to_i if attrs.key?(:id)
              attrs[:published_at] = Time.zone.parse(attrs[:published_at])
            end
            check_has_many(tc.object, :songs, 2, songs_attributes)
          end
        end

        context "with an attributes hash of string keys and values" do
          it "updates a record and associated records" do
            tc = TestClass.new
            attributes = {"name" => "Blue Lines", "released_at" => "1991-04-08", "length" => "45.04", "published_at" => "2022-01-26 14:21", "artist_attributes" => {"id" => album.artist.id.to_s, "name" => "Massive Attack", "published_at" => "2022-01-26 14:21"}, "songs_attributes" => [{"id" => album.songs[0].id.to_s, "name" => "Safe From Harm", "length" => "5.18", "published_at" => "2022-01-26 14:21"}, {"id" => album.songs[1].id.to_s, "name" => "Unfinished Sympathy", "length" => "5.08", "published_at" => "2022-01-26 14:21"}]}
            expect(tc.update(id: album.id, attributes: attributes)).to be(true)
            # album
            attributes = attributes.with_indifferent_access
            attributes[:released_at] = Date.parse(attributes[:released_at])
            attributes[:length] = BigDecimal(attributes[:length])
            attributes[:published_at] = Time.zone.parse(attributes[:published_at])
            expect(tc.object.id).to eq(album.id)
            expect(tc.object).to have_attributes(attributes.slice(:name, :released_at, :length, :published_at))
            # artist
            attributes[:artist_attributes][:id] = attributes[:artist_attributes][:id].to_i
            attributes[:artist_attributes][:published_at] = Time.zone.parse(attributes[:artist_attributes][:published_at])
            check_belongs_to(tc.object, :artist, attributes[:artist_attributes])
            # songs
            attributes[:songs_attributes].each_with_index do |attrs, i|
              attrs[:id] = attrs[:id].to_i
              attrs[:length] = Float(attrs[:length])
              attrs[:published_at] = Time.zone.parse(attrs[:published_at])
            end
            check_has_many(tc.object, :songs, 2, attributes[:songs_attributes])
          end
        end

        context "with an attributes hash containing date, datetime, decimal and float values that need to be normalized" do
          it "updates a record and associated records" do
            tc = TestClass.new
            attributes = {"name" => "Blue Lines", "released_at" => "8-4-91", "length" => "45,04", "published_at" => "26.1.22 14.21", "artist_attributes" => {"id" => album.artist.id.to_s, "name" => "Massive Attack", "published_at" => "26.1.22 14.21"}, "songs_attributes" => [{"id" => album.songs[0].id.to_s, "name" => "Safe From Harm", "length" => "5,18", "published_at" => "26.1.22 14.21"}, {"id" => album.songs[1].id.to_s, "name" => "Unfinished Sympathy", "length" => "5,08", "published_at" => "26.1.22 14.21"}]}
            I18n.with_locale(:nl) do
              expect(tc.update(id: album.id, attributes: attributes)).to be(true)
            end
            # album
            attributes = attributes.with_indifferent_access
            attributes[:released_at] = Date.parse("1991-04-08")
            attributes[:length] = BigDecimal(attributes[:length].tr(",", "."))
            attributes[:published_at] = Time.zone.parse("2022-01-26 14:21")
            expect(tc.object.id).to eq(album.id)
            expect(tc.object).to have_attributes(attributes.slice(:name, :released_at, :length, :published_at))
            # artist
            attributes[:artist_attributes][:id] = attributes[:artist_attributes][:id].to_i
            attributes[:artist_attributes][:published_at] = Time.zone.parse("2022-01-26 14:21")
            check_belongs_to(tc.object, :artist, attributes[:artist_attributes])
            # songs
            attributes[:songs_attributes].each_with_index do |attrs, i|
              attrs[:id] = attrs[:id].to_i
              attrs[:length] = Float(attrs[:length].tr(",", "."))
              attrs[:published_at] = Time.zone.parse("2022-01-26 14:21")
            end
            check_has_many(tc.object, :songs, 2, attributes[:songs_attributes])
          end
        end

        context "with an attributes params containing date, datetime, decimal and float values that need to be normalized" do
          it "updates a record and associated records" do
            tc = TestClass.new
            attributes = ActionController::Parameters.new(name: "Blue Lines", released_at: "8-4-91", length: "45,04", published_at: "26.1.22 14.21", artist_attributes: {id: album.artist.id.to_s, name: "Massive Attack", published_at: "26.1.22 14.21"}, songs_attributes: [{id: album.songs[0].id.to_s, name: "Safe From Harm", length: "5,18", published_at: "26.1.22 14.21"}, {id: album.songs[1].id.to_s, name: "Unfinished Sympathy", length: "5,08", published_at: "26.1.22 14.21"}]).permit(:name, :released_at, :length, :published_at, artist_attributes: [:id, :name, :published_at], songs_attributes: [:id, :name, :length, :published_at])
            I18n.with_locale(:nl) do
              expect(tc.update(id: album.id, attributes: attributes)).to be(true)
            end
            # album
            attributes[:released_at] = Date.parse("1991-04-08")
            attributes[:length] = BigDecimal(attributes[:length].tr(",", "."))
            attributes[:published_at] = Time.zone.parse("2022-01-26 14:21")
            expect(tc.object.id).to eq(album.id)
            expect(tc.object).to have_attributes(attributes.slice(:name, :released_at, :length, :published_at).to_h)
            # artist
            attributes[:artist_attributes][:id] = attributes[:artist_attributes][:id].to_i
            attributes[:artist_attributes][:published_at] = Time.zone.parse("2022-01-26 14:21")
            check_belongs_to(tc.object, :artist, attributes[:artist_attributes].to_h)
            # songs
            attributes[:songs_attributes].each_with_index do |attrs, i|
              attrs[:id] = attrs[:id].to_i
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

        describe "#includes" do
          context "without a class default includes" do
            context "without :includes option" do
              it "retrieves a record without eager loaded assocations" do
                tc = TestClass.new
                tc.update(id: album.id, attributes: {name: "Power Corruption and Lies"})
                expect(tc.object.songs).not_to be_loaded
                expect(tc.object.association(:artist)).not_to be_loaded
              end
            end

            context "with :includes option" do
              it "retrieves a record with :includes option eager loaded associations" do
                tc = TestClass.new
                tc.update(id: album.id, attributes: {name: "Power Corruption and Lies"}, options: {includes: [:songs, :artist]})
                expect(tc.object.songs).to be_loaded
                expect(tc.object.association(:artist)).to be_loaded
              end

              it "retrieves a record using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.update(id: album.id, attributes: {name: "Power Corruption and Lies"}, options: {includes: [:songs, :artist]})
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "retrieves a record with :includes option eager loaded associations" do
                tc = TestClass.new
                tc.update(id: album.id, attributes: {name: "Power Corruption and Lies"}, options: {includes: {associations: [:songs, :artist], loading_method: :preload}})
                expect(tc.object.songs).to be_loaded
                expect(tc.object.association(:artist)).to be_loaded
              end

              it "retrieves a record using the :includes option :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
                TestClass.new.update(id: album.id, attributes: {name: "Power Corruption and Lies"}, options: {includes: {associations: [:songs, :artist], loading_method: :preload}})
              end
            end
          end

          context "with a class default includes containing associations" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :update, model_class: Album
                default_includes :songs, :artist
              end

              stub_const("TestClass", test_class)
            end

            context "without :includes option" do
              it "retrieves a record with class default eager loaded assocations" do
                tc = TestClass.new
                tc.update(id: album.id, attributes: {name: "Power Corruption and Lies"})
                expect(tc.object.songs).to be_loaded
                expect(tc.object.association(:artist)).to be_loaded
                expect(tc.object.association(:label)).not_to be_loaded
              end

              it "retrieves a record using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.update(id: album.id, attributes: {name: "Power Corruption and Lies"})
              end
            end

            context "with :includes option" do
              it "retrieves a record with :includes option eager loaded associations" do
                tc = TestClass.new
                tc.update(id: album.id, attributes: {name: "Power Corruption and Lies"}, options: {includes: [:artist, :label]})
                expect(tc.object.songs).not_to be_loaded
                expect(tc.object.association(:artist)).to be_loaded
                expect(tc.object.association(:label)).to be_loaded
              end

              it "retrieves a record using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.update(id: album.id, attributes: {name: "Power Corruption and Lies"}, options: {includes: :artist})
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "retrieves a record with :includes option eager loaded associations" do
                tc = TestClass.new
                tc.update(id: album.id, attributes: {name: "Power Corruption and Lies"}, options: {includes: {associations: [:artist, :label], loading_method: :preload}})
                expect(tc.object.songs).not_to be_loaded
                expect(tc.object.association(:artist)).to be_loaded
                expect(tc.object.association(:label)).to be_loaded
              end

              it "retrieves a record using the :includes option :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
                TestClass.new.update(id: album.id, attributes: {name: "Power Corruption and Lies"}, options: {includes: {associations: :artist, loading_method: :preload}})
              end
            end
          end

          context "with a class default includes containing associations for the method" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, :update, model_class: Album
                default_includes :label, methods: :index
                default_includes :songs, :artist, methods: :update
              end

              stub_const("TestClass", test_class)
            end

            context "without :includes option" do
              it "retrieves a record with class default eager loaded assocations" do
                tc = TestClass.new
                tc.update(id: album.id, attributes: {name: "Power Corruption and Lies"})
                expect(tc.object.songs).to be_loaded
                expect(tc.object.association(:artist)).to be_loaded
                expect(tc.object.association(:label)).not_to be_loaded
              end

              it "retrieves a record using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.update(id: album.id, attributes: {name: "Power Corruption and Lies"})
              end
            end

            context "with :includes option" do
              it "retrieves a record with :includes option eager loaded associations" do
                tc = TestClass.new
                tc.update(id: album.id, attributes: {name: "Power Corruption and Lies"}, options: {includes: [:artist, :label]})
                expect(tc.object.songs).not_to be_loaded
                expect(tc.object.association(:artist)).to be_loaded
                expect(tc.object.association(:label)).to be_loaded
              end

              it "retrieves a record using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.update(id: album.id, attributes: {name: "Power Corruption and Lies"}, options: {includes: :artist})
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "retrieves a record with :includes option eager loaded associations" do
                tc = TestClass.new
                tc.update(id: album.id, attributes: {name: "Power Corruption and Lies"}, options: {includes: {associations: [:artist, :label], loading_method: :preload}})
                expect(tc.object.songs).not_to be_loaded
                expect(tc.object.association(:artist)).to be_loaded
                expect(tc.object.association(:label)).to be_loaded
              end

              it "retrieves a record using the :includes option :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
                TestClass.new.update(id: album.id, attributes: {name: "Power Corruption and Lies"}, options: {includes: {associations: :artist, loading_method: :preload}})
              end
            end
          end

          context "with a class default includes containing associations and :loading_method" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :update, model_class: Album
                default_includes :songs, loading_method: :eager_load
              end

              stub_const("TestClass", test_class)
            end

            context "without :includes option" do
              it "retrieves a record with class default eager loaded assocations" do
                tc = TestClass.new
                tc.update(id: album.id, attributes: {name: "Power Corruption and Lies"})
                expect(tc.object.songs).to be_loaded
                expect(tc.object.association(:artist)).not_to be_loaded
              end

              it "retrieves a record using the class default :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:eager_load).and_call_original
                TestClass.new.update(id: album.id, attributes: {name: "Power Corruption and Lies"})
              end
            end

            context "with :includes option" do
              it "retrieves a record with :includes option eager loaded associations" do
                tc = TestClass.new
                tc.update(id: album.id, attributes: {name: "Power Corruption and Lies"}, options: {includes: :artist})
                expect(tc.object.songs).not_to be_loaded
                expect(tc.object.association(:artist)).to be_loaded
              end

              it "retrieves a record using the class default :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:eager_load).and_call_original
                TestClass.new.update(id: album.id, attributes: {name: "Power Corruption and Lies"}, options: {includes: :artist})
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "retrieves a record with :includes option eager loaded associations" do
                tc = TestClass.new
                tc.update(id: album.id, attributes: {name: "Power Corruption and Lies"}, options: {includes: {associations: :artist, loading_method: :preload}})
                expect(tc.object.songs).not_to be_loaded
                expect(tc.object.association(:artist)).to be_loaded
              end

              it "retrieves a record using the :includes option :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
                TestClass.new.update(id: album.id, attributes: {name: "Power Corruption and Lies"}, options: {includes: {associations: :artist, loading_method: :preload}})
              end
            end
          end

          context "with a class default includes containing associations and :loading_method for the method" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, :update, model_class: Album
                default_includes :artist, methods: :index
                default_includes :songs, loading_method: :eager_load, methods: :update
              end

              stub_const("TestClass", test_class)
            end

            context "without :includes option" do
              it "retrieves a record with class default eager loaded assocations" do
                tc = TestClass.new
                tc.update(id: album.id, attributes: {name: "Power Corruption and Lies"})
                expect(tc.object.songs).to be_loaded
                expect(tc.object.association(:artist)).not_to be_loaded
              end

              it "retrieves a record using the class default :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:eager_load).and_call_original
                TestClass.new.update(id: album.id, attributes: {name: "Power Corruption and Lies"})
              end
            end

            context "with :includes option" do
              it "retrieves a record with :includes option eager loaded associations" do
                tc = TestClass.new
                tc.update(id: album.id, attributes: {name: "Power Corruption and Lies"}, options: {includes: :artist})
                expect(tc.object.songs).not_to be_loaded
                expect(tc.object.association(:artist)).to be_loaded
              end

              it "retrieves a record using the class default :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:eager_load).and_call_original
                TestClass.new.update(id: album.id, attributes: {name: "Power Corruption and Lies"}, options: {includes: :artist})
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "retrieves a record with :includes option eager loaded associations" do
                tc = TestClass.new
                tc.update(id: album.id, attributes: {name: "Power Corruption and Lies"}, options: {includes: {associations: :artist, loading_method: :preload}})
                expect(tc.object.songs).not_to be_loaded
                expect(tc.object.association(:artist)).to be_loaded
              end

              it "retrieves a record using the :includes option :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
                TestClass.new.update(id: album.id, attributes: {name: "Power Corruption and Lies"}, options: {includes: {associations: :artist, loading_method: :preload}})
              end
            end
          end

          context "with a class default includes containing a lambda that returns an association" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :update, model_class: Album
                default_includes -> { update_includes }

                def update_includes
                  :songs
                end
              end

              stub_const("TestClass", test_class)
            end

            context "without :includes option" do
              it "retrieves a record with class default eager loaded assocations" do
                tc = TestClass.new
                tc.update(id: album.id, attributes: {name: "Power Corruption and Lies"})
                expect(tc.object.songs).to be_loaded
                expect(tc.object.association(:artist)).not_to be_loaded
              end

              it "retrieves a record using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.update(id: album.id, attributes: {name: "Power Corruption and Lies"})
              end
            end

            context "with :includes option" do
              it "retrieves a record with :includes option eager loaded associations" do
                tc = TestClass.new
                tc.update(id: album.id, attributes: {name: "Power Corruption and Lies"}, options: {includes: :artist})
                expect(tc.object.songs).not_to be_loaded
                expect(tc.object.association(:artist)).to be_loaded
              end

              it "retrieves a record using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.update(id: album.id, attributes: {name: "Power Corruption and Lies"}, options: {includes: :artist})
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "retrieves a record with :includes option eager loaded associations" do
                tc = TestClass.new
                tc.update(id: album.id, attributes: {name: "Power Corruption and Lies"}, options: {includes: {associations: :artist, loading_method: :preload}})
                expect(tc.object.songs).not_to be_loaded
                expect(tc.object.association(:artist)).to be_loaded
              end

              it "retrieves a record using the :includes option :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
                TestClass.new.update(id: album.id, attributes: {name: "Power Corruption and Lies"}, options: {includes: {associations: :artist, loading_method: :preload}})
              end
            end
          end

          context "with a class default includes containing a proc that returns an association" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :update, model_class: Album
                default_includes proc { update_includes }

                def update_includes
                  :songs
                end
              end

              stub_const("TestClass", test_class)
            end

            context "without :includes option" do
              it "retrieves a record with class default eager loaded assocations" do
                tc = TestClass.new
                tc.update(id: album.id, attributes: {name: "Power Corruption and Lies"})
                expect(tc.object.songs).to be_loaded
                expect(tc.object.association(:artist)).not_to be_loaded
              end

              it "retrieves a record using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.update(id: album.id, attributes: {name: "Power Corruption and Lies"})
              end
            end

            context "with :includes option" do
              it "retrieves a record with :includes option eager loaded associations" do
                tc = TestClass.new
                tc.update(id: album.id, attributes: {name: "Power Corruption and Lies"}, options: {includes: :artist})
                expect(tc.object.songs).not_to be_loaded
                expect(tc.object.association(:artist)).to be_loaded
              end

              it "retrieves a record using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.update(id: album.id, attributes: {name: "Power Corruption and Lies"}, options: {includes: :artist})
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "retrieves a record with :includes option eager loaded associations" do
                tc = TestClass.new
                tc.update(id: album.id, attributes: {name: "Power Corruption and Lies"}, options: {includes: {associations: :artist, loading_method: :preload}})
                expect(tc.object.songs).not_to be_loaded
                expect(tc.object.association(:artist)).to be_loaded
              end

              it "retrieves a record using the :includes option :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
                TestClass.new.update(id: album.id, attributes: {name: "Power Corruption and Lies"}, options: {includes: {associations: :artist, loading_method: :preload}})
              end
            end
          end

          context "with a class default includes containing a lambda that returns associations for the method" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, :update, model_class: Album
                default_includes :songs, methods: :index
                default_includes -> { update_includes }, methods: :update

                def update_includes
                  [:songs, :artist]
                end
              end

              stub_const("TestClass", test_class)
            end

            context "without :includes option" do
              it "retrieves a record with class default eager loaded assocations" do
                tc = TestClass.new
                tc.update(id: album.id, attributes: {name: "Power Corruption and Lies"})
                expect(tc.object.songs).to be_loaded
                expect(tc.object.association(:artist)).to be_loaded
              end

              it "retrieves a record using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.update(id: album.id, attributes: {name: "Power Corruption and Lies"})
              end
            end

            context "with :includes option" do
              it "retrieves a record with :includes option eager loaded associations" do
                tc = TestClass.new
                tc.update(id: album.id, attributes: {name: "Power Corruption and Lies"}, options: {includes: :artist})
                expect(tc.object.songs).not_to be_loaded
                expect(tc.object.association(:artist)).to be_loaded
              end

              it "retrieves a record using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.update(id: album.id, attributes: {name: "Power Corruption and Lies"}, options: {includes: :artist})
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "retrieves a record with :includes option eager loaded associations" do
                tc = TestClass.new
                tc.update(id: album.id, attributes: {name: "Power Corruption and Lies"}, options: {includes: {associations: :artist, loading_method: :preload}})
                expect(tc.object.songs).not_to be_loaded
                expect(tc.object.association(:artist)).to be_loaded
              end

              it "retrieves a record using the :includes option :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
                TestClass.new.update(id: album.id, attributes: {name: "Power Corruption and Lies"}, options: {includes: {associations: :artist, loading_method: :preload}})
              end
            end
          end

          context "with a class default includes containing a lambda that returns nil" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :update, model_class: Album
                default_includes -> { update_includes }

                def update_includes
                  nil
                end
              end

              stub_const("TestClass", test_class)
            end

            context "without :includes option" do
              it "retrieves a record without eager loaded assocations" do
                tc = TestClass.new
                tc.update(id: album.id, attributes: {name: "Power Corruption and Lies"})
                expect(tc.object.songs).not_to be_loaded
                expect(tc.object.association(:artist)).not_to be_loaded
              end
            end

            context "with :includes option" do
              it "retrieves a record with :includes option eager loaded associations" do
                tc = TestClass.new
                tc.update(id: album.id, attributes: {name: "Power Corruption and Lies"}, options: {includes: [:songs, :artist]})
                expect(tc.object.songs).to be_loaded
                expect(tc.object.association(:artist)).to be_loaded
              end

              it "retrieves a record using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.update(id: album.id, attributes: {name: "Power Corruption and Lies"}, options: {includes: [:songs, :artist]})
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "retrieves a record with :includes option eager loaded associations" do
                tc = TestClass.new
                tc.update(id: album.id, attributes: {name: "Power Corruption and Lies"}, options: {includes: {associations: [:songs, :artist], loading_method: :preload}})
                expect(tc.object.songs).to be_loaded
                expect(tc.object.association(:artist)).to be_loaded
              end

              it "retrieves a record using the :includes option :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
                TestClass.new.update(id: album.id, attributes: {name: "Power Corruption and Lies"}, options: {includes: {associations: [:songs, :artist], loading_method: :preload}})
              end
            end
          end

          context "with a class default includes containing a lambda that returns an empty array" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :update, model_class: Album
                default_includes -> { update_includes }

                def update_includes
                  []
                end
              end

              stub_const("TestClass", test_class)
            end

            context "without :includes option" do
              it "retrieves a record without eager loaded assocations" do
                tc = TestClass.new
                tc.update(id: album.id, attributes: {name: "Power Corruption and Lies"})
                expect(tc.object.songs).not_to be_loaded
                expect(tc.object.association(:artist)).not_to be_loaded
              end
            end

            context "with :includes option" do
              it "retrieves a record with :includes option eager loaded associations" do
                tc = TestClass.new
                tc.update(id: album.id, attributes: {name: "Power Corruption and Lies"}, options: {includes: [:songs, :artist]})
                expect(tc.object.songs).to be_loaded
                expect(tc.object.association(:artist)).to be_loaded
              end

              it "retrieves a record using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.update(id: album.id, attributes: {name: "Power Corruption and Lies"}, options: {includes: [:songs, :artist]})
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "retrieves a record with :includes option eager loaded associations" do
                tc = TestClass.new
                tc.update(id: album.id, attributes: {name: "Power Corruption and Lies"}, options: {includes: {associations: [:songs, :artist], loading_method: :preload}})
                expect(tc.object.songs).to be_loaded
                expect(tc.object.association(:artist)).to be_loaded
              end

              it "retrieves a record using the :includes option :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
                TestClass.new.update(id: album.id, attributes: {name: "Power Corruption and Lies"}, options: {includes: {associations: [:songs, :artist], loading_method: :preload}})
              end
            end
          end
        end

        context "when using the pundit authorization library" do
          before do
            ActiveManageable.configuration.authorization_library = :pundit
            test_class = Class.new(ActiveManageable::Base) do
              manageable :update, model_class: Album
            end

            stub_const("TestClass", test_class)
          end

          describe "#authorize" do
            context "when the current_user has no permissions" do
              it "raises Pundit::NotAuthorizedError error" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :none, album_genre: :all)
                expect { TestClass.new.update(id: album.id, attributes: {name: "Power Corruption and Lies"}) }.to raise_error(Pundit::NotAuthorizedError)
              end
            end

            context "when the current_user does not have update permission" do
              it "raises Pundit::NotAuthorizedError error" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :create, album_genre: :all)
                expect { TestClass.new.update(id: album.id, attributes: {name: "Power Corruption and Lies"}) }.to raise_error(Pundit::NotAuthorizedError)
              end
            end

            context "when the current_user has update permission" do
              it "returns a record" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :update, album_genre: :all)
                expect(TestClass.new.update(id: album.id, attributes: {name: "Power Corruption and Lies"})).to be(true)
              end
            end

            context "when the current_user has manage permission for all genres" do
              it "returns a record" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :manage, album_genre: :all)
                expect(TestClass.new.update(id: album.id, attributes: {name: "Power Corruption and Lies"})).to be(true)
              end
            end

            context "when the current_user does not have permission for the genre" do
              it "raises Pundit::NotAuthorizedError error" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :update, album_genre: alternative_genre)
                expect { TestClass.new.update(id: album.id, attributes: {name: "Power Corruption and Lies"}) }.to raise_error(Pundit::NotAuthorizedError)
              end
            end

            context "when the current_user has permission for the genre" do
              it "returns a record" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :update, album_genre: album.genre.to_sym)
                expect(TestClass.new.update(id: album.id, attributes: {name: "Power Corruption and Lies"})).to be(true)
              end
            end
          end
        end

        context "when using the cancancan authorization library" do
          before do
            ActiveManageable.configuration.authorization_library = :cancancan
            test_class = Class.new(ActiveManageable::Base) do
              manageable :update, model_class: Album
            end

            stub_const("TestClass", test_class)
          end

          describe "#authorize" do
            context "when the current_user has no permissions" do
              it "raises CanCan::AccessDenied error" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :none, album_genre: :all)
                expect { TestClass.new.update(id: album.id, attributes: {name: "Power Corruption and Lies"}) }.to raise_error(CanCan::AccessDenied)
              end
            end

            context "when the current_user does not have update permission" do
              it "raises CanCan::AccessDenied error" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :create, album_genre: :all)
                expect { TestClass.new.update(id: album.id, attributes: {name: "Power Corruption and Lies"}) }.to raise_error(CanCan::AccessDenied)
              end
            end

            context "when the current_user has update permission" do
              it "returns a record" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :update, album_genre: :all)
                expect(TestClass.new.update(id: album.id, attributes: {name: "Power Corruption and Lies"})).to be(true)
              end
            end

            context "when the current_user has manage permission for all genres" do
              it "returns a record" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :manage, album_genre: :all)
                expect(TestClass.new.update(id: album.id, attributes: {name: "Power Corruption and Lies"})).to be(true)
              end
            end

            context "when the current_user does not have permission for the genre" do
              it "raises CanCan::AccessDenied error" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :update, album_genre: alternative_genre)
                expect { TestClass.new.update(id: album.id, attributes: {name: "Power Corruption and Lies"}) }.to raise_error(CanCan::AccessDenied)
              end
            end

            context "when the current_user has permission for the genre" do
              it "returns a record" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :update, album_genre: album.genre.to_sym)
                expect(TestClass.new.update(id: album.id, attributes: {name: "Power Corruption and Lies"})).to be(true)
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

          it "updates a record using the :attributes & :includes option and returns true" do
            ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :update, album_genre: :all)
            tc = TestClass.new
            artist = FactoryBot.create(:artist, name: "New Order")
            attributes = {name: "Power Corruption and Lies", artist_id: artist.id, genre: "pop", released_at: Date.new(1983, 5, 1)}
            expect(tc.update(id: album.id, attributes: attributes, options: {includes: :songs})).to be(true)
            expect(tc.object).to have_attributes(attributes)
            expect(Album.find(album.id)).to have_attributes(attributes)
            expect(tc.object.songs).to be_loaded
          end

          context "when the :id and :attributes contain string keys and values" do
            it "updates a record using the :attributes & :includes option and returns true" do
              ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :update, album_genre: :all)
              tc = TestClass.new
              artist = FactoryBot.create(:artist, name: "New Order")
              attributes = {"name" => "Power Corruption and Lies", "artist_id" => artist.id.to_s, "genre" => "pop", "released_at" => "1983-05-01"}
              expect(tc.update(id: album.id.to_s, attributes: attributes, options: {"includes" => "songs"})).to be(true)
              attributes["artist_id"] = artist.id
              attributes["released_at"] = Date.new(1983, 5, 1)
              expect(tc.object).to have_attributes(attributes)
              expect(Album.find(album.id)).to have_attributes(attributes)
              expect(tc.object.songs).to be_loaded
            end
          end
        end
      end
    end
  end
end
