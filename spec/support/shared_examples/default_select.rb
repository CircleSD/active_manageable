RSpec.shared_examples ".default_select" do |method|
  describe ".default_select" do
    before do
      test_class = Class.new(ActiveManageable::Base) do
        manageable method, model_class: Album
      end

      stub_const("TestClass", test_class)
    end

    context "when called with a single attribute" do
      it "sets the defaults attribute :select value for :all methods" do
        TestClass.default_select :name
        expect(TestClass.defaults[:select]).to eq({all: [:name]})
      end
    end

    context "when called with an array of attributes" do
      it "sets the defaults attribute :select value for :all methods" do
        TestClass.default_select :id, :name, :released_at
        expect(TestClass.defaults[:select]).to eq({all: [:id, :name, :released_at]})
      end
    end

    context "when called with attributes and :methods option" do
      it "sets the defaults attribute :select value for the method" do
        TestClass.default_select :name, :released_at, methods: :index
        expect(TestClass.defaults[:select]).to eq({index: [:name, :released_at]})
      end

      it "sets the defaults attribute :select value for the methods" do
        TestClass.default_select :name, :released_at, methods: :index
        TestClass.default_select :name, :genre, :released_at, methods: [:show, :edit]
        expect(TestClass.defaults[:select]).to eq({index: [:name, :released_at], show: [:name, :genre, :released_at], edit: [:name, :genre, :released_at]})
      end

      it "converts the methods to symbols" do
        TestClass.default_select :name, :genre, methods: "index"
        TestClass.default_select :name, methods: "edit"
        expect(TestClass.defaults[:select]).to eq({index: [:name, :genre], edit: [:name]})
      end
    end

    context "when called with a lambda" do
      it "sets the defaults attribute :select value for :all methods" do
        lambda = -> { select_attributes }
        TestClass.default_select lambda
        expect(TestClass.defaults[:select]).to eq({all: lambda})
      end
    end

    context "when called with a proc" do
      it "sets the defaults attribute :select value for :all methods" do
        prc = proc { select_attributes }
        TestClass.default_select prc
        expect(TestClass.defaults[:select]).to eq({all: prc})
      end
    end

    context "when called with a lambda and :methods option" do
      it "sets the defaults attribute :select value for the method" do
        lambda = -> { select_attributes }
        TestClass.default_select lambda, methods: :index
        expect(TestClass.defaults[:select]).to eq({index: lambda})
      end

      it "sets the defaults attribute :select value for the methods" do
        lambda = -> { select_attributes }
        TestClass.default_select lambda, methods: [:index, :show]
        expect(TestClass.defaults[:select]).to eq({index: lambda, show: lambda})
      end

      it "converts the methods to symbols" do
        lambda = -> { select_attributes }
        TestClass.default_select lambda, methods: ["index", "show"]
        expect(TestClass.defaults[:select]).to eq({index: lambda, show: lambda})
      end
    end
  end
end
