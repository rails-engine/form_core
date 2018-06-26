# frozen_string_literal: true

module FormCore
  module ActiveStorageBridge
    # Provides the class-level DSL for declaring that an Duck Record model has attached blobs.
    module Attached::Macros
      extend ActiveSupport::Concern

      module ClassMethods
        def has_one_attached(name)
          class_eval <<-CODE, __FILE__, __LINE__ + 1
            def #{name}=(attachable)
              blob =
                case attachable
                when ActiveStorage::Blob
                  attachable
                when ActionDispatch::Http::UploadedFile, Rack::Test::UploadedFile
                  ActiveStorage::Blob.create_after_upload! \
                    io: attachable.open,
                    filename: attachable.original_filename,
                    content_type: attachable.content_type
                when Hash
                  ActiveStorage::Blob.create_after_upload!(attachable)
                when String
                  id =
                      begin
                        ActiveStorage.verifier.verify(attachable, purpose: :blob_id)
                      rescue ActiveSupport::MessageVerifier::InvalidSignature
                        attachable
                      end
                  ActiveStorage::Blob.find_by(id: id)
                when Integer
                  ActiveStorage::Blob.find_by(id: attachable)
                else
                  nil
                end
    
              super(blob&.id)
            end
          CODE
        end

        def has_many_attached(name)
          class_eval <<-CODE, __FILE__, __LINE__ + 1
            def #{name}=(attachables)
              blobs = []
              ids = []
              attachables.flatten.collect do |attachable|
                case attachable
                when ActiveStorage::Blob
                  blobs << attachable
                when ActionDispatch::Http::UploadedFile, Rack::Test::UploadedFile
                  blobs << ActiveStorage::Blob.create_after_upload!(
                    io: attachable.open,
                    filename: attachable.original_filename,
                    content_type: attachable.content_type
                  )
                when Hash
                  blobs << ActiveStorage::Blob.create_after_upload!(attachable)
                when String
                  ids << \
                      begin
                        ActiveStorage.verifier.verify(attachable, purpose: :blob_id)
                      rescue ActiveSupport::MessageVerifier::InvalidSignature
                        attachable
                      end
                when Integer
                  ids << attachable
                else
                  nil
                end
              end
    
              super blobs.map(&:id).concat(ActiveStorage::Blob.where(id: ids).pluck(:id))
            end
          CODE
        end
      end
    end
  end
end
