RSpec.shared_examples "#normalize_attributes" do |method|
  describe "#normalize_attributes" do
    before do
      test_class = Class.new(ActiveManageable::Base) do
        manageable method, model_class: Album
      end

      stub_const("TestClass", test_class)
    end

    it "updates the :attributes values for date and datetime attributes to parsed values using Flexitime" do
      tc = TestClass.new
      attributes = {"name" => "Blue Lines", "released_at" => "8-4-91", "published_at" => "26.1.22 14.21"}
      tc.send(method, **args(method, attributes))
      attributes = attributes.with_indifferent_access
      attributes[:released_at] = Date.parse("1991-04-08")
      attributes[:published_at] = Time.zone.parse("2022-01-26 14:21")
      expect(tc.attributes).to be_a(ActiveSupport::HashWithIndifferentAccess)
      expect(tc.attributes).to eq(attributes)
    end

    context "when setting the Flexitime precision" do
      after do
        Flexitime.precision = :min
      end

      it "parses datetime attributes to a precision of :day" do
        Flexitime.precision = :day
        tc = TestClass.new
        attributes = {"name" => "Blue Lines", "published_at" => "2021-08-23T12:35:20.533314Z"}
        tc.send(method, **args(method, attributes))
        attributes = attributes.with_indifferent_access
        attributes[:published_at] = Time.zone.parse("2021-08-23")
        expect(tc.attributes).to be_a(ActiveSupport::HashWithIndifferentAccess)
        expect(tc.attributes).to eq(attributes)
      end

      it "parses datetime attributes to a precision of :hour" do
        Flexitime.precision = :hour
        tc = TestClass.new
        attributes = {"name" => "Blue Lines", "published_at" => "2021-08-23T12:35:20.533314Z"}
        tc.send(method, **args(method, attributes))
        attributes = attributes.with_indifferent_access
        attributes[:published_at] = Time.zone.parse("2021-08-23T12:00Z")
        expect(tc.attributes).to be_a(ActiveSupport::HashWithIndifferentAccess)
        expect(tc.attributes).to eq(attributes)
      end

      it "parses datetime attributes to a precision of :min" do
        Flexitime.precision = :min
        tc = TestClass.new
        attributes = {"name" => "Blue Lines", "published_at" => "2021-08-23T12:35:20.533314Z"}
        tc.send(method, **args(method, attributes))
        attributes = attributes.with_indifferent_access
        attributes[:published_at] = Time.zone.parse("2021-08-23T12:35Z")
        expect(tc.attributes).to be_a(ActiveSupport::HashWithIndifferentAccess)
        expect(tc.attributes).to eq(attributes)
      end

      it "parses datetime attributes to a precision of :sec" do
        Flexitime.precision = :sec
        tc = TestClass.new
        attributes = {"name" => "Blue Lines", "published_at" => "2021-08-23T12:35:20.533314Z"}
        tc.send(method, **args(method, attributes))
        attributes = attributes.with_indifferent_access
        attributes[:published_at] = Time.zone.parse("2021-08-23T12:35:20Z")
        expect(tc.attributes).to be_a(ActiveSupport::HashWithIndifferentAccess)
        expect(tc.attributes).to eq(attributes)
      end

      it "parses datetime attributes to a precision of :usec" do
        Flexitime.precision = :usec
        tc = TestClass.new
        attributes = {"name" => "Blue Lines", "published_at" => "2021-08-23T12:35:20.533314Z"}
        tc.send(method, **args(method, attributes))
        attributes = attributes.with_indifferent_access
        attributes[:published_at] = Time.zone.parse("2021-08-23T12:35:20.533314Z")
        expect(tc.attributes).to be_a(ActiveSupport::HashWithIndifferentAccess)
        expect(tc.attributes).to eq(attributes)
      end
    end

    it "does not update the :attributes values for date and datetime attributes that cannot be parsed" do
      tc = TestClass.new
      attributes = {"name" => "Blue Lines", "released_at" => "", "published_at" => "today"}
      tc.send(method, **args(method, attributes))
      attributes = attributes.with_indifferent_access
      expect(tc.attributes).to be_a(ActiveSupport::HashWithIndifferentAccess)
      expect(tc.attributes).to eq(attributes)
    end

    context "when the decimal separator is a comma" do
      it "updates the :attributes values for decimal and float attributes replacing a decimal comma with a decimal point" do
        tc = TestClass.new
        attributes = {"name" => "Blue Lines", "length" => "45,04"}
        I18n.with_locale(:nl) do
          tc.send(method, **args(method, attributes))
        end
        attributes = attributes.with_indifferent_access
        attributes[:length] = attributes[:length].tr(",", ".")
        expect(tc.attributes).to be_a(ActiveSupport::HashWithIndifferentAccess)
        expect(tc.attributes).to eq(attributes)
      end

      it "does not update the :attributes values for decimal and float attributes that do not contain a decimal separator" do
        tc = TestClass.new
        attributes = {"name" => "Blue Lines", "length" => "45"}
        I18n.with_locale(:nl) do
          tc.send(method, **args(method, attributes))
        end
        attributes = attributes.with_indifferent_access
        expect(tc.attributes).to be_a(ActiveSupport::HashWithIndifferentAccess)
        expect(tc.attributes).to eq(attributes)
      end

      it "does not update the :attributes values for decimal and float attributes that contain a decimal point" do
        tc = TestClass.new
        attributes = {"name" => "Blue Lines", "length" => "45.04"}
        I18n.with_locale(:nl) do
          tc.send(method, **args(method, attributes))
        end
        attributes = attributes.with_indifferent_access
        expect(tc.attributes).to be_a(ActiveSupport::HashWithIndifferentAccess)
        expect(tc.attributes).to eq(attributes)
      end

      it "does not update the :attributes values for decimal and float attributes that contain both decimal points and commas" do
        tc = TestClass.new
        attributes = {"name" => "Blue Lines", "length" => "45,040.45"}
        I18n.with_locale(:nl) do
          tc.send(method, **args(method, attributes))
        end
        attributes = attributes.with_indifferent_access
        expect(tc.attributes).to be_a(ActiveSupport::HashWithIndifferentAccess)
        expect(tc.attributes).to eq(attributes)
      end

      it "does not update the :attributes values for decimal and float attributes that contain multiple decimal commas" do
        tc = TestClass.new
        attributes = {"name" => "Blue Lines", "length" => "45,040,45"}
        I18n.with_locale(:nl) do
          tc.send(method, **args(method, attributes))
        end
        attributes = attributes.with_indifferent_access
        expect(tc.attributes).to be_a(ActiveSupport::HashWithIndifferentAccess)
        expect(tc.attributes).to eq(attributes)
      end
    end

    context "when the decimal separator is a point" do
      it "does not update the :attributes values for decimal and float attributes that contain a decimal point" do
        tc = TestClass.new
        attributes = {"name" => "Blue Lines", "length" => "45.04"}
        tc.send(method, **args(method, attributes))
        attributes = attributes.with_indifferent_access
        expect(tc.attributes).to be_a(ActiveSupport::HashWithIndifferentAccess)
        expect(tc.attributes).to eq(attributes)
      end

      it "does not update the :attributes values for decimal and float attributes that contain a decimal comma" do
        tc = TestClass.new
        attributes = {"name" => "Blue Lines", "length" => "45,04"}
        tc.send(method, **args(method, attributes))
        attributes = attributes.with_indifferent_access
        expect(tc.attributes).to be_a(ActiveSupport::HashWithIndifferentAccess)
        expect(tc.attributes).to eq(attributes)
      end
    end

    it "updates the :attributes values for date, datetime, decimal and float attributes for the model and its associations" do
      tc = TestClass.new
      attributes = {"name" => "Blue Lines", "released_at" => "8-4-91", "length" => "45,04", "published_at" => "26.1.22 14.21", "artist_attributes" => {"name" => "Massive Attack", "published_at" => "26.1.22 14.21"}, "songs_attributes" => [{"name" => "Safe From Harm", "length" => "5,18", "published_at" => "26.1.22 14.21"}, {"name" => "Unfinished Sympathy", "length" => "5,08", "published_at" => "26.1.22 14.21"}]}
      I18n.with_locale(:nl) do
        tc.send(method, **args(method, attributes))
      end
      attributes = attributes.with_indifferent_access
      attributes[:released_at] = Date.parse("1991-04-08")
      attributes[:length] = attributes[:length].tr(",", ".")
      attributes[:published_at] = Time.zone.parse("2022-01-26 14:21")
      attributes[:artist_attributes][:published_at] = Time.zone.parse("2022-01-26 14:21")
      attributes[:songs_attributes].each_with_index do |attrs, i|
        attrs[:length] = attrs[:length].tr(",", ".")
        attrs[:published_at] = Time.zone.parse("2022-01-26 14:21")
      end
      expect(tc.attributes).to be_a(ActiveSupport::HashWithIndifferentAccess)
      expect(tc.attributes).to eq(attributes)
    end

    it "updates :attributes containing non-existant attribute keys" do
      tc = TestClass.new
      attributes = {"name" => "Blue Lines", "published_at" => "26.1.22 14.21", "missing" => "boom?"}
      normalized_attributes = tc.send(:normalize_attributes, attributes)
      attributes = attributes.with_indifferent_access
      attributes[:published_at] = Time.zone.parse("2022-01-26 14:21")
      expect(normalized_attributes).to eq(attributes)
    end

    it "updates :attributes containing non-existant association keys" do
      tc = TestClass.new
      attributes = {"name" => "Blue Lines", "published_at" => "26.1.22 14.21", "artist_attributes" => {"name" => "Massive Attack", "published_at" => "26.1.22 14.21"}, "song_attributes" => {"name" => "Safe From Harm", "published_at" => "26.1.22 14.21"}}
      normalized_attributes = tc.send(:normalize_attributes, attributes)
      attributes = attributes.with_indifferent_access
      attributes[:published_at] = Time.zone.parse("2022-01-26 14:21")
      attributes[:artist_attributes][:published_at] = Time.zone.parse("2022-01-26 14:21")
      expect(normalized_attributes).to eq(attributes)
    end

    def args(method, attributes)
      (method == :update) ? {id: album.id, attributes: attributes} : {attributes: attributes}
    end
  end
end
