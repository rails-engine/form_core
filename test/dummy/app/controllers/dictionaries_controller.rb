class DictionariesController < ApplicationController
  before_action :set_dictionary, only: %i[edit update destroy]

  # GET /dictionaries/dictionaries
  def index
    @dictionaries = Dictionary.all
  end

  # GET /dictionaries/dictionaries/new
  def new
    @dictionary = Dictionary.new
  end

  # GET /dictionaries/dictionaries/1/edit
  def edit
  end

  # POST /dictionaries/dictionaries
  def create
    @dictionary = Dictionary.new(dictionary_params)

    if @dictionary.save
      redirect_to dictionaries_url, notice: "dictionary was successfully created."
    else
      render :new
    end
  end

  # PATCH/PUT /dictionaries/dictionaries/1
  def update
    if @dictionary.update(dictionary_params)
      redirect_to dictionaries_url, notice: "dictionary was successfully updated."
    else
      render :edit
    end
  end

  # DELETE /dictionaries/dictionaries/1
  def destroy
    @dictionary.destroy
    redirect_to dictionaries_url, notice: "dictionary was successfully destroyed."
  end

  private
  # Use callbacks to share common setup or constraints between actions.
  def set_dictionary
    @dictionary = Dictionary.find(params[:id])
  end

  # Only allow a trusted parameter "white list" through.
  def dictionary_params
    params.fetch(:dictionary, {}).permit(:scope, :value)
  end
end
