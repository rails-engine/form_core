# frozen_string_literal: true

class ApplicationPresenter < SimpleDelegator
  def initialize(model, view, options = {})
    super(model)

    @model = model
    @view = view
    @options = options
  end
end
