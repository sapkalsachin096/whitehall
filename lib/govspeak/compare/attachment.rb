require 'csv'
require 'diffy'
require 'govspeak/version'
require 'progress_bar'

module Govspeak
  module Compare
    class Attachment < Base
      def self.type
        "attachment"
      end

      def self.ids
        edition_ids ||= ::Edition.where(state: ::Edition::PUBLICLY_VISIBLE_STATES + ::Edition::PRE_PUBLICATION_STATES).pluck(:id)
        #news_article_ids ||= NewsArticle.where(state: Edition::PUBLICLY_VISIBLE_STATES + Edition::PRE_PUBLICATION_STATES).pluck(:id)
        #edition_ids = @news_article_ids
        html_attachment_ids ||= HtmlAttachment.where(attachable_id: edition_ids).pluck(:id)
        GovspeakContent.where(html_attachment_id: html_attachment_ids).pluck(:id)
      end

      attr_accessor :model

      def initialize(id)
        @model = GovspeakContent.find(id)
      end

      def content_id
        model.html_attachment.attachable.try(:content_id)
      end

      def rendered_govspeak
        @rendered_govspeak ||= model.send(:generate_govspeak).to_s
      rescue StandardError => e
        e.message
      end

      def current_html
        model.computed_body_html.to_s
      end
    end
  end
end
