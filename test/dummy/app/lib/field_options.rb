# frozen_string_literal: true

class FieldOptions < OptionsModel::Base
  include EnumTranslate

  def interpret_to(_model, _field_name, _accessibility, _options = {})
  end
end
