require 'csv'
require 'diffy'
require 'govspeak/version'
require 'progress_bar'

module Govspeak
  module Compare
    class Edition < Base
      def self.type
        "edition"
      end

      def self.ids
        ::Edition.where(state: ::Edition::PUBLICLY_VISIBLE_STATES + ::Edition::PRE_PUBLICATION_STATES).pluck(:id)
      end

      attr_accessor :model

      def initialize(id)
        @model = ::Edition.find(id)
      end

      def content_id
        model.content_id
      end

      def rendered_govspeak
        @rendered_govspeak ||= Whitehall::GovspeakRenderer.new.govspeak_edition_to_html(model)
      rescue StandardError => e
        e.message
      end

      def current_html
        @current_html ||= Services.publishing_api.
        get_content(model.content_id).parsed_content['details']['body']
      rescue StandardError => e
        e.message
      end
    end
  end
end
