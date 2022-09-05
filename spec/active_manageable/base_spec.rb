# frozen_string_literal: true

require "rails_helper"

module ActiveManageable
  RSpec.describe Base do
    before do
      ActiveManageable.configuration = ActiveManageable::Configuration.new
    end

    describe ".defaults" do
      before do
        test_class = Class.new(ActiveManageable::Base) do
          manageable ActiveManageable::ALL_METHODS
        end

        stub_const("TestClass", test_class)
      end

      it "has a default of an empty Hash" do
        expect(TestClass.defaults).to eq({})
      end
    end

    describe ".manageable" do
      context "when including all methods using the ALL_METHODS constant" do
        before do
          test_class = Class.new(ActiveManageable::Base) do
            manageable ActiveManageable::ALL_METHODS
          end

          stub_const("TestClass", test_class)
        end

        it "includes the index method" do
          expect(TestClass.new).to respond_to(:index)
        end

        it "includes the new method" do
          expect(TestClass.new).to respond_to(:new)
        end

        it "includes the create method" do
          expect(TestClass.new).to respond_to(:create)
        end

        it "includes the edit method" do
          expect(TestClass.new).to respond_to(:edit)
        end

        it "includes the update method" do
          expect(TestClass.new).to respond_to(:update)
        end

        it "includes the destroy method" do
          expect(TestClass.new).to respond_to(:destroy)
        end
      end

      context "when including only the index method" do
        before do
          test_class = Class.new(ActiveManageable::Base) do
            manageable :index
          end

          stub_const("TestClass", test_class)
        end

        it "includes the index method" do
          expect(TestClass.new).to respond_to(:index)
        end

        it "does not include the new method" do
          expect(TestClass.new).not_to respond_to(:new)
        end

        it "does not include the create method" do
          expect(TestClass.new).not_to respond_to(:create)
        end

        it "does not include the edit method" do
          expect(TestClass.new).not_to respond_to(:edit)
        end

        it "does not include the update method" do
          expect(TestClass.new).not_to respond_to(:update)
        end

        it "does not include the destroy method" do
          expect(TestClass.new).not_to respond_to(:destroy)
        end
      end

      context "when including only the edit and update methods" do
        before do
          test_class = Class.new(ActiveManageable::Base) do
            manageable :edit, :update
          end

          stub_const("TestClass", test_class)
        end

        it "does not include the index method" do
          expect(TestClass.new).not_to respond_to(:index)
        end

        it "does not include the new method" do
          expect(TestClass.new).not_to respond_to(:new)
        end

        it "does not include the create method" do
          expect(TestClass.new).not_to respond_to(:create)
        end

        it "includes the edit method" do
          expect(TestClass.new).to respond_to(:edit)
        end

        it "includes the update method" do
          expect(TestClass.new).to respond_to(:update)
        end

        it "does not include the destroy method" do
          expect(TestClass.new).not_to respond_to(:destroy)
        end
      end

      context "when not including any methods" do
        before do
          test_class = Class.new(ActiveManageable::Base) do
            manageable
          end

          stub_const("TestClass", test_class)
        end

        it "does not include the index method" do
          expect(TestClass.new).not_to respond_to(:index)
        end

        it "does not include the new method" do
          expect(TestClass.new).not_to respond_to(:new)
        end

        it "does not include the create method" do
          expect(TestClass.new).not_to respond_to(:create)
        end

        it "does not include the edit method" do
          expect(TestClass.new).not_to respond_to(:edit)
        end

        it "does not include the update method" do
          expect(TestClass.new).not_to respond_to(:update)
        end

        it "does not include the destroy method" do
          expect(TestClass.new).not_to respond_to(:destroy)
        end
      end

      context "when specifying the model class" do
        before do
          test_class = Class.new(ActiveManageable::Base)
          stub_const("ArtistManager", test_class)
        end

        it "sets the model_class attribute" do
          ArtistManager.manageable ActiveManageable::ALL_METHODS, model_class: Integer
          expect(ArtistManager.model_class).to eq(Integer)
          expect(ArtistManager.new.model_class).to eq(Integer)
        end
      end

      context "when not specifying the model class" do
        context "when the subclass name ends with the configuration suffix" do
          context "when a constant exists using the subclass name" do
            before do
              test_class = Class.new(ActiveManageable::Base)
              stub_const("ArtistManager", test_class)
            end

            it "sets the model_class attribute based on the subclass name" do
              ArtistManager.manageable ActiveManageable::ALL_METHODS
              expect(ArtistManager.model_class).to eq(Artist)
              expect(ArtistManager.new.model_class).to eq(Artist)
            end
          end

          context "when a constant does not exist using the subclass name" do
            before do
              test_class = Class.new(ActiveManageable::Base)
              stub_const("ArtManager", test_class)
            end

            it "does not set the model_class attribute" do
              ArtManager.manageable ActiveManageable::ALL_METHODS
              expect(ArtManager.model_class).to be_nil
              expect(ArtManager.new.model_class).to be_nil
            end
          end
        end

        context "when the subclass name does not end with the configuration suffix" do
          before do
            test_class = Class.new(ActiveManageable::Base)
            stub_const("ArtistManageable", test_class)
          end

          it "does not set the model_class attribute" do
            ArtistManageable.manageable ActiveManageable::ALL_METHODS
            expect(ArtistManageable.model_class).to be_nil
            expect(ArtistManageable.new.model_class).to be_nil
          end
        end
      end

      context "when there are multiple classes inheriting from ActiveManageable::Base" do
        before do
          first_test_class = Class.new(ActiveManageable::Base) do
            manageable ActiveManageable::ALL_METHODS, model_class: Integer
          end
          second_test_class = Class.new(ActiveManageable::Base) do
            manageable :edit, :update, model_class: Float
          end
          third_test_class = Class.new(ActiveManageable::Base) do
            manageable :destroy
          end

          stub_const("FirstClass", first_test_class)
          stub_const("SecondClass", second_test_class)
          stub_const("ThirdClass", third_test_class)
        end

        context "with the first class" do
          it "includes the index method" do
            expect(FirstClass.new).to respond_to(:index)
          end

          it "includes the new method" do
            expect(FirstClass.new).to respond_to(:new)
          end

          it "includes the create method" do
            expect(FirstClass.new).to respond_to(:create)
          end

          it "includes the edit method" do
            expect(FirstClass.new).to respond_to(:edit)
          end

          it "includes the update method" do
            expect(FirstClass.new).to respond_to(:update)
          end

          it "includes the destroy method" do
            expect(FirstClass.new).to respond_to(:destroy)
          end

          it "sets the model_class attribute" do
            expect(FirstClass.model_class).to eq(Integer)
            expect(FirstClass.new.model_class).to eq(Integer)
          end
        end

        context "with the second class" do
          it "does not include the index method" do
            expect(SecondClass.new).not_to respond_to(:index)
          end

          it "does not include the new method" do
            expect(SecondClass.new).not_to respond_to(:new)
          end

          it "does not include the create method" do
            expect(SecondClass.new).not_to respond_to(:create)
          end

          it "includes the edit method" do
            expect(SecondClass.new).to respond_to(:edit)
          end

          it "includes the update method" do
            expect(SecondClass.new).to respond_to(:update)
          end

          it "does not include the destroy method" do
            expect(SecondClass.new).not_to respond_to(:destroy)
          end

          it "sets the model_class attribute" do
            expect(SecondClass.model_class).to eq(Float)
            expect(SecondClass.new.model_class).to eq(Float)
          end
        end

        context "with the third class" do
          it "does not include the index method" do
            expect(ThirdClass.new).not_to respond_to(:index)
          end

          it "does not include the new method" do
            expect(ThirdClass.new).not_to respond_to(:new)
          end

          it "does not include the create method" do
            expect(ThirdClass.new).not_to respond_to(:create)
          end

          it "does not include the edit method" do
            expect(ThirdClass.new).not_to respond_to(:edit)
          end

          it "does not include the update method" do
            expect(ThirdClass.new).not_to respond_to(:update)
          end

          it "includes the destroy method" do
            expect(ThirdClass.new).to respond_to(:destroy)
          end

          it "does not set the model_class attribute" do
            expect(ThirdClass.model_class).to be_nil
            expect(ThirdClass.new.model_class).to be_nil
          end
        end
      end

      context "when using the pundit authorization library" do
        before do
          ActiveManageable.configuration.authorization_library = :pundit
          test_class = Class.new(ActiveManageable::Base) do
            manageable ActiveManageable::ALL_METHODS
          end

          stub_const("TestClass", test_class)
        end

        it "includes the pundit authorize method" do
          tc = TestClass.new
          expect(tc.method(:authorize).source_location.first).to include("pundit.rb")
        end

        it "includes the pundit scoped_class method" do
          tc = TestClass.new
          expect(tc.method(:scoped_class).source_location.first).to include("pundit.rb")
        end
      end

      context "when using the pundit authorization module" do
        before do
          ActiveManageable.configuration.authorization_library = ActiveManageable::Authorization::Pundit
          test_class = Class.new(ActiveManageable::Base) do
            manageable ActiveManageable::ALL_METHODS
          end

          stub_const("TestClass", test_class)
        end

        it "includes the pundit authorize method" do
          tc = TestClass.new
          expect(tc.method(:authorize).source_location.first).to include("pundit.rb")
        end

        it "includes the pundit scoped_class method" do
          tc = TestClass.new
          expect(tc.method(:scoped_class).source_location.first).to include("pundit.rb")
        end
      end

      context "when using the cancancan authorization library" do
        before do
          ActiveManageable.configuration.authorization_library = :cancancan
          test_class = Class.new(ActiveManageable::Base) do
            manageable ActiveManageable::ALL_METHODS
          end

          stub_const("TestClass", test_class)
        end

        it "includes the cancancan authorize method" do
          tc = TestClass.new
          expect(tc.method(:authorize).source_location.first).to include("cancancan.rb")
        end

        it "includes the cancancan scoped_class method" do
          tc = TestClass.new
          expect(tc.method(:scoped_class).source_location.first).to include("cancancan.rb")
        end
      end

      context "when using the ransack search library" do
        before do
          ActiveManageable.configuration.search_library = :ransack
          test_class = Class.new(ActiveManageable::Base) do
            manageable ActiveManageable::ALL_METHODS
          end

          stub_const("TestClass", test_class)
        end

        it "includes the ransack attribute" do
          expect(TestClass.new).to respond_to(:ransack)
        end

        it "includes the ransack search method" do
          tc = TestClass.new
          expect(tc.method(:search).source_location.first).to include("ransack.rb")
        end
      end

      context "when using the ransack search module" do
        before do
          ActiveManageable.configuration.search_library = ActiveManageable::Search::Ransack
          test_class = Class.new(ActiveManageable::Base) do
            manageable ActiveManageable::ALL_METHODS
          end

          stub_const("TestClass", test_class)
        end

        it "includes the ransack attribute" do
          expect(TestClass.new).to respond_to(:ransack)
        end

        it "includes the ransack search method" do
          tc = TestClass.new
          expect(tc.method(:search).source_location.first).to include("ransack.rb")
        end
      end

      context "when using the kaminari pagination library" do
        before do
          ActiveManageable.configuration.pagination_library = :kaminari
          test_class = Class.new(ActiveManageable::Base) do
            manageable ActiveManageable::ALL_METHODS
          end

          stub_const("TestClass", test_class)
        end

        it "includes the kaminari default_page_size method" do
          expect(TestClass.method(:default_page_size).source_location.first).to include("kaminari.rb")
        end

        it "includes the kaminari page method" do
          tc = TestClass.new
          expect(tc.method(:page).source_location.first).to include("kaminari.rb")
        end
      end

      context "when using the kaminari pagination module" do
        before do
          ActiveManageable.configuration.pagination_library = ActiveManageable::Pagination::Kaminari
          test_class = Class.new(ActiveManageable::Base) do
            manageable ActiveManageable::ALL_METHODS
          end

          stub_const("TestClass", test_class)
        end

        it "includes the kaminari default_page_size method" do
          expect(TestClass.method(:default_page_size).source_location.first).to include("kaminari.rb")
        end

        it "includes the kaminari page method" do
          tc = TestClass.new
          expect(tc.method(:page).source_location.first).to include("kaminari.rb")
        end
      end
    end

    describe ".current_user" do
      before do
        first_test_class = Class.new(ActiveManageable::Base) do
          manageable ActiveManageable::ALL_METHODS, model_class: Integer
        end
        second_test_class = Class.new(ActiveManageable::Base) do
          manageable :edit, :update, model_class: Float
        end

        stub_const("FirstClass", first_test_class)
        stub_const("SecondClass", second_test_class)
      end

      it "sets the current_user attribute for all subclasses" do
        user = FactoryBot.create(:user, name: "John Smith")
        ActiveManageable.current_user = user
        expect(FirstClass.current_user).to eq(user)
        expect(FirstClass.new.current_user).to eq(user)
        expect(SecondClass.current_user).to eq(user)
        expect(SecondClass.new.current_user).to eq(user)
      end

      it "is thread specific as it is stored in a thread-local variable" do
        threads = {
          one: Thread.new {
            sleep(0.005)
            FirstClass.current_user
          },
          two: Thread.new {
            sleep(0.001)
            ActiveManageable.current_user = "Paul"
            FirstClass.current_user
          }
        }
        threads.values.each(&:join)
        expect(threads[:one].value).to be_nil
        expect(threads[:two].value).to eq("Paul")
      end
    end

    describe "#with_current_user" do
      let(:album) { FactoryBot.create(:album, genre: Album.genres[:electronic]) }

      before do
        test_class = Class.new(ActiveManageable::Base) do
          manageable ActiveManageable::ALL_METHODS
        end

        stub_const("TestClass", test_class)
      end

      it "sets the current_user instance attribute and yields the block" do
        current_user = FactoryBot.create(:user, name: "John Smith")
        user = FactoryBot.create(:user, name: "Sarah Smith")
        ActiveManageable.current_user = current_user
        tc = TestClass.new
        expect(tc.current_user).to eq(current_user)
        expect(tc.with_current_user(user) { tc.current_user }).to eq(user)
        expect(tc.current_user).to eq(current_user)
      end

      context "when using the pundit authorization library" do
        before do
          ActiveManageable.configuration.authorization_library = :pundit
          test_class = Class.new(ActiveManageable::Base) do
            manageable :show, model_class: Album
          end

          stub_const("TestClass", test_class)
        end

        it "performs authorization using the argument user" do
          ActiveManageable.current_user = FactoryBot.create(:user, name: "No", permission_type: :none, album_genre: :all)
          user = FactoryBot.create(:user, name: "Yes", permission_type: :manage, album_genre: :all)
          tc = TestClass.new
          expect { tc.show(id: album.id) }.to raise_error(Pundit::NotAuthorizedError)
          expect(tc.with_current_user(user) { tc.show(id: album.id) }).to eq(Album.find(album.id))
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

        it "performs authorization using the argument user" do
          ActiveManageable.current_user = FactoryBot.create(:user, name: "No", permission_type: :none, album_genre: :all)
          user = FactoryBot.create(:user, name: "Yes", permission_type: :manage, album_genre: :all)
          tc = TestClass.new
          expect { tc.show(id: album.id) }.to raise_error(CanCan::AccessDenied)
          expect(tc.with_current_user(user) { tc.show(id: album.id) }).to eq(Album.find(album.id))
        end
      end
    end

    describe "#object" do
      before do
        test_class = Class.new(ActiveManageable::Base) do
          manageable :index
        end

        stub_const("TestClass", test_class)
      end

      it "adds an object alias for the target variable" do
        tc = TestClass.new
        tc.instance_variable_set(:@target, FactoryBot.create(:album))
        expect(tc.object).to eq(tc.target)
      end
    end

    describe "#collection" do
      before do
        test_class = Class.new(ActiveManageable::Base) do
          manageable :show
        end

        stub_const("TestClass", test_class)
      end

      it "adds a collection alias for the target variable" do
        tc = TestClass.new
        tc.instance_variable_set(:@target, FactoryBot.create_list(:album, 2))
        expect(tc.collection).to eq(tc.target)
      end
    end
  end
end
