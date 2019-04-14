# frozen_string_literal: true

module Fields
  module Fake
    extend ActiveSupport::Concern

    module ClassMethods
      def configure_fake_options_to(_field); end
    end
  end
end
