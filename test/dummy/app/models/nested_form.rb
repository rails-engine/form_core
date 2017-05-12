class NestedForm < FormCore::Form
  belongs_to :attachable, polymorphic: true, touch: true
end
