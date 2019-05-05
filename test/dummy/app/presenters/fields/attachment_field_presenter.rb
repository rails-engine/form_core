# frozen_string_literal: true

module Fields
  class AttachmentFieldPresenter < FieldPresenter
    def value_for_preview
      id = value
      return if id.blank?

      blob = ActiveStorage::Blob.find_by id: id
      return unless blob

      @view.link_to blob.filename, @view.rails_blob_path(blob, disposition: "attachment")
    end
  end
end
