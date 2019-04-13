# frozen_string_literal: true

module Forms
  module Fake
    extend ActiveSupport::Concern

    def build_random_fields(type_key_seq:)
      transaction(requires_new: true) do
        type_key_seq.each do |type_key|
          if type_key.is_a? Hash
            type_key.each do |k, v|
              klass = Fields::MAP[k]
              unless k.attached_nested_form?
                raise ArgumentError, "Only nested form types can be key"
              end
              field = fields.build type: Fields::MAP[type_key].to_s,
                                   section: sections.first,
                                   accessibility: "read_and_write"
              field.label = "#{klass.model_name.name.demodulize.titleize} #{field.name.to_s.split("_").last}"
              field.save!
              klass.configure_fake_options_to field
              field.save!
              field.nested_form.build_random_fields(v)
              field.save!
            end
          else
            klass = Fields::MAP[type_key]
            unless klass
              raise ArgumentError, "Can't reflect field class by #{type_key}"
            end
            field = fields.build type: Fields::MAP[type_key].to_s,
                                 section: sections.first,
                                 accessibility: "read_and_write"
            field.label = "#{klass.model_name.name.demodulize.titleize} #{field.name.to_s.split("_").last}"
            field.save!
            klass.configure_fake_options_to field
            field.save!
          end
        end
      end
    end

    module ClassMethods
      DEFAULT_TYPE_KEY_SEQ =
        Field.descendants.map(&:type_key) -
          %i[nested_form_field multiple_nested_form_field] -
          %i[attachment_field multiple_attachment_field] -
          %i[resource_select_field multiple_resource_select_field] -
          %i[resource_field multiple_resource_field]
      def create_random_form!(type_key_seq: DEFAULT_TYPE_KEY_SEQ)
        form = create! title: "Random form #{SecureRandom.hex(3)}"
        form.build_random_fields type_key_seq: type_key_seq
        form
      end
    end
  end
end
