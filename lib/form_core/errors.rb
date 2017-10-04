# frozen_string_literal: true

module FormCore
  # = Form Core Errors
  #
  # Generic Form Core exception class.
  class FormCoreError < StandardError
  end

  class DecodingDataCorrupted < FormCoreError
  end
end
