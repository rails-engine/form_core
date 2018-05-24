# frozen_string_literal: true

class NestedForm < MetalForm
  belongs_to :attachable, polymorphic: true, touch: true
end
