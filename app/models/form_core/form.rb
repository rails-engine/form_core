# frozen_string_literal: true

module FormCore
  class Form < ApplicationRecord
    include FormCore::Concerns::Models::Form
  end
end
