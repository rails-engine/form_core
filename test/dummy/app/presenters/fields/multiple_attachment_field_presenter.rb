# frozen_string_literal: true

module Fields
  class MultipleAttachmentFieldPresenter < FieldPresenter
    def value_for_preview
      ids = value
      return if ids.blank?

      blobs = ActiveStorage::Blob.where(id: ids)
      return if blobs.blank?

      blobs.map do |blob|
        @view.link_to blob.filename, @view.rails_blob_path(blob, disposition: "attachment")
      end.join(", ").html_safe
    end
  end
end
