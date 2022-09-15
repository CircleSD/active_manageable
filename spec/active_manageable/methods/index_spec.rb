# frozen_string_literal: true

require "rails_helper"
require "support/shared_examples/default_includes"
require "support/shared_examples/default_select"

module ActiveManageable
  module Methods
    RSpec.describe Index do
      before do
        ActiveManageable.configuration = ActiveManageable::Configuration.new
      end

      include_examples "default_includes", :index
      include_examples "default_select", :index

      describe ".unique_search" do
        before do
          test_class = Class.new(ActiveManageable::Base) do
            manageable :index
          end

          stub_const("TestClass", test_class)
        end

        it "has a default of nil" do
          expect(TestClass.unique_search).to be_nil
        end
      end

      describe ".has_unique_search" do
        before do
          test_class = Class.new(ActiveManageable::Base) do
            manageable :index
          end

          stub_const("TestClass", test_class)
        end

        context "when called without an argument" do
          it "sets the unique_search attribute to true" do
            TestClass.has_unique_search
            expect(TestClass.unique_search).to be(true)
          end
        end

        context "when called with an :if key" do
          it "sets the unique_search attribute to the argument" do
            TestClass.has_unique_search if: :blah
            expect(TestClass.unique_search).to eq({if: :blah})
          end
        end

        context "when called with an :unless key" do
          it "sets the unique_search attribute to the argument" do
            TestClass.has_unique_search unless: :blah
            expect(TestClass.unique_search).to eq({unless: :blah})
          end
        end

        context "when called with a key other than :if or :unless" do
          it "raises an error" do
            expect { TestClass.has_unique_search on: :blah }.to raise_error(ArgumentError)
          end
        end

        context "when called with a lambda value" do
          it "sets the unique_search attribute to the argument" do
            lambda = -> { true }
            TestClass.has_unique_search if: lambda
            expect(TestClass.unique_search).to eq({if: lambda})
          end
        end

        context "when called with a proc value" do
          it "sets the unique_search attribute to the argument" do
            prc = proc { true }
            TestClass.has_unique_search if: prc
            expect(TestClass.unique_search).to eq({if: prc})
          end
        end
      end

      describe "#unique_search?" do
        context "without calling the has_unique_search method" do
          before do
            test_class = Class.new(ActiveManageable::Base) do
              manageable :index
            end

            stub_const("TestClass", test_class)
          end

          it "returns the default value of false" do
            tc = TestClass.new
            expect(tc.unique_search?).to be(false)
          end
        end

        context "when calling the has_unique_search method" do
          before do
            test_class = Class.new(ActiveManageable::Base) do
              manageable :index
              has_unique_search
            end

            stub_const("TestClass", test_class)
          end

          it "returns true" do
            tc = TestClass.new
            expect(tc.unique_search?).to be(true)
          end
        end

        context "when calling the has_unique_search method with an :if condition and method symbol" do
          before do
            test_class = Class.new(ActiveManageable::Base) do
              manageable :index
              has_unique_search if: :test
              attr_accessor :test
            end

            stub_const("TestClass", test_class)
          end

          it "returns false when the method returns false" do
            tc = TestClass.new
            tc.test = false
            expect(tc.unique_search?).to be(false)
          end

          it "returns true when the method returns true" do
            tc = TestClass.new
            tc.test = true
            expect(tc.unique_search?).to be(true)
          end
        end

        context "when calling the has_unique_search method with an :unless condition and method symbol" do
          before do
            test_class = Class.new(ActiveManageable::Base) do
              manageable :index
              has_unique_search unless: :test
              attr_accessor :test
            end

            stub_const("TestClass", test_class)
          end

          it "returns false when the method returns true" do
            tc = TestClass.new
            tc.test = true
            expect(tc.unique_search?).to be(false)
          end

          it "returns true when the method returns false" do
            tc = TestClass.new
            tc.test = false
            expect(tc.unique_search?).to be(true)
          end
        end

        context "when calling the has_unique_search method with an :if condition and lambda" do
          before do
            test_class = Class.new(ActiveManageable::Base) do
              manageable :index
              has_unique_search if: -> { test }
              attr_accessor :test
            end

            stub_const("TestClass", test_class)
          end

          it "returns false when the lambda returns false" do
            tc = TestClass.new
            tc.test = false
            expect(tc.unique_search?).to be(false)
          end

          it "returns true when the lambda returns true" do
            tc = TestClass.new
            tc.test = true
            expect(tc.unique_search?).to be(true)
          end
        end

        context "when calling the has_unique_search method with an :unless condition and lambda" do
          before do
            test_class = Class.new(ActiveManageable::Base) do
              manageable :index
              has_unique_search unless: -> { test }
              attr_accessor :test
            end

            stub_const("TestClass", test_class)
          end

          it "returns false when the lambda returns true" do
            tc = TestClass.new
            tc.test = true
            expect(tc.unique_search?).to be(false)
          end

          it "returns true when the lambda returns false" do
            tc = TestClass.new
            tc.test = false
            expect(tc.unique_search?).to be(true)
          end
        end

        context "when calling the has_unique_search method with an :if condition and proc" do
          before do
            test_class = Class.new(ActiveManageable::Base) do
              manageable :index
              has_unique_search if: proc { test }
              attr_accessor :test
            end

            stub_const("TestClass", test_class)
          end

          it "returns false when the proc returns false" do
            tc = TestClass.new
            tc.test = false
            expect(tc.unique_search?).to be(false)
          end

          it "returns true when the proc returns true" do
            tc = TestClass.new
            tc.test = true
            expect(tc.unique_search?).to be(true)
          end
        end

        context "when calling the has_unique_search method with an :unless condition and proc" do
          before do
            test_class = Class.new(ActiveManageable::Base) do
              manageable :index
              has_unique_search unless: proc { test }
              attr_accessor :test
            end

            stub_const("TestClass", test_class)
          end

          it "returns false when the proc returns true" do
            tc = TestClass.new
            tc.test = true
            expect(tc.unique_search?).to be(false)
          end

          it "returns true when the proc returns false" do
            tc = TestClass.new
            tc.test = false
            expect(tc.unique_search?).to be(true)
          end
        end
      end

      describe ".default_order" do
        before do
          test_class = Class.new(ActiveManageable::Base) do
            manageable :index
          end

          stub_const("TestClass", test_class)
        end

        context "when called with a single attribute" do
          it "sets the defaults attribute :order value" do
            TestClass.default_order :name
            expect(TestClass.defaults[:order]).to eq([:name])
          end
        end

        context "when called with a string argument" do
          it "sets the defaults attribute :order value" do
            TestClass.default_order "name DESC"
            expect(TestClass.defaults[:order]).to eq(["name DESC"])
          end
        end

        context "when called with a lambda argument" do
          it "sets the defaults attribute :order value" do
            lambda = -> { order_by }
            TestClass.default_order lambda
            expect(TestClass.defaults[:order]).to eq(lambda)
          end
        end

        context "when called with a proc argument" do
          it "sets the defaults attribute :order value" do
            prc = proc { order_by }
            TestClass.default_order prc
            expect(TestClass.defaults[:order]).to eq(prc)
          end
        end
      end

      describe "#default_order" do
        before do
          test_class = Class.new(ActiveManageable::Base) do
            manageable :index

            def order_by
              [:id, :name, "created_at DESC"]
            end
          end

          stub_const("TestClass", test_class)
        end

        context "when the default order has not been set" do
          it "returns nil" do
            tc = TestClass.new
            expect(tc.default_order).to be_nil
          end
        end

        context "when the default order is set to a symbol attribute" do
          it "returns an array containing the symbol attribute" do
            TestClass.default_order :name
            tc = TestClass.new
            expect(tc.default_order).to eq([:name])
          end
        end

        context "when the default order is set to a string attribute" do
          it "returns an array containing the string attribute" do
            TestClass.default_order "name DESC"
            tc = TestClass.new
            expect(tc.default_order).to eq(["name DESC"])
          end
        end

        context "when the default order is set to a proc" do
          it "returns the output of the block" do
            prc = proc { order_by }
            TestClass.default_order prc
            tc = TestClass.new
            expect(tc.default_order).to eq([:id, :name, "created_at DESC"])
          end
        end
      end

      describe ".default_scopes" do
        before do
          test_class = Class.new(ActiveManageable::Base) do
            manageable :index
          end

          stub_const("TestClass", test_class)
        end

        context "when called with a single scope" do
          it "sets the defaults attribute :scopes value" do
            TestClass.default_scopes :electronic
            expect(TestClass.defaults[:scopes]).to eq([:electronic])
          end
        end

        context "when called with multiple scopes" do
          it "sets the defaults attribute :scopes value" do
            TestClass.default_scopes :electronic, {released_in_year: "1980"}
            expect(TestClass.defaults[:scopes]).to eq([:electronic, {released_in_year: "1980"}])
          end
        end

        context "when called with a lambda" do
          it "sets the defaults attribute :scopes value" do
            lambda = -> { index_scopes }
            TestClass.default_scopes lambda
            expect(TestClass.defaults[:scopes]).to eq(lambda)
          end
        end

        context "when called with a proc" do
          it "sets the defaults attribute :scopes value" do
            prc = proc { index_scopes }
            TestClass.default_scopes prc
            expect(TestClass.defaults[:scopes]).to eq(prc)
          end
        end
      end

      describe "#default_scopes" do
        before do
          test_class = Class.new(ActiveManageable::Base) do
            manageable :index

            def index_scopes
              [:rock, {released_in_year: 1969}]
            end
          end

          stub_const("TestClass", test_class)
        end

        context "when the default scopes has not been set" do
          it "returns an empty hash" do
            tc = TestClass.new
            expect(tc.default_scopes).to eq({})
          end
        end

        context "when the default scopes is set to a scope name" do
          it "returns a hash with a key of the scope name and value of an empty array" do
            TestClass.default_scopes :electronic
            tc = TestClass.new
            expect(tc.default_scopes).to eq({electronic: []})
          end
        end

        context "when the default scopes is set to scope name and argument" do
          it "returns a hash with a key of the scope name and value of an array containing the scope argument" do
            TestClass.default_scopes released_in_year: "1980"
            tc = TestClass.new
            expect(tc.default_scopes).to eq({released_in_year: ["1980"]})
          end
        end

        context "when the default scopes is set to a proc" do
          it "returns the output of the block converted to a hash with scope name keys and array of arguments values" do
            prc = proc { index_scopes }
            TestClass.default_scopes prc
            tc = TestClass.new
            expect(tc.default_scopes).to eq({rock: [], released_in_year: [1969]})
          end
        end
      end

      describe "#index" do
        before do
          test_class = Class.new(ActiveManageable::Base) do
            manageable :index, model_class: Album
          end

          stub_const("TestClass", test_class)

          artist = FactoryBot.create(:artist, name: "New Order")
          album = FactoryBot.create(:album, name: "Power, Corruption & Lies", artist: artist, genre: Album.genres[:electronic], released_at: "1983-05-02")
          FactoryBot.create(:song, name: "5 8 6", album: album, artist: artist)
          FactoryBot.create(:song, name: "Ecstacy", album: album, artist: artist)
          FactoryBot.create(:album, name: "Low-Life", artist: artist, genre: Album.genres[:electronic], released_at: "1985-05-13")
          FactoryBot.create(:album, name: "Brotherhood", artist: artist, genre: Album.genres[:electronic], released_at: "1986-09-29")
          FactoryBot.create(:album, name: "Substance", artist: artist, genre: Album.genres[:electronic], released_at: "1987-08-17")
          FactoryBot.create(:album, name: "Technique", artist: artist, genre: Album.genres[:electronic], released_at: "1988-01-30")
          FactoryBot.create(:album, name: "Republic", artist: artist, genre: Album.genres[:electronic], released_at: "1993-05-03")
          artist = FactoryBot.create(:artist, name: "Led Zeppelin")
          FactoryBot.create(:album, name: "Led Zeppelin", artist: artist, genre: Album.genres[:rock], released_at: "1969-01-12")
          FactoryBot.create(:album, name: "Led Zeppelin II", artist: artist, genre: Album.genres[:rock], released_at: "1969-10-22")
          FactoryBot.create(:album, name: "Led Zeppelin III", artist: artist, genre: Album.genres[:rock], released_at: "1970-10-05")
          FactoryBot.create(:album, name: "Led Zeppelin IV", artist: artist, genre: Album.genres[:rock], released_at: "1971-11-08")
          artist = FactoryBot.create(:artist, name: "Depeche Mode")
          FactoryBot.create(:album, name: "Black Celebration", artist: artist, genre: Album.genres[:electronic], released_at: "1986-03-17")
          FactoryBot.create(:album, name: "Music for the Masses", artist: artist, genre: Album.genres[:electronic], released_at: "1987-09-28")
          FactoryBot.create(:album, name: "Violator", artist: artist, genre: Album.genres[:electronic], released_at: "1990-03-19")
          FactoryBot.create(:album, name: "Songs of Faith and Devotion", artist: artist, genre: Album.genres[:electronic], released_at: "1993-05-03")
        end

        it "sets the :target variable" do
          tc = TestClass.new
          tc.index
          expect(tc.target).to be_a(ActiveRecord::Relation)
        end

        it "exposes the :collection variable via the #object method" do
          tc = TestClass.new
          tc.index
          expect(tc.collection).to eq(tc.target)
        end

        it "sets the :current_method variable" do
          tc = TestClass.new
          tc.index
          expect(tc.current_method).to eq(:index)
        end

        it "initializes the :attributes variable to an empty ActiveSupport::HashWithIndifferentAccess" do
          tc = TestClass.new
          tc.instance_variable_set(:@attributes, {name: "test"})
          tc.index
          expect(tc.attributes).to be_a(ActiveSupport::HashWithIndifferentAccess)
          expect(tc.attributes).to eq({})
        end

        it "sets the :options variable to an ActiveSupport::HashWithIndifferentAccess" do
          tc = TestClass.new
          options = {"includes" => ["songs"], "order" => "created_at"}
          tc.index(options: options)
          expect(tc.options).to be_a(ActiveSupport::HashWithIndifferentAccess)
          expect(tc.options).to eq(options.with_indifferent_access)
          options[:original] = true
          expect(tc.options).not_to be_key(:original)
        end

        context "when records do not exist" do
          it "returns an empty ActiveRecord::Relation" do
            collection = TestClass.new.index(options: {scopes: [:electronic, :rock]})
            expect(collection).to be_a(ActiveRecord::Relation)
            expect(collection).to be_empty
          end
        end

        context "when records exist" do
          it "returns an ActiveRecord::Relation" do
            expect(TestClass.new.index).to be_a(ActiveRecord::Relation)
          end

          it "returns all records" do
            expect(TestClass.new.index).to match_array(Album.all)
          end
        end

        describe "#order" do
          context "without a class default order" do
            context "without :order option" do
              it "returns records in database order" do
                expect(TestClass.new.index.map(&:id)).to eq(Album.ids)
              end
            end

            context "with :order option" do
              it "returns records ordered by :order option" do
                albums = Album.all.sort_by(&:name)
                expect(TestClass.new.index(options: {order: :name}).map(&:id)).to eq(albums.map(&:id))
              end
            end
          end

          context "with a class default order containing an attribute" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, model_class: Album
                default_order "name DESC"
              end

              stub_const("TestClass", test_class)
            end

            context "without :order option" do
              it "returns records ordered by class default order" do
                albums = Album.all.sort_by(&:name).reverse
                expect(TestClass.new.index.map(&:id)).to eq(albums.map(&:id))
              end
            end

            context "with :order option" do
              it "returns records ordered by :order option" do
                albums = Album.all.sort_by(&:name)
                expect(TestClass.new.index(options: {order: :name}).map(&:id)).to eq(albums.map(&:id))
              end
            end
          end

          context "with a class default order containing a lambda returning an attribute" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, model_class: Album
                default_order -> { default_order_attributes }

                def default_order_attributes
                  "name DESC"
                end
              end

              stub_const("TestClass", test_class)
            end

            context "without :order option" do
              it "returns records ordered by class default order" do
                albums = Album.all.sort_by(&:name).reverse
                expect(TestClass.new.index.map(&:id)).to eq(albums.map(&:id))
              end
            end

            context "with :order option" do
              it "returns records ordered by :order option" do
                albums = Album.all.sort_by(&:name)
                expect(TestClass.new.index(options: {order: :name}).map(&:id)).to eq(albums.map(&:id))
              end
            end
          end

          context "with a class default order containing a proc returning an array of attributes" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, model_class: Album
                default_order proc { default_order_attributes }

                def default_order_attributes
                  [:released_at, :name]
                end
              end

              stub_const("TestClass", test_class)
            end

            context "without :order option" do
              it "returns records ordered by class default order" do
                albums = Album.all.sort_by { |a| [a.released_at, a.name] }
                expect(TestClass.new.index.map(&:id)).to eq(albums.map(&:id))
              end
            end

            context "with :order option" do
              it "returns records ordered by :order option" do
                albums = Album.all.sort_by(&:name)
                expect(TestClass.new.index(options: {order: :name}).map(&:id)).to eq(albums.map(&:id))
              end
            end
          end

          context "with a class default order containing a lambda returning nil" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, model_class: Album
                default_order -> { default_order_attributes }

                def default_order_attributes
                  nil
                end
              end

              stub_const("TestClass", test_class)
            end

            context "without :order option" do
              it "returns records in database order" do
                expect(TestClass.new.index.map(&:id)).to eq(Album.ids)
              end
            end

            context "with :order option" do
              it "returns records ordered by :order option" do
                albums = Album.all.sort_by(&:name)
                expect(TestClass.new.index(options: {order: :name}).map(&:id)).to eq(albums.map(&:id))
              end
            end
          end

          context "with a class default order containing a lambda returning an empty array" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, model_class: Album
                default_order -> { default_order_attributes }

                def default_order_attributes
                  []
                end
              end

              stub_const("TestClass", test_class)
            end

            context "without :order option" do
              it "returns records in database order" do
                expect(TestClass.new.index.map(&:id)).to eq(Album.ids)
              end
            end

            context "with :order option" do
              it "returns records ordered by :order option" do
                albums = Album.all.sort_by(&:name)
                expect(TestClass.new.index(options: {order: :name}).map(&:id)).to eq(albums.map(&:id))
              end
            end
          end
        end

        describe "#scopes" do
          context "without a class default scopes" do
            context "without :scopes option" do
              it "returns all records" do
                expect(TestClass.new.index.size).to eq(Album.count)
              end
            end

            context "with a symbol :scopes option" do
              it "returns records filtered by the :scopes option" do
                collection = TestClass.new.index(options: {scopes: :rock})
                expect(collection).to match_array(Album.rock)
              end
            end

            context "with a string :scopes option" do
              it "returns records filtered by the :scopes option" do
                collection = TestClass.new.index(options: {scopes: "rock"})
                expect(collection).to match_array(Album.rock)
              end
            end

            context "with a hash :scopes option" do
              it "returns records filtered by the :scopes option" do
                collection = TestClass.new.index(options: {scopes: {genre_and_released_in_year: [:rock, 1969]}})
                expect(collection).to match_array(Album.rock.released_in_year(1969))
              end
            end

            context "with an array of :scopes options" do
              it "returns records filtered by the :scopes option" do
                collection = TestClass.new.index(options: {scopes: [:rock, {released_in_year: 1969}]})
                expect(collection).to match_array(Album.rock.released_in_year(1969))
              end
            end
          end

          context "with a class default scopes" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, model_class: Album
                default_scopes :electronic
              end

              stub_const("TestClass", test_class)
            end

            context "without :scopes option" do
              it "returns records filtered by the class default scopes" do
                collection = TestClass.new.index
                expect(collection).to match_array(Album.electronic)
              end
            end

            context "with a :scopes option" do
              it "returns records filtered by the :scopes option" do
                collection = TestClass.new.index(options: {scopes: :rock})
                expect(collection).to match_array(Album.rock)
              end
            end
          end

          context "with a class default scopes containing a symbol" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, model_class: Album
                default_scopes :electronic
              end

              stub_const("TestClass", test_class)
            end

            it "returns records filtered by the class default scopes" do
              collection = TestClass.new.index
              expect(collection).to match_array(Album.electronic)
            end
          end

          context "with a class default scopes containing a string" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, model_class: Album
                default_scopes "electronic"
              end

              stub_const("TestClass", test_class)
            end

            it "returns records filtered by the class default scopes" do
              collection = TestClass.new.index
              expect(collection).to match_array(Album.electronic)
            end
          end

          context "with a class default scopes containing a hash" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, model_class: Album
                default_scopes({genre_and_released_in_year: [:rock, 1969]})
              end

              stub_const("TestClass", test_class)
            end

            it "returns records filtered by the class default scopes" do
              collection = TestClass.new.index
              expect(collection).to match_array(Album.rock.released_in_year(1969))
            end
          end

          context "with a class default scopes containing an array" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, model_class: Album
                default_scopes :electronic, {released_in_year: 1986}
              end

              stub_const("TestClass", test_class)
            end

            it "returns records filtered by the class default scopes" do
              collection = TestClass.new.index
              expect(collection).to match_array(Album.electronic.released_in_year(1986))
            end
          end

          context "with a class default scopes containing a lambda that returns scopes" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, model_class: Album
                default_scopes -> { index_scopes }

                def index_scopes
                  :rock
                end
              end

              stub_const("TestClass", test_class)
            end

            it "returns records filtered by the class default scopes return value" do
              collection = TestClass.new.index
              expect(collection).to match_array(Album.rock)
            end
          end

          context "with a class default scopes containing a proc that returns scopes" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, model_class: Album
                default_scopes proc { index_scopes }

                def index_scopes
                  [:rock, {released_in_year: 1969}]
                end
              end

              stub_const("TestClass", test_class)
            end

            it "returns records filtered by the class default scopes return value" do
              collection = TestClass.new.index
              expect(collection).to match_array(Album.rock.released_in_year(1969))
            end
          end

          context "with a class default scopes containing a lambda that returns nil" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, model_class: Album
                default_scopes -> { index_scopes }

                def index_scopes
                  nil
                end
              end

              stub_const("TestClass", test_class)
            end

            it "returns all records" do
              expect(TestClass.new.index.size).to eq(Album.count)
            end
          end

          context "with a class default scopes containing a lambda that returns an empty array" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, model_class: Album
                default_scopes -> { index_scopes }

                def index_scopes
                  []
                end
              end

              stub_const("TestClass", test_class)
            end

            it "returns all records" do
              expect(TestClass.new.index.size).to eq(Album.count)
            end
          end
        end

        describe "#includes" do
          context "without a class default includes" do
            context "without :includes option" do
              it "returns records without eager loaded assocations" do
                collection = TestClass.new.index
                expect(collection.first.songs).not_to be_loaded
                expect(collection.first.association(:artist)).not_to be_loaded
              end
            end

            context "with :includes option" do
              it "returns records with :includes option eager loaded associations" do
                collection = TestClass.new.index(options: {includes: [:songs, :artist]})
                expect(collection.first.songs).to be_loaded
                expect(collection.first.association(:artist)).to be_loaded
              end

              it "returns records using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.index(options: {includes: [:songs, :artist]})
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "returns records with :includes option eager loaded associations" do
                collection = TestClass.new.index(options: {includes: {associations: [:songs, :artist], loading_method: :preload}})
                expect(collection.first.songs).to be_loaded
                expect(collection.first.association(:artist)).to be_loaded
              end

              it "returns records using the :includes option :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
                TestClass.new.index(options: {includes: {associations: [:songs, :artist], loading_method: :preload}})
              end
            end
          end

          context "with a class default includes containing an association" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, model_class: Album
                default_includes :songs
              end

              stub_const("TestClass", test_class)
            end

            context "without :includes option" do
              it "returns records with class default eager loaded assocations" do
                collection = TestClass.new.index
                expect(collection.first.songs).to be_loaded
                expect(collection.first.association(:artist)).not_to be_loaded
              end

              it "returns records using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.index
              end
            end

            context "with :includes option" do
              it "returns records with :includes option eager loaded associations" do
                collection = TestClass.new.index(options: {includes: :artist})
                expect(collection.first.songs).not_to be_loaded
                expect(collection.first.association(:artist)).to be_loaded
              end

              it "returns records using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.index(options: {includes: :artist})
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "returns records with :includes option eager loaded associations" do
                collection = TestClass.new.index(options: {includes: {associations: :artist, loading_method: :preload}})
                expect(collection.first.songs).not_to be_loaded
                expect(collection.first.association(:artist)).to be_loaded
              end

              it "returns records using the :includes option :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
                TestClass.new.index(options: {includes: {associations: :artist, loading_method: :preload}})
              end
            end
          end

          context "with a class default includes containing multiple associations" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, model_class: Album
                default_includes :songs, :artist
              end

              stub_const("TestClass", test_class)
            end

            context "without :includes option" do
              it "returns records with class default eager loaded assocations" do
                collection = TestClass.new.index
                expect(collection.first.songs).to be_loaded
                expect(collection.first.association(:artist)).to be_loaded
                expect(collection.first.association(:label)).not_to be_loaded
              end

              it "returns records using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.index
              end
            end

            context "with :includes option" do
              it "returns records with :includes option eager loaded associations" do
                collection = TestClass.new.index(options: {includes: [:artist, :label]})
                expect(collection.first.songs).not_to be_loaded
                expect(collection.first.association(:artist)).to be_loaded
                expect(collection.first.association(:label)).to be_loaded
              end

              it "returns records using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.index(options: {includes: :artist})
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "returns records with :includes option eager loaded associations" do
                collection = TestClass.new.index(options: {includes: {associations: [:artist, :label], loading_method: :preload}})
                expect(collection.first.songs).not_to be_loaded
                expect(collection.first.association(:artist)).to be_loaded
                expect(collection.first.association(:label)).to be_loaded
              end

              it "returns records using the :includes option :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
                TestClass.new.index(options: {includes: {associations: :artist, loading_method: :preload}})
              end
            end
          end

          context "with a class default includes containing an array & hash of associations" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, model_class: Album
                default_includes :artist, songs: :artist
              end

              stub_const("TestClass", test_class)
            end

            context "without :includes option" do
              it "returns records with class default eager loaded assocations" do
                collection = TestClass.new.index
                expect(collection.first.songs).to be_loaded
                expect(collection.first.songs.first.association(:artist)).to be_loaded
                expect(collection.first.association(:artist)).to be_loaded
                expect(collection.first.association(:label)).not_to be_loaded
              end

              it "returns records using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.index
              end
            end

            context "with :includes option" do
              it "returns records with :includes option eager loaded associations" do
                collection = TestClass.new.index(options: {includes: [{songs: :artist}, :label]})
                expect(collection.first.songs).to be_loaded
                expect(collection.first.songs.first.association(:artist)).to be_loaded
                expect(collection.first.association(:artist)).not_to be_loaded
                expect(collection.first.association(:label)).to be_loaded
              end

              it "returns records using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.index(options: {includes: :artist})
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "returns records with :includes option eager loaded associations" do
                collection = TestClass.new.index(options: {includes: {associations: [{songs: :artist}, :label], loading_method: :preload}})
                expect(collection.first.songs).to be_loaded
                expect(collection.first.songs.first.association(:artist)).to be_loaded
                expect(collection.first.association(:artist)).not_to be_loaded
                expect(collection.first.association(:label)).to be_loaded
              end

              it "returns records using the :includes option :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
                TestClass.new.index(options: {includes: {associations: :artist, loading_method: :preload}})
              end
            end
          end

          context "with a class default includes containing a hash of associations" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, model_class: Album
                default_includes songs: :artist
              end

              stub_const("TestClass", test_class)
            end

            context "without :includes option" do
              it "returns records with class default eager loaded assocations" do
                collection = TestClass.new.index
                expect(collection.first.songs).to be_loaded
                expect(collection.first.songs.first.association(:artist)).to be_loaded
                expect(collection.first.association(:artist)).not_to be_loaded
              end

              it "returns records using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.index
              end
            end

            context "with :includes option" do
              it "returns records with :includes option eager loaded associations" do
                collection = TestClass.new.index(options: {includes: [{artist: :songs}, :label]})
                expect(collection.first.songs).not_to be_loaded
                expect(collection.first.association(:artist)).to be_loaded
                expect(collection.first.artist.songs).to be_loaded
              end

              it "returns records using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.index(options: {includes: :artist})
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "returns records with :includes option eager loaded associations" do
                collection = TestClass.new.index(options: {includes: {associations: [{artist: :songs}, :label], loading_method: :preload}})
                expect(collection.first.songs).not_to be_loaded
                expect(collection.first.association(:artist)).to be_loaded
                expect(collection.first.artist.songs).to be_loaded
              end

              it "returns records using the :includes option :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
                TestClass.new.index(options: {includes: {associations: :artist, loading_method: :preload}})
              end
            end
          end

          context "with a class default includes containing multiple associations for the method" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, :show, model_class: Album
                default_includes :songs, :artist, methods: :index
                default_includes :songs, methods: :show
              end

              stub_const("TestClass", test_class)
            end

            context "without :includes option" do
              it "returns records with class default eager loaded assocations" do
                collection = TestClass.new.index
                expect(collection.first.songs).to be_loaded
                expect(collection.first.association(:artist)).to be_loaded
                expect(collection.first.association(:label)).not_to be_loaded
              end

              it "returns records using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.index
              end
            end

            context "with :includes option" do
              it "returns records with :includes option eager loaded associations" do
                collection = TestClass.new.index(options: {includes: [:artist, :label]})
                expect(collection.first.songs).not_to be_loaded
                expect(collection.first.association(:artist)).to be_loaded
                expect(collection.first.association(:label)).to be_loaded
              end

              it "returns records using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.index(options: {includes: :artist})
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "returns records with :includes option eager loaded associations" do
                collection = TestClass.new.index(options: {includes: {associations: [:artist, :label], loading_method: :preload}})
                expect(collection.first.songs).not_to be_loaded
                expect(collection.first.association(:artist)).to be_loaded
                expect(collection.first.association(:label)).to be_loaded
              end

              it "returns records using the :includes option :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
                TestClass.new.index(options: {includes: {associations: :artist, loading_method: :preload}})
              end
            end
          end

          context "with a class default includes containing an array & hash of associations for the method" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, :show, model_class: Album
                default_includes :artist, songs: :artist, methods: :index
                default_includes :songs, methods: :show
              end

              stub_const("TestClass", test_class)
            end

            context "without :includes option" do
              it "returns records with class default eager loaded assocations" do
                collection = TestClass.new.index
                expect(collection.first.songs).to be_loaded
                expect(collection.first.songs.first.association(:artist)).to be_loaded
                expect(collection.first.association(:artist)).to be_loaded
                expect(collection.first.association(:label)).not_to be_loaded
              end

              it "returns records using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.index
              end
            end

            context "with :includes option" do
              it "returns records with :includes option eager loaded associations" do
                collection = TestClass.new.index(options: {includes: [{songs: :artist}, :label]})
                expect(collection.first.songs).to be_loaded
                expect(collection.first.songs.first.association(:artist)).to be_loaded
                expect(collection.first.association(:artist)).not_to be_loaded
                expect(collection.first.association(:label)).to be_loaded
              end

              it "returns records using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.index(options: {includes: :artist})
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "returns records with :includes option eager loaded associations" do
                collection = TestClass.new.index(options: {includes: {associations: [{songs: :artist}, :label], loading_method: :preload}})
                expect(collection.first.songs).to be_loaded
                expect(collection.first.songs.first.association(:artist)).to be_loaded
                expect(collection.first.association(:artist)).not_to be_loaded
                expect(collection.first.association(:label)).to be_loaded
              end

              it "returns records using the :includes option :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
                TestClass.new.index(options: {includes: {associations: :artist, loading_method: :preload}})
              end
            end
          end

          context "with a class default includes containing a hash of associations for the method" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, :show, model_class: Album
                default_includes songs: :artist, methods: :index
                default_includes :songs, methods: :show
              end

              stub_const("TestClass", test_class)
            end

            context "without :includes option" do
              it "returns records with class default eager loaded assocations" do
                collection = TestClass.new.index
                expect(collection.first.songs).to be_loaded
                expect(collection.first.songs.first.association(:artist)).to be_loaded
                expect(collection.first.association(:artist)).not_to be_loaded
              end

              it "returns records using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.index
              end
            end

            context "with :includes option" do
              it "returns records with :includes option eager loaded associations" do
                collection = TestClass.new.index(options: {includes: [{artist: :songs}, :label]})
                expect(collection.first.songs).not_to be_loaded
                expect(collection.first.association(:artist)).to be_loaded
                expect(collection.first.artist.songs).to be_loaded
              end

              it "returns records using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.index(options: {includes: :artist})
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "returns records with :includes option eager loaded associations" do
                collection = TestClass.new.index(options: {includes: {associations: [{artist: :songs}, :label], loading_method: :preload}})
                expect(collection.first.songs).not_to be_loaded
                expect(collection.first.association(:artist)).to be_loaded
                expect(collection.first.artist.songs).to be_loaded
              end

              it "returns records using the :includes option :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
                TestClass.new.index(options: {includes: {associations: :artist, loading_method: :preload}})
              end
            end
          end

          context "with a class default includes containing multiple associations and :loading_method" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, model_class: Album
                default_includes :songs, :artist, loading_method: :eager_load
              end

              stub_const("TestClass", test_class)
            end

            context "without :includes option" do
              it "returns records with class default eager loaded assocations" do
                collection = TestClass.new.index
                expect(collection.first.songs).to be_loaded
                expect(collection.first.association(:artist)).to be_loaded
                expect(collection.first.association(:label)).not_to be_loaded
              end

              it "returns records using the class default :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:eager_load).and_call_original
                TestClass.new.index
              end
            end

            context "with :includes option" do
              it "returns records with :includes option eager loaded associations" do
                collection = TestClass.new.index(options: {includes: [:artist, :label]})
                expect(collection.first.songs).not_to be_loaded
                expect(collection.first.association(:artist)).to be_loaded
                expect(collection.first.association(:label)).to be_loaded
              end

              it "returns records using the class default :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:eager_load).and_call_original
                TestClass.new.index
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "returns records with :includes option eager loaded associations" do
                collection = TestClass.new.index(options: {includes: {associations: [:artist, :label], loading_method: :preload}})
                expect(collection.first.songs).not_to be_loaded
                expect(collection.first.association(:artist)).to be_loaded
                expect(collection.first.association(:label)).to be_loaded
              end

              it "returns records using the :includes option :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
                TestClass.new.index(options: {includes: {associations: :artist, loading_method: :preload}})
              end
            end
          end

          context "with a class default includes containing an array & hash of associations and :loading_method" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, model_class: Album
                default_includes :artist, songs: :artist, loading_method: :eager_load
              end

              stub_const("TestClass", test_class)
            end

            context "without :includes option" do
              it "returns records with class default eager loaded assocations" do
                collection = TestClass.new.index
                expect(collection.first.songs).to be_loaded
                expect(collection.first.songs.first.association(:artist)).to be_loaded
                expect(collection.first.association(:artist)).to be_loaded
                expect(collection.first.association(:label)).not_to be_loaded
              end

              it "returns records using the class default :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:eager_load).and_call_original
                TestClass.new.index
              end
            end

            context "with :includes option" do
              it "returns records with :includes option eager loaded associations" do
                collection = TestClass.new.index(options: {includes: [{songs: :artist}, :label]})
                expect(collection.first.songs).to be_loaded
                expect(collection.first.songs.first.association(:artist)).to be_loaded
                expect(collection.first.association(:artist)).not_to be_loaded
                expect(collection.first.association(:label)).to be_loaded
              end

              it "returns records using the class default :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:eager_load).and_call_original
                TestClass.new.index
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "returns records with :includes option eager loaded associations" do
                collection = TestClass.new.index(options: {includes: {associations: [{songs: :artist}, :label], loading_method: :preload}})
                expect(collection.first.songs).to be_loaded
                expect(collection.first.songs.first.association(:artist)).to be_loaded
                expect(collection.first.association(:artist)).not_to be_loaded
                expect(collection.first.association(:label)).to be_loaded
              end

              it "returns records using the :includes option :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
                TestClass.new.index(options: {includes: {associations: :artist, loading_method: :preload}})
              end
            end
          end

          context "with a class default includes containing a hash of associations and :loading_method" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, model_class: Album
                default_includes songs: :artist, loading_method: :eager_load
              end

              stub_const("TestClass", test_class)
            end

            context "without :includes option" do
              it "returns records with class default eager loaded assocations" do
                collection = TestClass.new.index
                expect(collection.first.songs).to be_loaded
                expect(collection.first.songs.first.association(:artist)).to be_loaded
                expect(collection.first.association(:artist)).not_to be_loaded
              end

              it "returns records using the class default :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:eager_load).and_call_original
                TestClass.new.index
              end
            end

            context "with :includes option" do
              it "returns records with :includes option eager loaded associations" do
                collection = TestClass.new.index(options: {includes: [{artist: :songs}, :label]})
                expect(collection.first.songs).not_to be_loaded
                expect(collection.first.association(:artist)).to be_loaded
                expect(collection.first.artist.songs).to be_loaded
              end

              it "returns records using the class default :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:eager_load).and_call_original
                TestClass.new.index
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "returns records with :includes option eager loaded associations" do
                collection = TestClass.new.index(options: {includes: {associations: [{artist: :songs}, :label], loading_method: :preload}})
                expect(collection.first.songs).not_to be_loaded
                expect(collection.first.association(:artist)).to be_loaded
                expect(collection.first.artist.songs).to be_loaded
              end

              it "returns records using the :includes option :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
                TestClass.new.index(options: {includes: {associations: :artist, loading_method: :preload}})
              end
            end
          end

          context "with a class default includes containing multiple associations and :loading_method for the method" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, :show, model_class: Album
                default_includes :songs, :artist, loading_method: :eager_load, methods: :index
                default_includes :songs, methods: :show
              end

              stub_const("TestClass", test_class)
            end

            context "without :includes option" do
              it "returns records with class default eager loaded assocations" do
                collection = TestClass.new.index
                expect(collection.first.songs).to be_loaded
                expect(collection.first.association(:artist)).to be_loaded
                expect(collection.first.association(:label)).not_to be_loaded
              end

              it "returns records using the class default :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:eager_load).and_call_original
                TestClass.new.index
              end
            end

            context "with :includes option" do
              it "returns records with :includes option eager loaded associations" do
                collection = TestClass.new.index(options: {includes: [:artist, :label]})
                expect(collection.first.songs).not_to be_loaded
                expect(collection.first.association(:artist)).to be_loaded
                expect(collection.first.association(:label)).to be_loaded
              end

              it "returns records using the class default :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:eager_load).and_call_original
                TestClass.new.index
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "returns records with :includes option eager loaded associations" do
                collection = TestClass.new.index(options: {includes: {associations: [:artist, :label], loading_method: :preload}})
                expect(collection.first.songs).not_to be_loaded
                expect(collection.first.association(:artist)).to be_loaded
                expect(collection.first.association(:label)).to be_loaded
              end

              it "returns records using the :includes option :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
                TestClass.new.index(options: {includes: {associations: :artist, loading_method: :preload}})
              end
            end
          end

          context "with a class default includes containing an array & hash of associations and :loading_method for the method" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, :show, model_class: Album
                default_includes :artist, songs: :artist, loading_method: :eager_load, methods: :index
                default_includes :songs, methods: :show
              end

              stub_const("TestClass", test_class)
            end

            context "without :includes option" do
              it "returns records with class default eager loaded assocations" do
                collection = TestClass.new.index
                expect(collection.first.songs).to be_loaded
                expect(collection.first.songs.first.association(:artist)).to be_loaded
                expect(collection.first.association(:artist)).to be_loaded
                expect(collection.first.association(:label)).not_to be_loaded
              end

              it "returns records using the class default :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:eager_load).and_call_original
                TestClass.new.index
              end
            end

            context "with :includes option" do
              it "returns records with :includes option eager loaded associations" do
                collection = TestClass.new.index(options: {includes: [{songs: :artist}, :label]})
                expect(collection.first.songs).to be_loaded
                expect(collection.first.songs.first.association(:artist)).to be_loaded
                expect(collection.first.association(:artist)).not_to be_loaded
                expect(collection.first.association(:label)).to be_loaded
              end

              it "returns records using the class default :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:eager_load).and_call_original
                TestClass.new.index
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "returns records with :includes option eager loaded associations" do
                collection = TestClass.new.index(options: {includes: {associations: [{songs: :artist}, :label], loading_method: :preload}})
                expect(collection.first.songs).to be_loaded
                expect(collection.first.songs.first.association(:artist)).to be_loaded
                expect(collection.first.association(:artist)).not_to be_loaded
                expect(collection.first.association(:label)).to be_loaded
              end

              it "returns records using the :includes option :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
                TestClass.new.index(options: {includes: {associations: :artist, loading_method: :preload}})
              end
            end
          end

          context "with a class default includes containing a hash of associations and :loading_method for the method" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, :show, model_class: Album
                default_includes songs: :artist, loading_method: :eager_load, methods: :index
                default_includes :songs, methods: :show
              end

              stub_const("TestClass", test_class)
            end

            context "without :includes option" do
              it "returns records with class default eager loaded assocations" do
                collection = TestClass.new.index
                expect(collection.first.songs).to be_loaded
                expect(collection.first.songs.first.association(:artist)).to be_loaded
                expect(collection.first.association(:artist)).not_to be_loaded
              end

              it "returns records using the class default :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:eager_load).and_call_original
                TestClass.new.index
              end
            end

            context "with :includes option" do
              it "returns records with :includes option eager loaded associations" do
                collection = TestClass.new.index(options: {includes: [{artist: :songs}, :label]})
                expect(collection.first.songs).not_to be_loaded
                expect(collection.first.association(:artist)).to be_loaded
                expect(collection.first.artist.songs).to be_loaded
              end

              it "returns records using the class default :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:eager_load).and_call_original
                TestClass.new.index
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "returns records with :includes option eager loaded associations" do
                collection = TestClass.new.index(options: {includes: {associations: [{artist: :songs}, :label], loading_method: :preload}})
                expect(collection.first.songs).not_to be_loaded
                expect(collection.first.association(:artist)).to be_loaded
                expect(collection.first.artist.songs).to be_loaded
              end

              it "returns records using the :includes option :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
                TestClass.new.index(options: {includes: {associations: :artist, loading_method: :preload}})
              end
            end
          end

          context "with a class default includes containing a lambda that returns an association" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, model_class: Album
                default_includes -> { index_includes }

                def index_includes
                  :songs
                end
              end

              stub_const("TestClass", test_class)
            end

            context "without :includes option" do
              it "returns records with class default eager loaded assocations" do
                collection = TestClass.new.index
                expect(collection.first.songs).to be_loaded
                expect(collection.first.association(:artist)).not_to be_loaded
              end

              it "returns records using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.index
              end
            end

            context "with :includes option" do
              it "returns records with :includes option eager loaded associations" do
                collection = TestClass.new.index(options: {includes: :artist})
                expect(collection.first.songs).not_to be_loaded
                expect(collection.first.association(:artist)).to be_loaded
              end

              it "returns records using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.index(options: {includes: :artist})
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "returns records with :includes option eager loaded associations" do
                collection = TestClass.new.index(options: {includes: {associations: :artist, loading_method: :preload}})
                expect(collection.first.songs).not_to be_loaded
                expect(collection.first.association(:artist)).to be_loaded
              end

              it "returns records using the :includes option :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
                TestClass.new.index(options: {includes: {associations: :artist, loading_method: :preload}})
              end
            end
          end

          context "with a class default includes containing a proc that returns an association" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, model_class: Album
                default_includes proc { index_includes }

                def index_includes
                  :songs
                end
              end

              stub_const("TestClass", test_class)
            end

            context "without :includes option" do
              it "returns records with class default eager loaded assocations" do
                collection = TestClass.new.index
                expect(collection.first.songs).to be_loaded
                expect(collection.first.association(:artist)).not_to be_loaded
              end

              it "returns records using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.index
              end
            end

            context "with :includes option" do
              it "returns records with :includes option eager loaded associations" do
                collection = TestClass.new.index(options: {includes: :artist})
                expect(collection.first.songs).not_to be_loaded
                expect(collection.first.association(:artist)).to be_loaded
              end

              it "returns records using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.index(options: {includes: :artist})
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "returns records with :includes option eager loaded associations" do
                collection = TestClass.new.index(options: {includes: {associations: :artist, loading_method: :preload}})
                expect(collection.first.songs).not_to be_loaded
                expect(collection.first.association(:artist)).to be_loaded
              end

              it "returns records using the :includes option :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
                TestClass.new.index(options: {includes: {associations: :artist, loading_method: :preload}})
              end
            end
          end

          context "with a class default includes containing a lambda that returns an array of associations" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, :show, model_class: Album
                default_includes -> { index_includes }

                def index_includes
                  [:songs, :artist]
                end
              end

              stub_const("TestClass", test_class)
            end

            context "without :includes option" do
              it "returns records with class default eager loaded assocations" do
                collection = TestClass.new.index
                expect(collection.first.songs).to be_loaded
                expect(collection.first.association(:artist)).to be_loaded
              end

              it "returns records using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.index
              end
            end

            context "with :includes option" do
              it "returns records with :includes option eager loaded associations" do
                collection = TestClass.new.index(options: {includes: :artist})
                expect(collection.first.songs).not_to be_loaded
                expect(collection.first.association(:artist)).to be_loaded
              end

              it "returns records using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.index(options: {includes: :artist})
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "returns records with :includes option eager loaded associations" do
                collection = TestClass.new.index(options: {includes: {associations: :artist, loading_method: :preload}})
                expect(collection.first.songs).not_to be_loaded
                expect(collection.first.association(:artist)).to be_loaded
              end

              it "returns records using the :includes option :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
                TestClass.new.index(options: {includes: {associations: :artist, loading_method: :preload}})
              end
            end
          end

          context "with a class default includes containing a lambda that returns an array & hash of associations" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, model_class: Album
                default_includes -> { index_includes }

                def index_includes
                  [:artist, songs: :artist]
                end
              end

              stub_const("TestClass", test_class)
            end

            context "without :includes option" do
              it "returns records with class default eager loaded assocations" do
                collection = TestClass.new.index
                expect(collection.first.songs).to be_loaded
                expect(collection.first.songs.first.association(:artist)).to be_loaded
                expect(collection.first.association(:artist)).to be_loaded
                expect(collection.first.association(:label)).not_to be_loaded
              end

              it "returns records using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.index
              end
            end

            context "with :includes option" do
              it "returns records with :includes option eager loaded associations" do
                collection = TestClass.new.index(options: {includes: [{songs: :artist}, :label]})
                expect(collection.first.songs).to be_loaded
                expect(collection.first.songs.first.association(:artist)).to be_loaded
                expect(collection.first.association(:artist)).not_to be_loaded
                expect(collection.first.association(:label)).to be_loaded
              end

              it "returns records using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.index(options: {includes: :artist})
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "returns records with :includes option eager loaded associations" do
                collection = TestClass.new.index(options: {includes: {associations: [{songs: :artist}, :label], loading_method: :preload}})
                expect(collection.first.songs).to be_loaded
                expect(collection.first.songs.first.association(:artist)).to be_loaded
                expect(collection.first.association(:artist)).not_to be_loaded
                expect(collection.first.association(:label)).to be_loaded
              end

              it "returns records using the :includes option :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
                TestClass.new.index(options: {includes: {associations: :artist, loading_method: :preload}})
              end
            end
          end

          context "with a class default includes containing a lambda that returns a hash of associations" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, model_class: Album
                default_includes -> { index_includes }

                def index_includes
                  {songs: :artist}
                end
              end

              stub_const("TestClass", test_class)
            end

            context "without :includes option" do
              it "returns records with class default eager loaded assocations" do
                collection = TestClass.new.index
                expect(collection.first.songs).to be_loaded
                expect(collection.first.songs.first.association(:artist)).to be_loaded
                expect(collection.first.association(:artist)).not_to be_loaded
              end

              it "returns records using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.index
              end
            end

            context "with :includes option" do
              it "returns records with :includes option eager loaded associations" do
                collection = TestClass.new.index(options: {includes: [{artist: :songs}, :label]})
                expect(collection.first.songs).not_to be_loaded
                expect(collection.first.association(:artist)).to be_loaded
                expect(collection.first.artist.songs).to be_loaded
              end

              it "returns records using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.index(options: {includes: :artist})
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "returns records with :includes option eager loaded associations" do
                collection = TestClass.new.index(options: {includes: {associations: [{artist: :songs}, :label], loading_method: :preload}})
                expect(collection.first.songs).not_to be_loaded
                expect(collection.first.association(:artist)).to be_loaded
                expect(collection.first.artist.songs).to be_loaded
              end

              it "returns records using the :includes option :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
                TestClass.new.index(options: {includes: {associations: :artist, loading_method: :preload}})
              end
            end
          end

          context "with a class default includes containing a lambda that returns associations for the method" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, :show, model_class: Album
                default_includes -> { index_includes }, methods: :index
                default_includes :songs, methods: :show

                def index_includes
                  [:songs, :artist]
                end
              end

              stub_const("TestClass", test_class)
            end

            context "without :includes option" do
              it "returns records with class default eager loaded assocations" do
                collection = TestClass.new.index
                expect(collection.first.songs).to be_loaded
                expect(collection.first.association(:artist)).to be_loaded
              end

              it "returns records using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.index
              end
            end

            context "with :includes option" do
              it "returns records with :includes option eager loaded associations" do
                collection = TestClass.new.index(options: {includes: :artist})
                expect(collection.first.songs).not_to be_loaded
                expect(collection.first.association(:artist)).to be_loaded
              end

              it "returns records using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.index(options: {includes: :artist})
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "returns records with :includes option eager loaded associations" do
                collection = TestClass.new.index(options: {includes: {associations: :artist, loading_method: :preload}})
                expect(collection.first.songs).not_to be_loaded
                expect(collection.first.association(:artist)).to be_loaded
              end

              it "returns records using the :includes option :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
                TestClass.new.index(options: {includes: {associations: :artist, loading_method: :preload}})
              end
            end
          end

          context "with a class default includes containing a lambda that returns nil" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, model_class: Album
                default_includes -> { index_includes }

                def index_includes
                  nil
                end
              end

              stub_const("TestClass", test_class)
            end

            context "without :includes option" do
              it "returns records without eager loaded assocations" do
                collection = TestClass.new.index
                expect(collection.first.songs).not_to be_loaded
                expect(collection.first.association(:artist)).not_to be_loaded
              end
            end

            context "with :includes option" do
              it "returns records with :includes option eager loaded associations" do
                collection = TestClass.new.index(options: {includes: [:songs, :artist]})
                expect(collection.first.songs).to be_loaded
                expect(collection.first.association(:artist)).to be_loaded
              end

              it "returns records using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.index(options: {includes: [:songs, :artist]})
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "returns records with :includes option eager loaded associations" do
                collection = TestClass.new.index(options: {includes: {associations: [:songs, :artist], loading_method: :preload}})
                expect(collection.first.songs).to be_loaded
                expect(collection.first.association(:artist)).to be_loaded
              end

              it "returns records using the :includes option :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
                TestClass.new.index(options: {includes: {associations: [:songs, :artist], loading_method: :preload}})
              end
            end
          end

          context "with a class default includes containing a lambda that returns an empty array" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, model_class: Album
                default_includes -> { index_includes }

                def index_includes
                  []
                end
              end

              stub_const("TestClass", test_class)
            end

            context "without :includes option" do
              it "returns records without eager loaded assocations" do
                collection = TestClass.new.index
                expect(collection.first.songs).not_to be_loaded
                expect(collection.first.association(:artist)).not_to be_loaded
              end
            end

            context "with :includes option" do
              it "returns records with :includes option eager loaded associations" do
                collection = TestClass.new.index(options: {includes: [:songs, :artist]})
                expect(collection.first.songs).to be_loaded
                expect(collection.first.association(:artist)).to be_loaded
              end

              it "returns records using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.index(options: {includes: [:songs, :artist]})
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "returns records with :includes option eager loaded associations" do
                collection = TestClass.new.index(options: {includes: {associations: [:songs, :artist], loading_method: :preload}})
                expect(collection.first.songs).to be_loaded
                expect(collection.first.association(:artist)).to be_loaded
              end

              it "returns records using the :includes option :loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
                TestClass.new.index(options: {includes: {associations: [:songs, :artist], loading_method: :preload}})
              end
            end
          end
        end

        describe "#select" do
          context "without a class default select" do
            context "without :select option" do
              it "returns records with all attributes" do
                collection = TestClass.new.index
                expect(collection.first.attributes.keys.sort).to eq(Album.new.attributes.keys.map(&:to_s).sort)
              end
            end

            context "with :select option" do
              it "returns records with :select option attributes" do
                collection = TestClass.new.index(options: {select: [:id, :name]})
                expect(collection.first.attributes.keys.sort).to eq([:id, :name].map(&:to_s).sort)
              end
            end
          end

          context "with a class default select containing attributes" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, model_class: Album
                default_select :id, :name, :released_at
              end

              stub_const("TestClass", test_class)
            end

            context "without :select option" do
              it "returns records with class default select attributes" do
                collection = TestClass.new.index
                expect(collection.first.attributes.keys.sort).to eq([:id, :name, :released_at].map(&:to_s).sort)
              end
            end

            context "with :select option" do
              it "returns records with :select option attributes" do
                collection = TestClass.new.index(options: {select: :id})
                expect(collection.first.attributes.keys.sort).to eq([:id].map(&:to_s).sort)
              end
            end
          end

          context "with a class default select containing attributes for the method" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, :show, model_class: Album
                default_select :id, :name, :genre, methods: :index
                default_select :id, methods: :show
              end

              stub_const("TestClass", test_class)
            end

            context "without :select option" do
              it "returns records with class default select attributes" do
                collection = TestClass.new.index
                expect(collection.first.attributes.keys.sort).to eq([:id, :name, :genre].map(&:to_s).sort)
              end
            end

            context "with :select option" do
              it "returns records with :select option attributes" do
                collection = TestClass.new.index(options: {select: [:id, :name, :released_at]})
                expect(collection.first.attributes.keys.sort).to eq([:id, :name, :released_at].map(&:to_s).sort)
              end
            end
          end

          context "with a class default select containing a lambda that returns attributes" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, model_class: Album
                default_select -> { select_attributes }

                def select_attributes
                  [:id, :name, :released_at]
                end
              end

              stub_const("TestClass", test_class)
            end

            context "without :select option" do
              it "returns records with class default select attributes" do
                collection = TestClass.new.index
                expect(collection.first.attributes.keys.sort).to eq([:id, :name, :released_at].map(&:to_s).sort)
              end
            end

            context "with :select option" do
              it "returns records with :select option attributes" do
                collection = TestClass.new.index(options: {select: :id})
                expect(collection.first.attributes.keys.sort).to eq([:id].map(&:to_s).sort)
              end
            end
          end

          context "with a class default select containing a proc that returns attributes" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, model_class: Album
                default_select proc { select_attributes }

                def select_attributes
                  [:id, :name, :released_at]
                end
              end

              stub_const("TestClass", test_class)
            end

            context "without :select option" do
              it "returns records with class default select attributes" do
                collection = TestClass.new.index
                expect(collection.first.attributes.keys.sort).to eq([:id, :name, :released_at].map(&:to_s).sort)
              end
            end

            context "with :select option" do
              it "returns records with :select option attributes" do
                collection = TestClass.new.index(options: {select: :id})
                expect(collection.first.attributes.keys.sort).to eq([:id].map(&:to_s).sort)
              end
            end
          end

          context "with a class default select containing a lambda for the method" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, :show, model_class: Album
                default_select -> { index_select_attributes }, methods: :index
                default_select -> { show_select_attributes }, methods: :show

                def index_select_attributes
                  [:id, :name, :genre]
                end

                def show_select_attributes
                  [:id]
                end
              end

              stub_const("TestClass", test_class)
            end

            context "without :select option" do
              it "returns records with class default select attributes" do
                collection = TestClass.new.index
                expect(collection.first.attributes.keys.sort).to eq([:id, :name, :genre].map(&:to_s).sort)
              end
            end

            context "with :select option" do
              it "returns records with :select option attributes" do
                collection = TestClass.new.index(options: {select: [:id, :name, :released_at]})
                expect(collection.first.attributes.keys.sort).to eq([:id, :name, :released_at].map(&:to_s).sort)
              end
            end
          end

          context "with a class default select containing a lambda that returns nil" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, model_class: Album
                default_select -> { select_attributes }

                def select_attributes
                  nil
                end
              end

              stub_const("TestClass", test_class)
            end

            context "without :select option" do
              it "returns records with all attributes" do
                collection = TestClass.new.index
                expect(collection.first.attributes.keys.sort).to eq(Album.new.attributes.keys.map(&:to_s).sort)
              end
            end

            context "with :select option" do
              it "returns records with :select option attributes" do
                collection = TestClass.new.index(options: {select: [:id, :name]})
                expect(collection.first.attributes.keys.sort).to eq([:id, :name].map(&:to_s).sort)
              end
            end
          end

          context "with a class default select containing a lambda that returns an empty array" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, model_class: Album
                default_select -> { select_attributes }

                def select_attributes
                  []
                end
              end

              stub_const("TestClass", test_class)
            end

            context "without :select option" do
              it "returns records with all attributes" do
                collection = TestClass.new.index
                expect(collection.first.attributes.keys.sort).to eq(Album.new.attributes.keys.map(&:to_s).sort)
              end
            end

            context "with :select option" do
              it "returns records with :select option attributes" do
                collection = TestClass.new.index(options: {select: [:id, :name]})
                expect(collection.first.attributes.keys.sort).to eq([:id, :name].map(&:to_s).sort)
              end
            end
          end
        end

        describe "#distinct" do
          context "when class :unique_search is false" do
            it "returns records without a DISTINCT statement" do
              expect(TestClass.new.index.to_sql).not_to include("SELECT DISTINCT")
            end
          end

          context "when class :unique_search is true" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, model_class: Album
                has_unique_search
              end

              stub_const("TestClass", test_class)
            end

            it "returns records with a DISTINCT statement" do
              expect(TestClass.new.index.to_sql).to include("SELECT DISTINCT")
            end
          end

          context "when class :unique_search is a method that returns false" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, model_class: Album
                has_unique_search if: :test

                def test
                  false
                end
              end

              stub_const("TestClass", test_class)
            end

            it "returns records without a DISTINCT statement" do
              expect(TestClass.new.index.to_sql).not_to include("SELECT DISTINCT")
            end
          end

          context "when class :unique_search is a method that returns true" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, model_class: Album
                has_unique_search if: :test

                def test
                  true
                end
              end

              stub_const("TestClass", test_class)
            end

            it "returns records with a DISTINCT statement" do
              expect(TestClass.new.index.to_sql).to include("SELECT DISTINCT")
            end
          end

          context "without a class default includes" do
            context "without :includes option" do
              it "returns records without eager loading association" do
                collection = TestClass.new.index
                expect(collection.first.songs).not_to be_loaded
              end
            end

            context "with :includes option" do
              it "returns records with :includes option eager loaded associations" do
                collection = TestClass.new.index(options: {includes: :songs})
                expect(collection.first.songs).to be_loaded
              end

              it "returns records using the configuration :default_loading_method" do
                expect_any_instance_of(ActiveRecord::Relation).to receive(ActiveManageable.configuration.default_loading_method).and_call_original
                TestClass.new.index(options: {includes: :songs})
              end
            end

            context "with :includes option containing :associations and :loading_method" do
              it "returns records with :includes option eager loaded associations" do
                collection = TestClass.new.index(options: {includes: {associations: :songs, loading_method: :preload}})
                expect(collection.first.songs).to be_loaded
              end
            end

            it "returns records using the :includes option :loading_method" do
              expect_any_instance_of(ActiveRecord::Relation).to receive(:preload).and_call_original
              TestClass.new.index(options: {includes: {associations: :songs, loading_method: :preload}})
            end
          end
        end

        context "when using the pundit authorization library" do
          before do
            ActiveManageable.configuration.authorization_library = :pundit
            test_class = Class.new(ActiveManageable::Base) do
              manageable :index, model_class: Album
            end

            stub_const("TestClass", test_class)
          end

          describe "#authorize" do
            context "when the current_user has no permissions" do
              it "raises Pundit::NotAuthorizedError error" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :none, album_genre: :all)
                expect { TestClass.new.index }.to raise_error(Pundit::NotAuthorizedError)
              end
            end

            context "when the current_user does not have read permission" do
              it "raises Pundit::NotAuthorizedError error" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :create, album_genre: :all)
                expect { TestClass.new.index }.to raise_error(Pundit::NotAuthorizedError)
              end
            end

            context "when the current_user has manage permission" do
              it "returns all records" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :manage, album_genre: :all)
                expect(TestClass.new.index).to match_array(Album.all)
              end
            end

            context "when the current_user has read permission" do
              it "returns all records" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :read, album_genre: :all)
                expect(TestClass.new.index).to match_array(Album.all)
              end
            end
          end

          describe "#authorization_scope" do
            context "when the current_user does not have access to any genres" do
              it "returns no records" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :read, album_genre: :none)
                expect(TestClass.new.index).to be_empty
              end
            end

            context "when the current_user has access to all genres" do
              it "returns all records" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :read, album_genre: :all)
                expect(TestClass.new.index).to match_array(Album.all)
              end
            end

            context "when the current_user has access to only the electronic genre" do
              it "returns scoped records" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :read, album_genre: :electronic)
                expect(TestClass.new.index).to match_array(Album.electronic)
              end
            end
          end
        end

        context "when using the cancancan authorization library" do
          before do
            ActiveManageable.configuration.authorization_library = :cancancan
            test_class = Class.new(ActiveManageable::Base) do
              manageable :index, model_class: Album
            end

            stub_const("TestClass", test_class)
          end

          describe "#authorize" do
            context "when the current_user has no permissions" do
              it "raises CanCan::AccessDenied error" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :none, album_genre: :all)
                expect { TestClass.new.index }.to raise_error(CanCan::AccessDenied)
              end
            end

            context "when the current_user does not have read permission" do
              it "raises CanCan::AccessDenied error" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :create, album_genre: :all)
                expect { TestClass.new.index }.to raise_error(CanCan::AccessDenied)
              end
            end

            context "when the current_user has manage permission" do
              it "returns all records" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :manage, album_genre: :all)
                expect(TestClass.new.index).to match_array(Album.all)
              end
            end

            context "when the current_user has read permission" do
              it "returns all records" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :read, album_genre: :all)
                expect(TestClass.new.index).to match_array(Album.all)
              end
            end
          end

          describe "#authorization_scope" do
            context "when the current_user does not have access to any genres" do
              it "returns no records" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :read, album_genre: :none)
                expect(TestClass.new.index).to be_empty
              end
            end

            context "when the current_user has access to all genres" do
              it "returns all records" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :read, album_genre: :all)
                expect(TestClass.new.index).to match_array(Album.all)
              end
            end

            context "when the current_user has access to only the electronic genre" do
              it "returns scoped records" do
                ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :read, album_genre: :electronic)
                expect(TestClass.new.index).to match_array(Album.electronic)
              end
            end
          end
        end

        context "when using the ransack search library" do
          before do
            ActiveManageable.configuration.search_library = :ransack
            test_class = Class.new(ActiveManageable::Base) do
              manageable :index, model_class: Album
            end

            stub_const("TestClass", test_class)
          end

          it "sets the :current_method variable" do
            tc = TestClass.new
            tc.index
            expect(tc.current_method).to eq(:index)
          end

          describe "#search" do
            context "without :search option" do
              it "sets the :ransack variable" do
                tc = TestClass.new
                tc.instance_variable_set(:@ransack, nil)
                tc.index
                expect(tc.ransack).to be_a(Ransack::Search)
              end

              it "returns all records" do
                expect(TestClass.new.index).to match_array(Album.all)
              end
            end

            context "with :search option" do
              it "sets the :ransack variable" do
                tc = TestClass.new
                tc.instance_variable_set(:@ransack, nil)
                search = {search: {genre_eq: Album.genres[:rock], s: "name ASC"}}
                tc.index(options: search)
                expect(tc.ransack).to be_a(Ransack::Search)
              end

              it "returns records filtered by the :search option" do
                collection = TestClass.new.index(options: {search: {genre_eq: Album.genres[:rock]}})
                expect(collection).to match_array(Album.rock)
              end
            end
          end

          describe "#order" do
            before do
              test_class = Class.new(ActiveManageable::Base) do
                manageable :index, model_class: Album
                default_order "name DESC"
              end

              stub_const("TestClass", test_class)
            end

            context "without :search option" do
              it "returns records in database order" do
                TestClass.default_order nil
                expect(TestClass.new.index.map(&:id)).to eq(Album.ids)
              end

              it "returns records ordered by :order option" do
                albums = Album.all.sort_by(&:name)
                expect(TestClass.new.index(options: {order: :name}).map(&:id)).to eq(albums.map(&:id))
              end

              it "returns records ordered by class default order" do
                albums = Album.all.sort_by(&:name).reverse
                expect(TestClass.new.index.map(&:id)).to eq(albums.map(&:id))
              end
            end

            context "with :search option excluding :s sorts key" do
              it "returns records in database order" do
                TestClass.default_order nil
                expect(TestClass.new.index.map(&:id)).to eq(Album.ids)
              end

              it "returns records ordered by :order option" do
                albums = Album.rock.sort_by(&:name)
                expect(TestClass.new.index(options: {search: {genre_eq: Album.genres[:rock]}, order: :name}).map(&:id)).to eq(albums.map(&:id))
              end

              it "returns records ordered by class default order" do
                albums = Album.rock.sort_by(&:name).reverse
                expect(TestClass.new.index(options: {search: {genre_eq: Album.genres[:rock]}}).map(&:id)).to eq(albums.map(&:id))
              end
            end

            context "with :search option including :s sorts key" do
              it "returns records ordered by the :search option :s sorts value" do
                albums = Album.rock.sort_by(&:name)
                expect(TestClass.new.index(options: {search: {genre_eq: Album.genres[:rock], s: "name ASC"}}).map(&:id)).to eq(albums.map(&:id))
              end
            end
          end
        end

        context "when using the kaminari pagination library" do
          before do
            Kaminari.config.default_per_page = 10
            ActiveManageable.configuration.pagination_library = :kaminari
            test_class = Class.new(ActiveManageable::Base) do
              manageable :index, model_class: Album
            end

            stub_const("TestClass", test_class)
          end

          describe ".default_page_size" do
            it "sets the defaults attribute :page key :size value" do
              TestClass.default_page_size 8
              expect(TestClass.defaults[:page][:size]).to eq(8)
            end

            it "sets the defaults attribute :page key :size value to an integer" do
              TestClass.default_page_size "9"
              expect(TestClass.defaults[:page][:size]).to eq(9)
            end
          end

          describe "#page" do
            context "without :page option" do
              context "without a class default page size"
              it "returns first page and number of records using the kaminari :default_per_page" do
                expect(TestClass.new.index).to match_array(Album.limit(Kaminari.config.default_per_page))
              end

              context "with a class :default_page_size" do
                it "returns first page and number of records using the class default page size" do
                  TestClass.default_page_size 5
                  expect(TestClass.new.index).to match_array(Album.limit(5))
                end
              end
            end

            context "with :page option" do
              it "returns records using the :page option :number and kaminari :default_per_page" do
                collection = TestClass.new.index(options: {page: {number: 2}})
                expect(collection).to match_array(Album.offset(Kaminari.config.default_per_page).limit(Kaminari.config.default_per_page))
              end

              it "returns first page of records using the :page option :size value" do
                collection = TestClass.new.index(options: {page: {size: 5}})
                expect(collection).to match_array(Album.limit(5))
              end

              it "returns records using the :page option :number and :size values" do
                collection = TestClass.new.index(options: {page: {number: 2, size: 5}})
                expect(collection).to match_array(Album.offset(5).limit(5))
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

          it "returns records using a combination of the pundit authorization_scope, ransack :search option and kaminari :page option" do
            artist = Artist.find_by(name: "New Order")
            ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :read, album_genre: :electronic)
            collection = TestClass.new.index(options: {search: {artist_id_eq: artist.id, s: "name DESC"}, page: {number: 2, size: 2}})
            expect(collection).to match_array(Album.where(artist_id: artist.id).electronic.order("name DESC").offset(2).limit(2))
          end

          it "returns records using a combination of the pundit authorization_scope, ransack :search option, kaminari :page option and :order, :scopes, :includes & :select options" do
            artist = Artist.find_by(name: "New Order")
            ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :read, album_genre: :electronic)
            collection = TestClass.new.index(options: {search: {artist_id_eq: artist.id}, page: {number: 2, size: 2}, order: "name DESC", scopes: [:released_in_1980s], includes: :songs, select: [:id, :name, :released_at, :genre]})
            expect(collection).to match_array(Album.where(artist_id: artist.id).electronic.released_in_1980s.order("name DESC").offset(2).limit(2))
            expect(collection.first.songs).to be_loaded
            expect(collection.first.attributes.keys.sort).to eq([:id, :name, :released_at, :genre].map(&:to_s).sort)
          end

          context "when the :options contain string keys and values" do
            it "returns records using a combination of the pundit authorization_scope, ransack :search option, kaminari :page option and :order, :scopes, :includes & :select options" do
              artist = Artist.find_by(name: "New Order")
              ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :read, album_genre: :electronic)
              collection = TestClass.new.index(options: {"search" => {"artist_id_eq" => artist.id.to_s}, "page" => {"number" => "2", "size" => "2"}, "order" => "name DESC", "scopes" => ["released_in_1980s"], "includes" => "songs", "select" => ["id", "name", "released_at", "genre"]})
              expect(collection).to match_array(Album.where(artist_id: artist.id).electronic.released_in_1980s.order("name DESC").offset(2).limit(2))
              expect(collection.first.songs).to be_loaded
              expect(collection.first.attributes.keys.sort).to eq([:id, :name, :released_at, :genre].map(&:to_s).sort)
            end
          end
        end

        context "when overriding the instance methods and calling super" do
          before do
            ActiveManageable.configuration.authorization_library = :pundit
            ActiveManageable.configuration.search_library = :ransack
            ActiveManageable.configuration.pagination_library = :kaminari
            test_class = Class.new(ActiveManageable::Base) do
              manageable :index, model_class: Album

              def index(options: {})
                super
              end

              def authorize(record:, action: nil)
                super
              end

              def search(opts)
                super
              end

              def order(attributes)
                super
              end

              def scopes(scopes)
                super
              end

              def page(opts)
                super
              end

              def includes(opts)
                super
              end

              def select(attributes)
                super
              end
            end

            stub_const("TestClass", test_class)
          end

          it "returns records using a combination of the pundit authorization_scope, ransack :search option, kaminari :page option and :order, :scopes, :includes & :select options" do
            artist = Artist.find_by(name: "New Order")
            ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :read, album_genre: :electronic)
            collection = TestClass.new.index(options: {search: {artist_id_eq: artist.id}, page: {number: 2, size: 2}, order: "name DESC", scopes: [:released_in_1980s], includes: :songs, select: [:id, :name, :released_at, :genre]})
            expect(collection).to match_array(Album.where(artist_id: artist.id).electronic.released_in_1980s.order("name DESC").offset(2).limit(2))
            expect(collection.first.songs).to be_loaded
            expect(collection.first.attributes.keys.sort).to eq([:id, :name, :released_at, :genre].map(&:to_s).sort)
          end

          context "when the current_user has no permissions" do
            it "raises Pundit::NotAuthorizedError error" do
              ActiveManageable.current_user = FactoryBot.create(:user, permission_type: :none, album_genre: :all)
              expect { TestClass.new.index }.to raise_error(Pundit::NotAuthorizedError)
            end
          end
        end

        context "when a block is given" do
          it "yields with no arguments" do
            expect { |b| TestClass.new.index(&b) }.to yield_with_no_args
          end

          it "yields to a block that alters the collection attribute" do
            tc = TestClass.new
            artist = Artist.find_by(name: "New Order")
            result = tc.index do
              tc.collection = tc.collection.where(artist_id: artist.id)
            end
            expect(result).to match_array(Album.where(artist_id: artist.id))
          end
        end
      end
    end
  end
end
