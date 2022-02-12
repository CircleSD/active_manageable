# frozen_string_literal: true

require "rails_helper"

RSpec.describe AlbumsController, type: :controller do
  let(:album) { create(:album) }

  before do
    ActiveManageable.current_user = create(:user, permission_type: :manage, album_genre: :all)
  end

  describe "GET #index" do
    it "renders the index page" do
      # exercise
      get :index
      # verify
      expect(response).to have_http_status(:ok)
    end

    it "sets the users and ransack variables" do
      # exercise
      get :index
      # verify
      expect(assigns(:albums)).to be_a(ActiveRecord::Relation)
      expect(assigns(:ransack)).to be_a(Ransack::Search)
    end
  end

  describe "GET #new" do
    it "renders the new page" do
      # exercise
      get :new
      # verify
      expect(response).to have_http_status(:ok)
    end

    it "builds a new album with default attributes" do
      # exercise
      get :new
      # verify
      expect(assigns(:album).genre).to eq("electronic")
      expect(assigns(:album).published_at).to eq(Date.current)
    end
  end

  describe "POST #create" do
    it "creates a new album and redirects to the show page" do
      # exercise
      post :create, params: {album: {name: "Blue Lines"}}
      # verify
      added_album = Album.find_by(name: "Blue Lines")
      expect(added_album).to be_present
      expect(response).to have_http_status(:found)
      expect(response).to redirect_to album_url(id: added_album.id)
    end

    it "creates a new album with default attributes" do
      # exercise
      post :create, params: {album: {name: "Blue Lines"}}
      # verify
      added_album = Album.find_by(name: "Blue Lines")
      expect(added_album).to be_present
      expect(added_album.genre).to eq("electronic")
      expect(added_album.published_at).to eq(Date.current)
    end

    context "when the locale is en-GB" do
      it "creates a new album with datetime attribute in day/month/year format" do
        # exercise
        I18n.with_locale(:"en-GB") do
          post :create, params: {album: {name: "Blue Lines", released_at: "12/02/2022"}}
        end
        # verify
        added_album = Album.find_by(name: "Blue Lines")
        expect(added_album).to be_present
        expect(added_album.released_at).to eq(Date.new(2022, 2, 12))
      end

      it "creates a new album with numeric attribute containing point separator" do
        # exercise
        I18n.with_locale(:"en-GB") do
          post :create, params: {album: {name: "Blue Lines", length: "45.23"}}
        end
        # verify
        added_album = Album.find_by(name: "Blue Lines")
        expect(added_album).to be_present
        expect(added_album.length).to eq(BigDecimal("45.23"))
      end
    end

    context "when the locale is en-US" do
      it "creates a new album with datetime attribute in month/day/year format" do
        # exercise
        I18n.with_locale(:"en-US") do
          post :create, params: {album: {name: "Blue Lines", released_at: "12/02/2022"}}
        end
        # verify
        added_album = Album.find_by(name: "Blue Lines")
        expect(added_album).to be_present
        expect(added_album.released_at).to eq(Date.new(2022, 12, 2))
      end
    end

    context "when the locale is nl" do
      it "creates a new album with numeric attribute containing comma separator" do
        # exercise
        I18n.with_locale(:nl) do
          post :create, params: {album: {name: "Blue Lines", length: "45,23"}}
        end
        # verify
        added_album = Album.find_by(name: "Blue Lines")
        expect(added_album).to be_present
        expect(added_album.length).to eq(BigDecimal("45.23"))
      end
    end
  end

  describe "GET #edit" do
    it "renders the edit page" do
      # exercise
      get :edit, params: {id: album.id}
      # verify
      expect(response).to have_http_status(:ok)
    end
  end

  describe "PATCH #update" do
    it "updates an album and redirects to the show page" do
      # exercise
      patch :update, params: {id: album.id, album: {name: "Mezzanine"}}
      # verify
      updated_album = Album.find(album.id)
      expect(updated_album.name).to eq("Mezzanine")
      expect(response).to redirect_to album_url(id: updated_album.id)
    end

    context "when the locale is en-GB" do
      it "updates an album with datetime attribute in day/month/year format" do
        # exercise
        I18n.with_locale(:"en-GB") do
          patch :update, params: {id: album.id, album: {released_at: "12/02/2022"}}
        end
        # verify
        updated_album = Album.find(album.id)
        expect(updated_album.released_at).to eq(Date.new(2022, 2, 12))
      end

      it "updates an album with numeric attribute containing point separator" do
        # exercise
        I18n.with_locale(:"en-GB") do
          patch :update, params: {id: album.id, album: {length: "45.23"}}
        end
        # verify
        updated_album = Album.find(album.id)
        expect(updated_album.length).to eq(BigDecimal("45.23"))
      end
    end

    context "when the locale is en-US" do
      it "updates an album with datetime attribute in month/day/year format" do
        # exercise
        I18n.with_locale(:"en-US") do
          patch :update, params: {id: album.id, album: {released_at: "12/02/2022"}}
        end
        # verify
        updated_album = Album.find(album.id)
        expect(updated_album.released_at).to eq(Date.new(2022, 12, 2))
      end
    end

    context "when the locale is nl" do
      it "updates an album with numeric attribute containing comma separator" do
        # exercise
        I18n.with_locale(:nl) do
          patch :update, params: {id: album.id, album: {length: "45,23"}}
        end
        # verify
        updated_album = Album.find(album.id)
        expect(updated_album.length).to eq(BigDecimal("45.23"))
      end
    end
  end

  describe "DELETE #destroy" do
    it "deletes an album and redirects to the index page" do
      # exercise
      delete :destroy, params: {id: album.id}
      # verify
      expect(Album.find_by(id: album.id)).to be_nil
      expect(response).to redirect_to albums_path
    end
  end
end
