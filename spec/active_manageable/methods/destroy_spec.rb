# frozen_string_literal: true

require "rails_helper"
require "support/shared_examples/default_includes"

module ActiveManageable
  module Methods
    RSpec.describe Destroy do
      before do
        ActiveManageable.configuration = ActiveManageable::Configuration.new
      end

      include_examples ".default_includes", :destroy

      describe "#destroy" do
        let(:label) { FactoryBot.create(:label, name: "Factory Records") }
        let(:artist) { FactoryBot.create(:artist, name: "New Order") }
        let(:album) { FactoryBot.create(:album, :with_songs, song_names: ["5 8 6", "Ecstacy"], name: "Power, Corruption & Lies", label: label, artist: artist, genre: Album.genres[:electronic], released_at: "1983-05-02") }
        let(:cannot_destroy_album) { FactoryBot.create(:album, name: "Movement", label: label, artist: artist, genre: Album.genres[:rock], released_at: "1981-11-13") }
        let(:alternative_genre) { :rock }

        before do
          test_class = Class.new(ActiveManageable::Base) do
            manageable :destroy, model_class: Album
          end

          stub_const("TestClass", test_class)
        end

        it "sets the :target variable" do
          tc = TestClass.new
          tc.instance_variable_set(:@target, Album.first)
          tc.destroy(id: album.id)
          expect(tc.target).to be_a(ApplicationRecord)
        end

        it "exposes the :target variable via the #object method" do
          tc = TestClass.new
          tc.destroy(id: album.id)
          expect(tc.object).to eq(tc.target)
        end

        it "sets the :current_method variable" do
          tc = TestClass.new
          tc.destroy(id: album.id)
          expect(tc.current_method).to eq(:destroy)
        end

        it "initializes the :attributes variable to an empty ActiveSupport::HashWithIndifferentAccess" do
          tc = TestClass.new
          tc.instance_variable_set(:@attributes, {name: "test"})
          tc.destroy(id: album.id)
          expect(tc.attributes).to be_a(ActiveSupport::HashWithIndifferentAccess)
          expect(tc.attributes).to eq({})
        end

        it "sets the :options variable to an ActiveSupport::HashWithIndifferentAccess" do
          tc = TestClass.new
          options = {"includes" => ["songs"]}
          tc.destroy(id: album.id, options: options)
          expect(tc.options).to be_a(ActiveSupport::HashWithIndifferentAccess)
          expect(tc.options).to eq(options.with_indifferent_access)
          options[:original] = true
          expect(tc.options).not_to be_key(:original)
        end

        context "when the destroy of the record succeeds" do
          it "returns an ApplicationRecord" do
            expect(TestClass.new.destroy(id: album.id)).to be_a(ApplicationRecord)
          end

          it "returns the record" do
            expect(TestClass.new.destroy(id: album.id)).to eq(album)
          end

          it "sets the :target variable" do
            tc = TestClass.new
            tc.destroy(id: album.id)
            expect(tc.target).to be_a(Album)
            expect(tc.target).to be_destroyed
          end

          it "deletes the record" do
            tc = TestClass.new
            object = tc.destroy(id: album.id)
            expect(object).to be_destroyed
            expect(tc.object).to be_destroyed
            expect(Album.where(id: album.id)).not_to exist
          end

          it "deletes the record and associated records with dependent :destroy" do
            tc = TestClass.new
            expect(album.songs).to exist
            tc.destroy(id: album.id)
            expect(Album.where(id: album.id)).not_to exist
            expect(Song.where(album_id: album.id)).not_to exist
          end
        end

        context "when the destroy of the record fails" do
          it "returns false" do
            expect(TestClass.new.destroy(id: cannot_destroy_album.id)).to be(false)
          end

          it "sets the :target variable making the errors accessible" do
            tc = TestClass.new
            tc.destroy(id: cannot_destroy_album.id)
            expect(tc.target).to be_a(Album)
            expect(tc.target).not_to be_destroyed
            expect(tc.target.errors[:base][0]).to be_present
          end

          it "does not delete the record" do
            tc = TestClass.new
            expect(tc.destroy(id: cannot_destroy_album.id)).to be(false)
            expect(Album.where(id: album.id)).to exist
          end
        end

        context "when a record does not exist for the id argument" do
          it "raises ActiveRecord::RecordNotFound error" do
            expect { TestClass.new.destroy(id: -1) }.to raise_error(ActiveRecord::RecordNotFound)
          end
        end

        describe "#includes" do
          context "without a class default includes" do
            context "without :includes option" do
              it "retrieves a record without eager loaded assocations" do
                tc = TestClass.new
                tc.destroy(id: album.id)
                expect(tc.object.association(:label)).not_to be_loaded
                expect(tc.object.association(:artist)).not_to be_loaded
              end
            end

            context "with :includes option" do
              it "retrieves a record with :includes option eager loaded associations" do
                tc = TestClass.new
                tc.destroy(id: album.id, options: {includes: [:label, :artist]})
                expect(tc.object.association(:label)).to be_loaded
                expect(tc.object.association(:artist)).to be_loaded
              end

              it "retrieves a record using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.destroy(id: album.id, options: {includes: [:label, :artist]})
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "retrieves a record with :includes option eager loaded associations" do
                tc = TestClass.new
                tc.destroy(id: album.id, options: {includes: {associations: [:label, :artist], loading_method: :preload}})
                expect(tc.object.association(:label)).to be_loaded
                expect(tc.object.association(:artist)).to be_loaded
              end

              it "retrieves a record using the :includes option :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
                TestClass.new.destroy(id: album.id, options: {includes: {associations: [:label, :artist], loading_method: :preload}})
              end
            end
          end

          context "with a class default includes containing associations" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :destroy, model_class: Album
                default_includes :label
              end

              stub_const("TestClass", test_class)
            end

            context "without :includes option" do
              it "retrieves a record with class default eager loaded assocations" do
                tc = TestClass.new
                tc.destroy(id: album.id)
                expect(tc.object.association(:label)).to be_loaded
                expect(tc.object.association(:artist)).not_to be_loaded
              end

              it "retrieves a record using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.destroy(id: album.id)
              end
            end

            context "with :includes option" do
              it "retrieves a record with :includes option eager loaded associations" do
                tc = TestClass.new
                tc.destroy(id: album.id, options: {includes: :artist})
                expect(tc.object.association(:label)).not_to be_loaded
                expect(tc.object.association(:artist)).to be_loaded
              end

              it "retrieves a record using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.destroy(id: album.id, options: {includes: :artist})
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "retrieves a record with :includes option eager loaded associations" do
                tc = TestClass.new
                tc.destroy(id: album.id, options: {includes: {associations: :artist, loading_method: :preload}})
                expect(tc.object.association(:label)).not_to be_loaded
                expect(tc.object.association(:artist)).to be_loaded
              end

              it "retrieves a record using the :includes option :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
                TestClass.new.destroy(id: album.id, options: {includes: {associations: :artist, loading_method: :preload}})
              end
            end
          end

          context "with a class default includes containing associations for the method" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :update, :destroy, model_class: Album
                default_includes :artist, methods: :update
                default_includes :label, methods: :destroy
              end

              stub_const("TestClass", test_class)
            end

            context "without :includes option" do
              it "retrieves a record with class default eager loaded assocations" do
                tc = TestClass.new
                tc.destroy(id: album.id)
                expect(tc.object.association(:label)).to be_loaded
                expect(tc.object.association(:artist)).not_to be_loaded
              end

              it "retrieves a record using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.destroy(id: album.id)
              end
            end

            context "with :includes option" do
              it "retrieves a record with :includes option eager loaded associations" do
                tc = TestClass.new
                tc.destroy(id: album.id, options: {includes: :artist})
                expect(tc.object.association(:label)).not_to be_loaded
                expect(tc.object.association(:artist)).to be_loaded
              end

              it "retrieves a record using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.destroy(id: album.id, options: {includes: :artist})
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "retrieves a record with :includes option eager loaded associations" do
                tc = TestClass.new
                tc.destroy(id: album.id, options: {includes: {associations: :artist, loading_method: :preload}})
                expect(tc.object.association(:label)).not_to be_loaded
                expect(tc.object.association(:artist)).to be_loaded
              end

              it "retrieves a record using the :includes option :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
                TestClass.new.destroy(id: album.id, options: {includes: {associations: :artist, loading_method: :preload}})
              end
            end
          end

          context "with a class default includes containing associations and :loading_method" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :destroy, model_class: Album
                default_includes :label, loading_method: :eager_load
              end

              stub_const("TestClass", test_class)
            end

            context "without :includes option" do
              it "retrieves a record with class default eager loaded assocations" do
                tc = TestClass.new
                tc.destroy(id: album.id)
                expect(tc.object.association(:label)).to be_loaded
                expect(tc.object.association(:artist)).not_to be_loaded
              end

              it "retrieves a record using the class default :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:eager_load).and_call_original
                TestClass.new.destroy(id: album.id)
              end
            end

            context "with :includes option" do
              it "retrieves a record with :includes option eager loaded associations" do
                tc = TestClass.new
                tc.destroy(id: album.id, options: {includes: :artist})
                expect(tc.object.association(:label)).not_to be_loaded
                expect(tc.object.association(:artist)).to be_loaded
              end

              it "retrieves a record using the class default :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:eager_load).and_call_original
                TestClass.new.destroy(id: album.id, options: {includes: :artist})
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "retrieves a record with :includes option eager loaded associations" do
                tc = TestClass.new
                tc.destroy(id: album.id, options: {includes: {associations: :artist, loading_method: :preload}})
                expect(tc.object.association(:label)).not_to be_loaded
                expect(tc.object.association(:artist)).to be_loaded
              end

              it "retrieves a record using the :includes option :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
                TestClass.new.destroy(id: album.id, options: {includes: {associations: :artist, loading_method: :preload}})
              end
            end
          end

          context "with a class default includes containing associations and :loading_method for the method" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :update, :destroy, model_class: Album
                default_includes :artist, methods: :update
                default_includes :label, loading_method: :eager_load, methods: :destroy
              end

              stub_const("TestClass", test_class)
            end

            context "without :includes option" do
              it "retrieves a record with class default eager loaded assocations" do
                tc = TestClass.new
                tc.destroy(id: album.id)
                expect(tc.object.association(:label)).to be_loaded
                expect(tc.object.association(:artist)).not_to be_loaded
              end

              it "retrieves a record using the class default :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:eager_load).and_call_original
                TestClass.new.destroy(id: album.id)
              end
            end

            context "with :includes option" do
              it "retrieves a record with :includes option eager loaded associations" do
                tc = TestClass.new
                tc.destroy(id: album.id, options: {includes: :artist})
                expect(tc.object.association(:label)).not_to be_loaded
                expect(tc.object.association(:artist)).to be_loaded
              end

              it "retrieves a record using the class default :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:eager_load).and_call_original
                TestClass.new.destroy(id: album.id, options: {includes: :artist})
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "retrieves a record with :includes option eager loaded associations" do
                tc = TestClass.new
                tc.destroy(id: album.id, options: {includes: {associations: :artist, loading_method: :preload}})
                expect(tc.object.association(:label)).not_to be_loaded
                expect(tc.object.association(:artist)).to be_loaded
              end

              it "retrieves a record using the :includes option :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
                TestClass.new.destroy(id: album.id, options: {includes: {associations: :artist, loading_method: :preload}})
              end
            end
          end

          context "with a class default includes containing a lambda" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :destroy, model_class: Album
                default_includes -> { destroy_includes }

                def destroy_includes
                  :label
                end
              end

              stub_const("TestClass", test_class)
            end

            context "without :includes option" do
              it "retrieves a record with class default eager loaded assocations" do
                tc = TestClass.new
                tc.destroy(id: album.id)
                expect(tc.object.association(:label)).to be_loaded
                expect(tc.object.association(:artist)).not_to be_loaded
              end

              it "retrieves a record using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.destroy(id: album.id)
              end
            end

            context "with :includes option" do
              it "retrieves a record with :includes option eager loaded associations" do
                tc = TestClass.new
                tc.destroy(id: album.id, options: {includes: :artist})
                expect(tc.object.association(:label)).not_to be_loaded
                expect(tc.object.association(:artist)).to be_loaded
              end

              it "retrieves a record using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.destroy(id: album.id, options: {includes: :artist})
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "retrieves a record with :includes option eager loaded associations" do
                tc = TestClass.new
                tc.destroy(id: album.id, options: {includes: {associations: :artist, loading_method: :preload}})
                expect(tc.object.association(:label)).not_to be_loaded
                expect(tc.object.association(:artist)).to be_loaded
              end

              it "retrieves a record using the :includes option :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
                TestClass.new.destroy(id: album.id, options: {includes: {associations: :artist, loading_method: :preload}})
              end
            end
          end

          context "with a class default includes containing a lambda for the method" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :update, :destroy, model_class: Album
                default_includes :artist, methods: :update
                default_includes -> { destroy_includes }, methods: :destroy

                def destroy_includes
                  :label
                end
              end

              stub_const("TestClass", test_class)
            end

            context "without :includes option" do
              it "retrieves a record with class default eager loaded assocations" do
                tc = TestClass.new
                tc.destroy(id: album.id)
                expect(tc.object.association(:label)).to be_loaded
                expect(tc.object.association(:artist)).not_to be_loaded
              end

              it "retrieves a record using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.destroy(id: album.id)
              end
            end

            context "with :includes option" do
              it "retrieves a record with :includes option eager loaded associations" do
                tc = TestClass.new
                tc.destroy(id: album.id, options: {includes: :artist})
                expect(tc.object.association(:label)).not_to be_loaded
                expect(tc.object.association(:artist)).to be_loaded
              end

              it "retrieves a record using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.destroy(id: album.id, options: {includes: :artist})
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "retrieves a record with :includes option eager loaded associations" do
                tc = TestClass.new
                tc.destroy(id: album.id, options: {includes: {associations: :artist, loading_method: :preload}})
                expect(tc.object.association(:label)).not_to be_loaded
                expect(tc.object.association(:artist)).to be_loaded
              end

              it "retrieves a record using the :includes option :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
                TestClass.new.destroy(id: album.id, options: {includes: {associations: :artist, loading_method: :preload}})
              end
            end
          end

          context "with a class default includes containing a lambda and :loading_method" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :destroy, model_class: Album
                default_includes -> { destroy_includes }, loading_method: :eager_load

                def destroy_includes
                  :label
                end
              end

              stub_const("TestClass", test_class)
            end

            context "without :includes option" do
              it "retrieves a record with class default eager loaded assocations" do
                tc = TestClass.new
                tc.destroy(id: album.id)
                expect(tc.object.association(:label)).to be_loaded
                expect(tc.object.association(:artist)).not_to be_loaded
              end

              it "retrieves a record using the class default :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:eager_load).and_call_original
                TestClass.new.destroy(id: album.id)
              end
            end

            context "with :includes option" do
              it "retrieves a record with :includes option eager loaded associations" do
                tc = TestClass.new
                tc.destroy(id: album.id, options: {includes: :artist})
                expect(tc.object.association(:label)).not_to be_loaded
                expect(tc.object.association(:artist)).to be_loaded
              end

              it "retrieves a record using the class default :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:eager_load).and_call_original
                TestClass.new.destroy(id: album.id, options: {includes: :artist})
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "retrieves a record with :includes option eager loaded associations" do
                tc = TestClass.new
                tc.destroy(id: album.id, options: {includes: {associations: :artist, loading_method: :preload}})
                expect(tc.object.association(:label)).not_to be_loaded
                expect(tc.object.association(:artist)).to be_loaded
              end

              it "retrieves a record using the :includes option :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
                TestClass.new.destroy(id: album.id, options: {includes: {associations: :artist, loading_method: :preload}})
              end
            end
          end

          context "with a class default includes containing a lambda and :loading_method for the method" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :update, :destroy, model_class: Album
                default_includes :artist, methods: :update
                default_includes -> { destroy_includes }, loading_method: :eager_load, methods: :destroy

                def destroy_includes
                  :label
                end
              end

              stub_const("TestClass", test_class)
            end

            context "without :includes option" do
              it "retrieves a record with class default eager loaded assocations" do
                tc = TestClass.new
                tc.destroy(id: album.id)
                expect(tc.object.association(:label)).to be_loaded
                expect(tc.object.association(:artist)).not_to be_loaded
              end

              it "retrieves a record using the class default :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:eager_load).and_call_original
                TestClass.new.destroy(id: album.id)
              end
            end

            context "with :includes option" do
              it "retrieves a record with :includes option eager loaded associations" do
                tc = TestClass.new
                tc.destroy(id: album.id, options: {includes: :artist})
                expect(tc.object.association(:label)).not_to be_loaded
                expect(tc.object.association(:artist)).to be_loaded
              end

              it "retrieves a record using the class default :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:eager_load).and_call_original
                TestClass.new.destroy(id: album.id, options: {includes: :artist})
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "retrieves a record with :includes option eager loaded associations" do
                tc = TestClass.new
                tc.destroy(id: album.id, options: {includes: {associations: :artist, loading_method: :preload}})
                expect(tc.object.association(:label)).not_to be_loaded
                expect(tc.object.association(:artist)).to be_loaded
              end

              it "retrieves a record using the :includes option :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
                TestClass.new.destroy(id: album.id, options: {includes: {associations: :artist, loading_method: :preload}})
              end
            end
          end
        end

        context "when using the pundit authorization library" do
          before do
            ActiveManageable.configuration.authorization_library = :pundit
            test_class = Class.new(ActiveManageable::Base) do
              manageable :destroy, model_class: Album
            end

            stub_const("TestClass", test_class)
          end

          describe "#authorize" do
            context "when the current_user has no permissions" do
              it "raises Pundit::NotAuthorizedError error" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :none, album_genre: :all)
                expect { TestClass.new.destroy(id: album.id) }.to raise_error(Pundit::NotAuthorizedError)
              end
            end

            context "when the current_user does not have destroy permission" do
              it "raises Pundit::NotAuthorizedError error" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :create, album_genre: :all)
                expect { TestClass.new.destroy(id: album.id) }.to raise_error(Pundit::NotAuthorizedError)
              end
            end

            context "when the current_user has destroy permission" do
              it "returns the record" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :destroy, album_genre: :all)
                expect(TestClass.new.destroy(id: album.id)).to eq(album)
              end
            end

            context "when the current_user has manage permission for all genres" do
              it "returns the record" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :manage, album_genre: :all)
                expect(TestClass.new.destroy(id: album.id)).to eq(album)
              end
            end

            context "when the current_user does not have permission for the genre" do
              it "raises Pundit::NotAuthorizedError error" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :destroy, album_genre: alternative_genre)
                expect { TestClass.new.destroy(id: album.id) }.to raise_error(Pundit::NotAuthorizedError)
              end
            end

            context "when the current_user has permission for the genre" do
              it "returns the record" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :destroy, album_genre: album.genre.to_sym)
                expect(TestClass.new.destroy(id: album.id)).to eq(album)
              end
            end
          end
        end

        context "when using the cancancan authorization library" do
          before do
            ActiveManageable.configuration.authorization_library = :cancancan
            test_class = Class.new(ActiveManageable::Base) do
              manageable :destroy, model_class: Album
            end

            stub_const("TestClass", test_class)
          end

          describe "#authorize" do
            context "when the current_user has no permissions" do
              it "raises CanCan::AccessDenied error" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :none, album_genre: :all)
                expect { TestClass.new.destroy(id: album.id) }.to raise_error(CanCan::AccessDenied)
              end
            end

            context "when the current_user does not have destroy permission" do
              it "raises CanCan::AccessDenied error" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :create, album_genre: :all)
                expect { TestClass.new.destroy(id: album.id) }.to raise_error(CanCan::AccessDenied)
              end
            end

            context "when the current_user has destroy permission" do
              it "returns the record" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :destroy, album_genre: :all)
                expect(TestClass.new.destroy(id: album.id)).to eq(album)
              end
            end

            context "when the current_user has manage permission for all genres" do
              it "returns the record" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :manage, album_genre: :all)
                expect(TestClass.new.destroy(id: album.id)).to eq(album)
              end
            end

            context "when the current_user does not have permission for the genre" do
              it "raises CanCan::AccessDenied error" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :destroy, album_genre: alternative_genre)
                expect { TestClass.new.destroy(id: album.id) }.to raise_error(CanCan::AccessDenied)
              end
            end

            context "when the current_user has permission for the genre" do
              it "returns the record" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :destroy, album_genre: album.genre.to_sym)
                expect(TestClass.new.destroy(id: album.id)).to eq(album)
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

          it "deletes a record using the :includes option and returns the record" do
            ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :destroy, album_genre: :all)
            tc = TestClass.new
            object = tc.destroy(id: album.id, options: {includes: [:label, :artist]})
            expect(object).to eq(album)
            expect(object).to be_destroyed
            expect(tc.object).to eq(album)
            expect(tc.object).to be_destroyed
            expect(Album.where(id: album.id)).not_to exist
            expect(tc.object.association(:label)).to be_loaded
            expect(tc.object.association(:artist)).to be_loaded
          end

          context "when the :id and :options contain string keys and values" do
            it "deletes a record using the :includes option and returns the record" do
              ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :destroy, album_genre: :all)
              tc = TestClass.new
              object = tc.destroy(id: album.id.to_s, options: {"includes" => ["label", "artist"]})
              expect(object).to eq(album)
              expect(object).to be_destroyed
              expect(tc.object).to eq(album)
              expect(tc.object).to be_destroyed
              expect(Album.where(id: album.id)).not_to exist
              expect(tc.object.association(:label)).to be_loaded
              expect(tc.object.association(:artist)).to be_loaded
            end
          end
        end

        context "when overriding the instance methods and calling super" do
          before do
            ActiveManageable.configuration.authorization_library = :pundit
            test_class = Class.new(ActiveManageable::Base) do
              manageable ActiveManageable::ALL_METHODS, model_class: Album

              def destroy(id:, options: {})
                super
              end

              def includes(opts)
                super
              end

              def authorize(record:, action: nil)
                super
              end
            end

            stub_const("TestClass", test_class)
          end

          it "deletes a record using the :includes option and returns the record" do
            ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :destroy, album_genre: :all)
            tc = TestClass.new
            object = tc.destroy(id: album.id, options: {includes: [:label, :artist]})
            expect(object).to eq(album)
            expect(object).to be_destroyed
            expect(tc.object).to eq(album)
            expect(tc.object).to be_destroyed
            expect(Album.where(id: album.id)).not_to exist
            expect(tc.object.association(:label)).to be_loaded
            expect(tc.object.association(:artist)).to be_loaded
          end

          context "when the current_user has no permissions" do
            it "raises Pundit::NotAuthorizedError error" do
              ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :none, album_genre: :all)
              expect { TestClass.new.destroy(id: album.id) }.to raise_error(Pundit::NotAuthorizedError)
            end
          end
        end

        context "when a block is given" do
          it "yields with no arguments" do
            expect { |b| TestClass.new.destroy(id: album.id, &b) }.to yield_with_no_args
          end

          it "yields to a block that alters the object attribute" do
            tc = TestClass.new
            result = tc.destroy(id: album.id) do
              tc.object.name = "Blue Lines"
            end
            expect(result).to be_a(Album)
            expect(tc.object.name).to eq("Blue Lines")
          end
        end
      end
    end
  end
end
