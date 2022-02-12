RSpec.shared_examples ".default_attribute_values" do |method|
  describe ".default_attribute_values" do
    before do
      test_class = Class.new(ActiveManageable::Base) do
        manageable method, model_class: Album
      end

      stub_const("TestClass", test_class)
    end

    context "when called with a hash containing a single attribute value" do
      it "sets the defaults attribute :attributes value for :all methods" do
        TestClass.default_attribute_values genre: Album.genres[:electronic]
        expect(TestClass.defaults[:attributes]).to eq({all: {genre: Album.genres[:electronic]}})
      end
    end

    context "when called with a hash containing multiple attribute values" do
      it "sets the defaults attribute :attributes value for :all methods" do
        TestClass.default_attribute_values genre: Album.genres[:electronic], released_at: Date.current
        expect(TestClass.defaults[:attributes]).to eq({all: {genre: Album.genres[:electronic], released_at: Date.current}})
      end
    end

    context "when called with a hash containing attribute values and :methods option" do
      it "sets the defaults attribute :attributes value for the method" do
        TestClass.default_attribute_values genre: Album.genres[:electronic], methods: :new
        expect(TestClass.defaults[:attributes]).to eq({new: {genre: Album.genres[:electronic]}})
      end

      it "sets the defaults attribute :attributes value for the methods" do
        TestClass.default_attribute_values genre: Album.genres[:electronic], released_at: Date.current, methods: [:new, :create]
        expect(TestClass.defaults[:attributes]).to eq({new: {genre: Album.genres[:electronic], released_at: Date.current}, create: {genre: Album.genres[:electronic], released_at: Date.current}})
      end

      it "converts the methods to symbols" do
        TestClass.default_attribute_values genre: Album.genres[:electronic], methods: "new"
        TestClass.default_attribute_values genre: Album.genres[:rock], methods: "create"
        expect(TestClass.defaults[:attributes]).to eq({new: {genre: Album.genres[:electronic]}, create: {genre: Album.genres[:rock]}})
      end
    end

    context "when called with a lambda" do
      it "sets the defaults attribute :attributes value for :all methods" do
        lambda = -> { attr_values }
        TestClass.default_attribute_values lambda
        expect(TestClass.defaults[:attributes]).to eq({all: lambda})
      end
    end

    context "when called with a proc" do
      it "sets the defaults attribute :attributes value for :all methods" do
        prc = proc { attr_values }
        TestClass.default_attribute_values prc
        expect(TestClass.defaults[:attributes]).to eq({all: prc})
      end
    end

    context "when called with a lambda and :methods option" do
      it "sets the defaults attribute :attributes value for the method" do
        lambda = -> { attr_values }
        TestClass.default_attribute_values lambda, methods: :new
        expect(TestClass.defaults[:attributes]).to eq({new: lambda})
      end

      it "sets the defaults attribute :attributes value for the methods" do
        lambda = -> { attr_values }
        TestClass.default_attribute_values lambda, methods: [:new, :create]
        expect(TestClass.defaults[:attributes]).to eq({new: lambda, create: lambda})
      end

      it "converts the methods to symbols" do
        lambda = -> { attr_values }
        TestClass.default_attribute_values lambda, methods: ["new", "create"]
        expect(TestClass.defaults[:attributes]).to eq({new: lambda, create: lambda})
      end
    end
  end
end
