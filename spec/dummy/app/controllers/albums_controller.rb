class AlbumsController < ApplicationController
  # GET /albums
  def index
    @albums = manager.index(options: {search: params[:q], page: {number: params[:page]}})
    @ransack = manager.ransack
  end

  # GET /albums/1
  def show
    @album = manager.show(id: params[:id])
  end

  # GET /albums/new
  def new
    @album = manager.new
  end

  # POST /albums
  def create
    result = manager.create(attributes: album_params)
    @album = manager.object

    if result
      redirect_to @album, notice: I18n.t(:msg_album_created)
    else
      render :new
    end
  end

  # GET /albums/1/edit
  def edit
    @album = manager.edit(id: params[:id])
  end

  # PATCH/PUT /albums/1
  def update
    result = manager.update(id: params[:id], attributes: album_params)
    @album = manager.object

    if result
      redirect_to @album, notice: I18n.t(:msg_album_updated)
    else
      render :edit
    end
  end

  # DELETE /albums/1
  def destroy
    result = manager.destroy(id: params[:id])
    @album = manager.object

    if result
      redirect_to albums_url, notice: I18n.t(:msg_album_destroyed)
    else
      render :show
    end
  end

  private

  def album_params
    params.require(:album).permit(:name, :length, :released_at)
  end

  def manager
    @manager ||= AlbumManager.new
  end
end
