# frozen_string_literal: true

require "rails_helper"
require "support/shared_examples/default_includes"
require "support/shared_examples/default_select"

module ActiveManageable
  module Methods
    RSpec.describe Show do
      before do
        ActiveManageable.configuration = ActiveManageable::Configuration.new
      end

      include_examples ".default_includes", :show
      include_examples ".default_select", :show

      describe "#show" do
        let(:artist) { FactoryBot.create(:artist, name: "New Order") }
        let(:album) { FactoryBot.create(:album, :with_songs, song_names: ["5 8 6", "Ecstacy"], name: "Power, Corruption & Lies", artist: artist, genre: Album.genres[:electronic], released_at: "1983-05-02") }
        let(:alternative_genre) { :rock }

        before do
          test_class = Class.new(ActiveManageable::Base) do
            manageable :show, model_class: Album
          end

          stub_const("TestClass", test_class)
        end

        it "sets the :target variable" do
          tc = TestClass.new
          tc.instance_variable_set(:@target, Album.first)
          tc.show(id: album.id)
          expect(tc.target).to be_a(ApplicationRecord)
        end

        it "exposes the :target variable via the #object method" do
          tc = TestClass.new
          tc.show(id: album.id)
          expect(tc.object).to eq(tc.target)
        end

        it "sets the :current_method variable" do
          tc = TestClass.new
          tc.show(id: album.id)
          expect(tc.current_method).to eq(:show)
        end

        it "initializes the :attributes variable to an empty ActiveSupport::HashWithIndifferentAccess" do
          tc = TestClass.new
          tc.instance_variable_set(:@attributes, {name: "test"})
          tc.show(id: album.id)
          expect(tc.attributes).to be_a(ActiveSupport::HashWithIndifferentAccess)
          expect(tc.attributes).to eq({})
        end

        it "sets the :options variable to an ActiveSupport::HashWithIndifferentAccess" do
          tc = TestClass.new
          options = {"includes" => ["songs"]}
          tc.show(id: album.id, options: options)
          expect(tc.options).to be_a(ActiveSupport::HashWithIndifferentAccess)
          expect(tc.options).to eq(options.with_indifferent_access)
          options[:original] = true
          expect(tc.options).not_to be_key(:original)
        end

        context "when a record does not exist for the id argument" do
          it "raises ActiveRecord::RecordNotFound error" do
            expect { TestClass.new.show(id: -1) }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end

        context "when a record exists for the id argument" do
          it "returns an ApplicationRecord" do
            expect(TestClass.new.show(id: album.id)).to be_a(ApplicationRecord)
          end

          it "returns a record" do
            expect(TestClass.new.show(id: album.id)).to eq(Album.find(album.id))
          end
        end

        describe "#includes" do
          context "without a class default includes" do
            context "without :includes option" do
              it "returns a record without eager loaded assocations" do
                object = TestClass.new.show(id: album.id)
                expect(object.songs).not_to be_loaded
                expect(object.association(:artist)).not_to be_loaded
              end
            end

            context "with :includes option" do
              it "returns a record with :includes option eager loaded associations" do
                object = TestClass.new.show(id: album.id, options: {includes: [:songs, :artist]})
                expect(object.songs).to be_loaded
                expect(object.association(:artist)).to be_loaded
              end

              it "returns a record using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.show(id: album.id, options: {includes: [:songs, :artist]})
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "returns a record with :includes option eager loaded associations" do
                object = TestClass.new.show(id: album.id, options: {includes: {associations: [:songs, :artist], loading_method: :preload}})
                expect(object.songs).to be_loaded
                expect(object.association(:artist)).to be_loaded
              end

              it "returns a record using the :includes option :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
                TestClass.new.show(id: album.id, options: {includes: {associations: [:songs, :artist], loading_method: :preload}})
              end
            end
          end

          context "with a class default includes containing associations" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :show, model_class: Album
                default_includes :songs, :artist
              end

              stub_const("TestClass", test_class)
            end

            context "without :includes option" do
              it "returns a record with class default eager loaded assocations" do
                object = TestClass.new.show(id: album.id)
                expect(object.songs).to be_loaded
                expect(object.association(:artist)).to be_loaded
                expect(object.association(:label)).not_to be_loaded
              end

              it "returns a record using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.show(id: album.id)
              end
            end

            context "with :includes option" do
              it "returns a record with :includes option eager loaded associations" do
                object = TestClass.new.show(id: album.id, options: {includes: [:artist, :label]})
                expect(object.songs).not_to be_loaded
                expect(object.association(:artist)).to be_loaded
                expect(object.association(:label)).to be_loaded
              end

              it "returns a record using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.show(id: album.id, options: {includes: :artist})
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "returns a record with :includes option eager loaded associations" do
                object = TestClass.new.show(id: album.id, options: {includes: {associations: [:artist, :label], loading_method: :preload}})
                expect(object.songs).not_to be_loaded
                expect(object.association(:artist)).to be_loaded
                expect(object.association(:label)).to be_loaded
              end

              it "returns a record using the :includes option :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
                TestClass.new.show(id: album.id, options: {includes: {associations: :artist, loading_method: :preload}})
              end
            end
          end

          context "with a class default includes containing associations for the method" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, :show, model_class: Album
                default_includes :label, methods: :index
                default_includes :songs, :artist, methods: :show
              end

              stub_const("TestClass", test_class)
            end

            context "without :includes option" do
              it "returns a record with class default eager loaded assocations" do
                object = TestClass.new.show(id: album.id)
                expect(object.songs).to be_loaded
                expect(object.association(:artist)).to be_loaded
                expect(object.association(:label)).not_to be_loaded
              end

              it "returns a record using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.show(id: album.id)
              end
            end

            context "with :includes option" do
              it "returns a record with :includes option eager loaded associations" do
                object = TestClass.new.show(id: album.id, options: {includes: [:artist, :label]})
                expect(object.songs).not_to be_loaded
                expect(object.association(:artist)).to be_loaded
                expect(object.association(:label)).to be_loaded
              end

              it "returns a record using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.show(id: album.id, options: {includes: :artist})
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "returns a record with :includes option eager loaded associations" do
                object = TestClass.new.show(id: album.id, options: {includes: {associations: [:artist, :label], loading_method: :preload}})
                expect(object.songs).not_to be_loaded
                expect(object.association(:artist)).to be_loaded
                expect(object.association(:label)).to be_loaded
              end

              it "returns a record using the :includes option :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
                TestClass.new.show(id: album.id, options: {includes: {associations: :artist, loading_method: :preload}})
              end
            end
          end

          context "with a class default includes containing associations and :loading_method" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :show, model_class: Album
                default_includes :songs, loading_method: :eager_load
              end

              stub_const("TestClass", test_class)
            end

            context "without :includes option" do
              it "returns a record with class default eager loaded assocations" do
                object = TestClass.new.show(id: album.id)
                expect(object.songs).to be_loaded
                expect(object.association(:artist)).not_to be_loaded
              end

              it "returns a record using the class default :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:eager_load).and_call_original
                TestClass.new.show(id: album.id)
              end
            end

            context "with :includes option" do
              it "returns a record with :includes option eager loaded associations" do
                object = TestClass.new.show(id: album.id, options: {includes: :artist})
                expect(object.songs).not_to be_loaded
                expect(object.association(:artist)).to be_loaded
              end

              it "returns a record using the class default :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:eager_load).and_call_original
                TestClass.new.show(id: album.id, options: {includes: :artist})
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "returns a record with :includes option eager loaded associations" do
                object = TestClass.new.show(id: album.id, options: {includes: {associations: :artist, loading_method: :preload}})
                expect(object.songs).not_to be_loaded
                expect(object.association(:artist)).to be_loaded
              end

              it "returns a record using the :includes option :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
                TestClass.new.show(id: album.id, options: {includes: {associations: :artist, loading_method: :preload}})
              end
            end
          end

          context "with a class default includes containing associations and :loading_method for the method" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, :show, model_class: Album
                default_includes :artist, methods: :index
                default_includes :songs, loading_method: :eager_load, methods: :show
              end

              stub_const("TestClass", test_class)
            end

            context "without :includes option" do
              it "returns a record with class default eager loaded assocations" do
                object = TestClass.new.show(id: album.id)
                expect(object.songs).to be_loaded
                expect(object.association(:artist)).not_to be_loaded
              end

              it "returns a record using the class default :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:eager_load).and_call_original
                TestClass.new.show(id: album.id)
              end
            end

            context "with :includes option" do
              it "returns a record with :includes option eager loaded associations" do
                object = TestClass.new.show(id: album.id, options: {includes: :artist})
                expect(object.songs).not_to be_loaded
                expect(object.association(:artist)).to be_loaded
              end

              it "returns a record using the class default :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:eager_load).and_call_original
                TestClass.new.show(id: album.id, options: {includes: :artist})
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "returns a record with :includes option eager loaded associations" do
                object = TestClass.new.show(id: album.id, options: {includes: {associations: :artist, loading_method: :preload}})
                expect(object.songs).not_to be_loaded
                expect(object.association(:artist)).to be_loaded
              end

              it "returns a record using the :includes option :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
                TestClass.new.show(id: album.id, options: {includes: {associations: :artist, loading_method: :preload}})
              end
            end
          end

          context "with a class default includes containing a lambda that returns an association" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :show, model_class: Album
                default_includes -> { show_includes }

                def show_includes
                  :songs
                end
              end

              stub_const("TestClass", test_class)
            end

            context "without :includes option" do
              it "returns a record with class default eager loaded assocations" do
                object = TestClass.new.show(id: album.id)
                expect(object.songs).to be_loaded
                expect(object.association(:artist)).not_to be_loaded
              end

              it "returns a record using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.show(id: album.id)
              end
            end

            context "with :includes option" do
              it "returns a record with :includes option eager loaded associations" do
                object = TestClass.new.show(id: album.id, options: {includes: :artist})
                expect(object.songs).not_to be_loaded
                expect(object.association(:artist)).to be_loaded
              end

              it "returns a record using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.show(id: album.id, options: {includes: :artist})
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "returns a record with :includes option eager loaded associations" do
                object = TestClass.new.show(id: album.id, options: {includes: {associations: :artist, loading_method: :preload}})
                expect(object.songs).not_to be_loaded
                expect(object.association(:artist)).to be_loaded
              end

              it "returns a record using the :includes option :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
                TestClass.new.show(id: album.id, options: {includes: {associations: :artist, loading_method: :preload}})
              end
            end
          end

          context "with a class default includes containing a proc that returns an association" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :show, model_class: Album
                default_includes proc { show_includes }

                def show_includes
                  :songs
                end
              end

              stub_const("TestClass", test_class)
            end

            context "without :includes option" do
              it "returns a record with class default eager loaded assocations" do
                object = TestClass.new.show(id: album.id)
                expect(object.songs).to be_loaded
                expect(object.association(:artist)).not_to be_loaded
              end

              it "returns a record using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.show(id: album.id)
              end
            end

            context "with :includes option" do
              it "returns a record with :includes option eager loaded associations" do
                object = TestClass.new.show(id: album.id, options: {includes: :artist})
                expect(object.songs).not_to be_loaded
                expect(object.association(:artist)).to be_loaded
              end

              it "returns a record using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.show(id: album.id, options: {includes: :artist})
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "returns a record with :includes option eager loaded associations" do
                object = TestClass.new.show(id: album.id, options: {includes: {associations: :artist, loading_method: :preload}})
                expect(object.songs).not_to be_loaded
                expect(object.association(:artist)).to be_loaded
              end

              it "returns a record using the :includes option :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
                TestClass.new.show(id: album.id, options: {includes: {associations: :artist, loading_method: :preload}})
              end
            end
          end

          context "with a class default includes containing a lambda that returns associations for the method" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, :show, model_class: Album
                default_includes :songs, methods: :index
                default_includes -> { show_includes }, methods: :show

                def show_includes
                  [:songs, :artist]
                end
              end

              stub_const("TestClass", test_class)
            end

            context "without :includes option" do
              it "returns a record with class default eager loaded assocations" do
                object = TestClass.new.show(id: album.id)
                expect(object.songs).to be_loaded
                expect(object.association(:artist)).to be_loaded
              end

              it "returns a record using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.show(id: album.id)
              end
            end

            context "with :includes option" do
              it "returns a record with :includes option eager loaded associations" do
                object = TestClass.new.show(id: album.id, options: {includes: :artist})
                expect(object.songs).not_to be_loaded
                expect(object.association(:artist)).to be_loaded
              end

              it "returns a record using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.show(id: album.id, options: {includes: :artist})
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "returns a record with :includes option eager loaded associations" do
                object = TestClass.new.show(id: album.id, options: {includes: {associations: :artist, loading_method: :preload}})
                expect(object.songs).not_to be_loaded
                expect(object.association(:artist)).to be_loaded
              end

              it "returns a record using the :includes option :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
                TestClass.new.show(id: album.id, options: {includes: {associations: :artist, loading_method: :preload}})
              end
            end
          end

          context "with a class default includes containing a lambda that returns nil" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :show, model_class: Album
                default_includes -> { show_includes }

                def show_includes
                  nil
                end
              end

              stub_const("TestClass", test_class)
            end

            context "without :includes option" do
              it "returns a record without eager loaded assocations" do
                object = TestClass.new.show(id: album.id)
                expect(object.songs).not_to be_loaded
                expect(object.association(:artist)).not_to be_loaded
              end
            end

            context "with :includes option" do
              it "returns a record with :includes option eager loaded associations" do
                object = TestClass.new.show(id: album.id, options: {includes: [:songs, :artist]})
                expect(object.songs).to be_loaded
                expect(object.association(:artist)).to be_loaded
              end

              it "returns a record using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.show(id: album.id, options: {includes: [:songs, :artist]})
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "returns a record with :includes option eager loaded associations" do
                object = TestClass.new.show(id: album.id, options: {includes: {associations: [:songs, :artist], loading_method: :preload}})
                expect(object.songs).to be_loaded
                expect(object.association(:artist)).to be_loaded
              end

              it "returns a record using the :includes option :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
                TestClass.new.show(id: album.id, options: {includes: {associations: [:songs, :artist], loading_method: :preload}})
              end
            end
          end

          context "with a class default includes containing a lambda that returns an empty array" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :show, model_class: Album
                default_includes -> { show_includes }

                def show_includes
                  []
                end
              end

              stub_const("TestClass", test_class)
            end

            context "without :includes option" do
              it "returns a record without eager loaded assocations" do
                object = TestClass.new.show(id: album.id)
                expect(object.songs).not_to be_loaded
                expect(object.association(:artist)).not_to be_loaded
              end
            end

            context "with :includes option" do
              it "returns a record with :includes option eager loaded associations" do
                object = TestClass.new.show(id: album.id, options: {includes: [:songs, :artist]})
                expect(object.songs).to be_loaded
                expect(object.association(:artist)).to be_loaded
              end

              it "returns a record using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.show(id: album.id, options: {includes: [:songs, :artist]})
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "returns a record with :includes option eager loaded associations" do
                object = TestClass.new.show(id: album.id, options: {includes: {associations: [:songs, :artist], loading_method: :preload}})
                expect(object.songs).to be_loaded
                expect(object.association(:artist)).to be_loaded
              end

              it "returns a record using the :includes option :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
                TestClass.new.show(id: album.id, options: {includes: {associations: [:songs, :artist], loading_method: :preload}})
              end
            end
          end
        end

        describe "#select" do
          context "without a class default select" do
            context "without :select option" do
              it "returns a record with all attributes" do
                object = TestClass.new.show(id: album.id)
                expect(object.attributes.keys.sort).to eq(Album.new.attributes.keys.map(&:to_s).sort)
              end
            end

            context "with :select option" do
              it "returns a record with :select option attributes" do
                object = TestClass.new.show(id: album.id, options: {select: [:id, :name]})
                expect(object.attributes.keys.sort).to eq([:id, :name].map(&:to_s).sort)
              end
            end
          end

          context "with a class default select containing attributes" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :show, model_class: Album
                default_select :id, :name, :released_at
              end

              stub_const("TestClass", test_class)
            end

            context "without :select option" do
              it "returns a record with class default select attributes" do
                object = TestClass.new.show(id: album.id)
                expect(object.attributes.keys.sort).to eq([:id, :name, :released_at].map(&:to_s).sort)
              end
            end

            context "with :select option" do
              it "returns a record with :select option attributes" do
                object = TestClass.new.show(id: album.id, options: {select: :id})
                expect(object.attributes.keys.sort).to eq([:id].map(&:to_s).sort)
              end
            end
          end

          context "with a class default select containing attributes for the method" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :show, :edit, model_class: Album
                default_select :id, :name, :genre, methods: :show
                default_select :id, methods: :edit
              end

              stub_const("TestClass", test_class)
            end

            context "without :select option" do
              it "returns a record with class default select attributes" do
                object = TestClass.new.show(id: album.id)
                expect(object.attributes.keys.sort).to eq([:id, :name, :genre].map(&:to_s).sort)
              end
            end

            context "with :select option" do
              it "returns a record with :select option attributes" do
                object = TestClass.new.show(id: album.id, options: {select: [:id, :name, :released_at]})
                expect(object.attributes.keys.sort).to eq([:id, :name, :released_at].map(&:to_s).sort)
              end
            end
          end

          context "with a class default select containing a lambda that returns attributes" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :show, model_class: Album
                default_select -> { show_attributes }

                def show_attributes
                  [:id, :name, :released_at]
                end
              end

              stub_const("TestClass", test_class)
            end

            context "without :select option" do
              it "returns a record with class default select attributes" do
                object = TestClass.new.show(id: album.id)
                expect(object.attributes.keys.sort).to eq([:id, :name, :released_at].map(&:to_s).sort)
              end
            end

            context "with :select option" do
              it "returns a record with :select option attributes" do
                object = TestClass.new.show(id: album.id, options: {select: :id})
                expect(object.attributes.keys.sort).to eq([:id].map(&:to_s).sort)
              end
            end
          end

          context "with a class default select containing a proc that returns attributes" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :show, model_class: Album
                default_select proc { show_attributes }

                def show_attributes
                  [:id, :name, :released_at]
                end
              end

              stub_const("TestClass", test_class)
            end

            context "without :select option" do
              it "returns a record with class default select attributes" do
                object = TestClass.new.show(id: album.id)
                expect(object.attributes.keys.sort).to eq([:id, :name, :released_at].map(&:to_s).sort)
              end
            end

            context "with :select option" do
              it "returns a record with :select option attributes" do
                object = TestClass.new.show(id: album.id, options: {select: :id})
                expect(object.attributes.keys.sort).to eq([:id].map(&:to_s).sort)
              end
            end
          end

          context "with a class default select containing a lambda for the method" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :show, :edit, model_class: Album
                default_select -> { show_select_attributes }, methods: :show
                default_select -> { edit_select_attributes }, methods: :edit

                def show_select_attributes
                  [:id, :name, :genre]
                end

                def edit_select_attributes
                  [:id]
                end
              end

              stub_const("TestClass", test_class)
            end

            context "without :select option" do
              it "returns a record with class default select attributes" do
                object = TestClass.new.show(id: album.id)
                expect(object.attributes.keys.sort).to eq([:id, :name, :genre].map(&:to_s).sort)
              end
            end

            context "with :select option" do
              it "returns a record with :select option attributes" do
                object = TestClass.new.show(id: album.id, options: {select: [:id, :name, :released_at]})
                expect(object.attributes.keys.sort).to eq([:id, :name, :released_at].map(&:to_s).sort)
              end
            end
          end

          context "with a class default select containing a lambda that returns nil" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :show, model_class: Album
                default_select -> { show_attributes }

                def show_attributes
                  nil
                end
              end

              stub_const("TestClass", test_class)
            end

            context "without :select option" do
              it "returns a record with all attributes" do
                object = TestClass.new.show(id: album.id)
                expect(object.attributes.keys.sort).to eq(Album.new.attributes.keys.map(&:to_s).sort)
              end
            end

            context "with :select option" do
              it "returns a record with :select option attributes" do
                object = TestClass.new.show(id: album.id, options: {select: [:id, :name]})
                expect(object.attributes.keys.sort).to eq([:id, :name].map(&:to_s).sort)
              end
            end
          end

          context "with a class default select containing a lambda that returns an empty array" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :show, model_class: Album
                default_select -> { show_attributes }

                def show_attributes
                  []
                end
              end

              stub_const("TestClass", test_class)
            end

            context "without :select option" do
              it "returns a record with all attributes" do
                object = TestClass.new.show(id: album.id)
                expect(object.attributes.keys.sort).to eq(Album.new.attributes.keys.map(&:to_s).sort)
              end
            end

            context "with :select option" do
              it "returns a record with :select option attributes" do
                object = TestClass.new.show(id: album.id, options: {select: [:id, :name]})
                expect(object.attributes.keys.sort).to eq([:id, :name].map(&:to_s).sort)
              end
            end
          end
        end

        context "when using the pundit authorization library" do
          before do
            ActiveManageable.configuration.authorization_library = :pundit
            test_class = Class.new(ActiveManageable::Base) do
              manageable :show, model_class: Album
            end

            stub_const("TestClass", test_class)
          end

          describe "#authorize" do
            context "when the current_user has no permissions" do
              it "raises Pundit::NotAuthorizedError error" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :none, album_genre: :all)
                expect { TestClass.new.show(id: album.id) }.to raise_error(Pundit::NotAuthorizedError)
              end
            end

            context "when the current_user does not have read permission" do
              it "raises Pundit::NotAuthorizedError error" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :create, album_genre: :all)
                expect { TestClass.new.show(id: album.id) }.to raise_error(Pundit::NotAuthorizedError)
              end
            end

            context "when the current_user has read permission" do
              it "returns a record" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :read, album_genre: :all)
                expect(TestClass.new.show(id: album.id)).to eq(Album.find(album.id))
              end
            end

            context "when the current_user has manage permission for all genres" do
              it "returns a record" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :manage, album_genre: :all)
                expect(TestClass.new.show(id: album.id)).to eq(Album.find(album.id))
              end
            end

            context "when the current_user does not have permission for the genre" do
              it "raises Pundit::NotAuthorizedError error" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :read, album_genre: alternative_genre)
                expect { TestClass.new.show(id: album.id) }.to raise_error(Pundit::NotAuthorizedError)
              end
            end

            context "when the current_user has permission for the genre" do
              it "returns a record" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :read, album_genre: album.genre.to_sym)
                expect(TestClass.new.show(id: album.id)).to eq(Album.find(album.id))
              end
            end
          end
        end

        context "when using the cancancan authorization library" do
          before do
            ActiveManageable.configuration.authorization_library = :cancancan
            test_class = Class.new(ActiveManageable::Base) do
              manageable :show, model_class: Album
            end

            stub_const("TestClass", test_class)
          end

          describe "#authorize" do
            context "when the current_user has no permissions" do
              it "raises CanCan::AccessDenied error" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :none, album_genre: :all)
                expect { TestClass.new.show(id: album.id) }.to raise_error(CanCan::AccessDenied)
              end
            end

            context "when the current_user does not have read permission" do
              it "raises CanCan::AccessDenied error" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :create, album_genre: :all)
                expect { TestClass.new.show(id: album.id) }.to raise_error(CanCan::AccessDenied)
              end
            end

            context "when the current_user has read permission" do
              it "returns a record" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :read, album_genre: :all)
                expect(TestClass.new.show(id: album.id)).to eq(Album.find(album.id))
              end
            end

            context "when the current_user has manage permission for all genres" do
              it "returns a record" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :manage, album_genre: :all)
                expect(TestClass.new.show(id: album.id)).to eq(Album.find(album.id))
              end
            end

            context "when the current_user does not have permission for the genre" do
              it "raises CanCan::AccessDenied error" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :read, album_genre: alternative_genre)
                expect { TestClass.new.show(id: album.id) }.to raise_error(CanCan::AccessDenied)
              end
            end

            context "when the current_user has permission for the genre" do
              it "returns a record" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :read, album_genre: album.genre.to_sym)
                expect(TestClass.new.show(id: album.id)).to eq(Album.find(album.id))
              end
            end
          end
        end

        context "when including all methods and using all options" do
          before do
            ActiveManageable.configuration.authorization_library = :pundit
            ActiveManageable.configuration.search_library = :ransack
            ActiveManageable.configuration.pagination_library = :kaminari
            test_class = Class.new(ActiveManageable::Base) do
              manageable ActiveManageable::ALL_METHODS, model_class: Album
            end

            stub_const("TestClass", test_class)
          end

          it "returns a record using a combination of the :includes & :select options" do
            ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :read, album_genre: :all)
            object = TestClass.new.show(id: album.id, options: {includes: :songs, select: [:id, :name, :released_at, :genre]})
            expect(object).to eq(Album.find(album.id))
            expect(object.songs).to be_loaded
            expect(object.attributes.keys.sort).to eq([:id, :name, :released_at, :genre].map(&:to_s).sort)
          end

          context "when the :options contain string keys and values" do
            it "returns a record using a combination of the :includes & :select options" do
              ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :read, album_genre: :all)
              object = TestClass.new.show(id: album.id.to_s, options: {"includes" => "songs", "select" => ["id", "name", "released_at", "genre"]})
              expect(object).to eq(Album.find(album.id))
              expect(object.songs).to be_loaded
              expect(object.attributes.keys.sort).to eq([:id, :name, :released_at, :genre].map(&:to_s).sort)
            end
          end
        end

        context "when overriding the instance methods and calling super" do
          before do
            ActiveManageable.configuration.authorization_library = :pundit
            test_class = Class.new(ActiveManageable::Base) do
              manageable ActiveManageable::ALL_METHODS, model_class: Album

              def show(id:, options: {})
                super
              end

              def includes(opts)
                super
              end

              def select(attributes)
                super
              end

              def authorize(record:, action: nil)
                super
              end
            end

            stub_const("TestClass", test_class)
          end

          it "returns a record using a combination of the :includes & :select options" do
            ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :read, album_genre: :all)
            object = TestClass.new.show(id: album.id, options: {includes: :songs, select: [:id, :name, :released_at, :genre]})
            expect(object).to eq(Album.find(album.id))
            expect(object.songs).to be_loaded
            expect(object.attributes.keys.sort).to eq([:id, :name, :released_at, :genre].map(&:to_s).sort)
          end

          context "when the current_user has no permissions" do
            it "raises Pundit::NotAuthorizedError error" do
              ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :none, album_genre: :all)
              expect { TestClass.new.show(id: album.id) }.to raise_error(Pundit::NotAuthorizedError)
            end
          end
        end

        context "when a block is given" do
          it "yields with no arguments" do
            expect { |b| TestClass.new.show(id: album.id, &b) }.to yield_with_no_args
          end

          it "yields to a block that alters the object attribute" do
            tc = TestClass.new
            expect {
              tc.show(id: album.id) do
                tc.object = tc.object.where(id: 6666)
              end
            }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end
      end
    end
  end
end
