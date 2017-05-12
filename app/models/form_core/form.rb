module FormCore
  class Form < ApplicationRecord
    include FormCore::Concerns::Models::Form
  end
end
