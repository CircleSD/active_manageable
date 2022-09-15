RSpec.shared_examples "default_includes" do |method|
  describe ".default_includes" do
    before do
      test_class = Class.new(ActiveManageable::Base) do
        manageable method, model_class: Album
      end

      stub_const("TestClass", test_class)
    end

    context "when called with a single association" do
      it "sets the defaults attribute :includes value for :all methods using the configuration :default_loading_method" do
        TestClass.default_includes :songs
        expect(TestClass.defaults[:includes]).to eq({all: {associations: [:songs], loading_method: :includes}})
      end
    end

    context "when called with multiple associations" do
      it "sets the defaults attribute :includes value for :all methods using the configuration :default_loading_method" do
        ActiveManageable.configuration.default_loading_method = :preload
        TestClass.default_includes :songs, :artist
        expect(TestClass.defaults[:includes]).to eq({all: {associations: [:songs, :artist], loading_method: :preload}})
      end
    end

    context "when called with an array & hash of associations" do
      it "sets the defaults attribute :includes value for :all methods using the configuration :default_loading_method" do
        ActiveManageable.configuration.default_loading_method = :preload
        TestClass.default_includes :artist, songs: :artist
        expect(TestClass.defaults[:includes]).to eq({all: {associations: [:artist, {songs: :artist}], loading_method: :preload}})
      end
    end

    context "when called with a hash of associations" do
      it "sets the defaults attribute :includes value for :all methods using the configuration :default_loading_method" do
        ActiveManageable.configuration.default_loading_method = :preload
        TestClass.default_includes songs: :artist
        expect(TestClass.defaults[:includes]).to eq({all: {associations: [{songs: :artist}], loading_method: :preload}})
      end
    end

    context "when called with multiple associations and :loading_method option" do
      it "sets the defaults attribute :includes value for :all methods using the :loading_method option" do
        TestClass.default_includes :songs, :artist, loading_method: :preload
        expect(TestClass.defaults[:includes]).to eq({all: {associations: [:songs, :artist], loading_method: :preload}})
      end
    end

    context "when called with an array & hash of associations and :loading_method option" do
      it "sets the defaults attribute :includes value for :all methods using the :loading_method option" do
        TestClass.default_includes :artist, {songs: :artist}, loading_method: :preload
        expect(TestClass.defaults[:includes]).to eq({all: {associations: [:artist, {songs: :artist}], loading_method: :preload}})
      end
    end

    context "when called with a hash of associations and :loading_method option" do
      it "sets the defaults attribute :includes value for :all methods using the :loading_method option" do
        TestClass.default_includes songs: :artist, loading_method: :preload
        expect(TestClass.defaults[:includes]).to eq({all: {associations: [{songs: :artist}], loading_method: :preload}})
      end
    end

    context "when called with associations and :methods option" do
      it "sets the defaults attribute :includes value for the method using the configuration :default_loading_method" do
        TestClass.default_includes :songs, :artist, methods: :index
        expect(TestClass.defaults[:includes]).to eq({index: {associations: [:songs, :artist], loading_method: :includes}})
      end

      it "sets the defaults attribute :includes value for the methods using the configuration :default_loading_method" do
        TestClass.default_includes :songs, :artist, methods: :index
        TestClass.default_includes :songs, methods: [:show, :edit]
        expect(TestClass.defaults[:includes]).to eq({index: {associations: [:songs, :artist], loading_method: :includes}, show: {associations: [:songs], loading_method: :includes}, edit: {associations: [:songs], loading_method: :includes}})
      end

      it "converts the methods to symbols" do
        TestClass.default_includes :songs, :artist, methods: "index"
        TestClass.default_includes :songs, methods: "edit"
        expect(TestClass.defaults[:includes]).to eq({index: {associations: [:songs, :artist], loading_method: :includes}, edit: {associations: [:songs], loading_method: :includes}})
      end
    end

    context "when called with an array & hash of associations and :methods option" do
      it "sets the defaults attribute :includes value for the method using the configuration :default_loading_method" do
        TestClass.default_includes :artist, {songs: :artist}, methods: :index
        expect(TestClass.defaults[:includes]).to eq({index: {associations: [:artist, {songs: :artist}], loading_method: :includes}})
      end
    end

    context "when called a hash of associations and :methods option" do
      it "sets the defaults attribute :includes value for the method using the configuration :default_loading_method" do
        TestClass.default_includes songs: :artist, methods: :index
        expect(TestClass.defaults[:includes]).to eq({index: {associations: [{songs: :artist}], loading_method: :includes}})
      end
    end

    context "when called with associations and :loading_method & :methods options" do
      it "sets the defaults attribute :includes value for the method using the :loading_method option" do
        TestClass.default_includes :songs, methods: :index, loading_method: :preload
        expect(TestClass.defaults[:includes]).to eq({index: {associations: [:songs], loading_method: :preload}})
      end

      it "sets the defaults attribute :includes value for the methods using the :loading_method option" do
        TestClass.default_includes :songs, loading_method: :preload, methods: [:index, :show]
        expect(TestClass.defaults[:includes]).to eq({index: {associations: [:songs], loading_method: :preload}, show: {associations: [:songs], loading_method: :preload}})
      end

      it "converts the methods to symbols" do
        TestClass.default_includes :songs, :artist, methods: "index", loading_method: :preload
        TestClass.default_includes :songs, loading_method: :eager_load, methods: "show"
        expect(TestClass.defaults[:includes]).to eq({index: {associations: [:songs, :artist], loading_method: :preload}, show: {associations: [:songs], loading_method: :eager_load}})
      end
    end

    context "when called with an array & hash of associations and :loading_method & :methods options" do
      it "sets the defaults attribute :includes value for the method using the :loading_method option" do
        TestClass.default_includes :artist, {songs: :artist}, loading_method: :preload, methods: :index
        expect(TestClass.defaults[:includes]).to eq({index: {associations: [:artist, {songs: :artist}], loading_method: :preload}})
      end
    end

    context "when called with a hash of associations and :loading_method & :methods options" do
      it "sets the defaults attribute :includes value for the method using the :loading_method option" do
        TestClass.default_includes songs: :artist, loading_method: :preload, methods: :index
        expect(TestClass.defaults[:includes]).to eq({index: {associations: [{songs: :artist}], loading_method: :preload}})
      end
    end

    context "when called with a lambda" do
      it "sets the defaults attribute :includes value for :all methods using the configuration :default_loading_method" do
        lambda = -> { includes_associations }
        TestClass.default_includes lambda
        expect(TestClass.defaults[:includes]).to eq({all: {associations: lambda, loading_method: :includes}})
      end
    end

    context "when called with a proc" do
      it "sets the defaults attribute :includes value for :all methods using the configuration :default_loading_method" do
        prc = proc { includes_associations }
        TestClass.default_includes prc
        expect(TestClass.defaults[:includes]).to eq({all: {associations: prc, loading_method: :includes}})
      end
    end

    context "when called with a lambda and :methods option" do
      it "sets the defaults attribute :includes value for the method using the configuration :default_loading_method" do
        lambda = -> { includes_associations }
        TestClass.default_includes lambda, methods: :index
        expect(TestClass.defaults[:includes]).to eq({index: {associations: lambda, loading_method: :includes}})
      end

      it "sets the defaults attribute :includes value for the methods using the configuration :default_loading_method" do
        lambda = -> { includes_associations }
        TestClass.default_includes lambda, methods: [:show, :edit]
        expect(TestClass.defaults[:includes]).to eq({show: {associations: lambda, loading_method: :includes}, edit: {associations: lambda, loading_method: :includes}})
      end

      it "converts the methods to symbols" do
        lambda1 = -> { includes_associations }
        lambda2 = -> { includes_associations }
        TestClass.default_includes lambda1, methods: "index"
        TestClass.default_includes lambda2, methods: "edit"
        expect(TestClass.defaults[:includes]).to eq({index: {associations: lambda1, loading_method: :includes}, edit: {associations: lambda2, loading_method: :includes}})
      end
    end

    context "when called a lambda and :loading_method & :methods options" do
      it "sets the defaults attribute :includes value for the method using the :loading_method option" do
        lambda = -> { includes_associations }
        TestClass.default_includes lambda, methods: :index, loading_method: :preload
        expect(TestClass.defaults[:includes]).to eq({index: {associations: lambda, loading_method: :preload}})
      end

      it "sets the defaults attribute :includes value for the methods using the :loading_method option" do
        lambda = -> { includes_associations }
        TestClass.default_includes lambda, methods: [:index, :show], loading_method: :preload
        expect(TestClass.defaults[:includes]).to eq({index: {associations: lambda, loading_method: :preload}, show: {associations: lambda, loading_method: :preload}})
      end

      it "converts the methods to symbols" do
        lambda1 = -> { includes_associations }
        lambda2 = -> { includes_associations }
        TestClass.default_includes lambda1, methods: "index", loading_method: :preload
        TestClass.default_includes lambda2, loading_method: :eager_load, methods: "show"
        expect(TestClass.defaults[:includes]).to eq({index: {associations: lambda1, loading_method: :preload}, show: {associations: lambda2, loading_method: :eager_load}})
      end
    end
  end

  describe "#default_includes" do
    before do
      test_class = Class.new(ActiveManageable::Base) do
        manageable method, model_class: Album

        def includes_associations
          [:artist, {songs: :artist}]
        end
      end

      stub_const("TestClass", test_class)
    end

    context "when the default includes has not been set" do
      it "returns nil" do
        tc = TestClass.new
        expect(tc.default_includes).to be_nil
      end
    end

    context "when the default includes is set for all methods" do
      before do
        TestClass.default_includes :songs
      end

      context "without a method argument" do
        it "returns an array containing the associations" do
          tc = TestClass.new
          expect(tc.default_includes).to eq([:songs])
        end
      end

      context "with a method argument" do
        it "returns an array containing the associations" do
          tc = TestClass.new
          expect(tc.default_includes(method: :index)).to eq([:songs])
        end
      end
    end

    context "when the default includes is set for selected methods" do
      before do
        TestClass.default_includes :songs, :artist, methods: :index
      end

      context "without a method argument" do
        it "returns nil" do
          tc = TestClass.new
          expect(tc.default_includes).to be_nil
        end
      end

      context "with an argument for a method with default includes" do
        it "returns an array containing the associations" do
          tc = TestClass.new
          expect(tc.default_includes(method: :index)).to eq([:songs, :artist])
        end
      end

      context "with an argument for a method without default includes" do
        it "returns nil" do
          tc = TestClass.new
          expect(tc.default_includes(method: :show)).to be_nil
        end
      end

      context "with a string argument for a method with default includes" do
        it "returns an array containing the associations" do
          tc = TestClass.new
          expect(tc.default_includes(method: "index")).to eq([:songs, :artist])
        end
      end

      context "with a string argument for a method without default includes" do
        it "returns nil" do
          tc = TestClass.new
          expect(tc.default_includes(method: "show")).to be_nil
        end
      end
    end

    context "when the default includes is set with a proc and :loading_method & :methods options" do
      before do
        prc = proc { includes_associations }
        TestClass.default_includes prc, loading_method: :eager_load, methods: [:index, :show]
      end

      context "without a method argument" do
        it "returns nil" do
          tc = TestClass.new
          expect(tc.default_includes).to be_nil
        end
      end

      context "with an argument for a method with default includes" do
        it "returns an array containing the associations" do
          tc = TestClass.new
          expect(tc.default_includes(method: :index)).to eq([:artist, {songs: :artist}])
        end
      end

      context "with an argument for a method without default includes" do
        it "returns nil" do
          tc = TestClass.new
          expect(tc.default_includes(method: :edit)).to be_nil
        end
      end
    end
  end

  describe "#default_loading_method" do
    before do
      test_class = Class.new(ActiveManageable::Base) do
        manageable method, model_class: Album

        def includes_associations
          [:artist, {songs: :artist}]
        end
      end

      stub_const("TestClass", test_class)
    end

    context "when the default includes has not been set" do
      it "returns the configuration :default_loading_method" do
        tc = TestClass.new
        expect(tc.default_loading_method).to eq(:includes)
      end
    end

    context "when the default includes is set for all methods without the :loading_method" do
      before do
        TestClass.default_includes :songs
      end

      context "without a method argument" do
        it "returns the configuration :default_loading_method" do
          tc = TestClass.new
          expect(tc.default_loading_method).to eq(:includes)
        end
      end

      context "with a method argument" do
        it "returns the configuration :default_loading_method" do
          tc = TestClass.new
          expect(tc.default_loading_method(method: :index)).to eq(:includes)
        end
      end
    end

    context "when the default includes is set for all methods with the :loading_method" do
      before do
        TestClass.default_includes :songs, loading_method: :preload
      end

      context "without a method argument" do
        it "returns the option :loading_method" do
          tc = TestClass.new
          expect(tc.default_loading_method).to eq(:preload)
        end
      end

      context "with a method argument" do
        it "returns the option :loading_method" do
          tc = TestClass.new
          expect(tc.default_loading_method(method: :index)).to eq(:preload)
        end
      end
    end

    context "when the default includes is set for selected methods without the :loading_method" do
      before do
        TestClass.default_includes :songs, :artist, methods: :index
      end

      context "without a method argument" do
        it "returns the configuration :default_loading_method" do
          tc = TestClass.new
          expect(tc.default_loading_method).to eq(:includes)
        end
      end

      context "with an argument for a method with default includes" do
        it "returns the configuration :default_loading_method" do
          tc = TestClass.new
          expect(tc.default_loading_method(method: :index)).to eq(:includes)
        end
      end

      context "with an argument for a method without default includes" do
        it "returns the configuration :default_loading_method" do
          tc = TestClass.new
          expect(tc.default_loading_method(method: :show)).to eq(:includes)
        end
      end
    end

    context "when the default includes is set for selected methods with the :loading_method" do
      before do
        TestClass.default_includes :songs, :artist, methods: :index, loading_method: :preload
      end

      context "without a method argument" do
        it "returns the configuration :default_loading_method" do
          tc = TestClass.new
          expect(tc.default_loading_method).to eq(:includes)
        end
      end

      context "with an argument for a method with default includes" do
        it "returns the option :loading_method" do
          tc = TestClass.new
          expect(tc.default_loading_method(method: :index)).to eq(:preload)
        end
      end

      context "with an argument for a method without default includes" do
        it "returns the configuration :default_loading_method" do
          tc = TestClass.new
          expect(tc.default_loading_method(method: :show)).to eq(:includes)
        end
      end

      context "with a string argument for a method with default includes" do
        it "returns the option :loading_method" do
          tc = TestClass.new
          expect(tc.default_loading_method(method: "index")).to eq(:preload)
        end
      end

      context "with a string argument for a method without default includes" do
        it "returns the configuration :default_loading_method" do
          tc = TestClass.new
          expect(tc.default_loading_method(method: "show")).to eq(:includes)
        end
      end
    end
  end
end
