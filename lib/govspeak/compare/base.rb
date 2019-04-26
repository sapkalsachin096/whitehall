module Govspeak
  module Compare
    class Base
      def self.csv_header
        %w[id content_id type current_eq_govspeak_6 govspeak_6_valid current_eq_govspeak_5 govspeak_5_valid]
      end

      def self.base_path
        "/tmp/compare/"
      end

      def self.govspeak_6_path
        base_path + "govspeak-6-#{type}.csv"
      end

      def self.govspeak_5_6_path
        base_path + "govspeak-#{type}.csv"
      end

      def self.run
        FileUtils.mkdir_p(base_path + Govspeak::VERSION)

        if Govspeak::VERSION == '6.0.0'
          CSV.open(govspeak_6_path, 'wb') do |csv|
            csv << csv_header

            sampled_ids = ids#.sample(2000)
            bar = ProgressBar.new(sampled_ids.count)
            sampled_ids.each do |id|
              ge = new(id)
              next if ge.nil?

              csv << [id, ge.content_id, ge.model.class, ge.equal?, ge.valid_govspeak, nil, nil]
              ge.write_diff
              bar.increment!
            end
          end
        end

        if Govspeak::VERSION == '5.5.0'
          CSV.open(govspeak_5_6_path, 'wb', headers: true) do |new_csv|
            File.open(govspeak_6_path, 'r') do |file|
              csv = CSV.new(file, headers: true)
              bar = ProgressBar.new(csv.count)
              csv.rewind

              new_csv << csv_header
              while(row = csv.shift)
                ge = new(row['id'].to_i)

                row['current_eq_govspeak_5'] = ge.equal?
                row['govspeak_5_valid'] = ge.valid_govspeak

                new_csv << row
                ge.write_diff
                bar.increment!
              end
            end
          end
        end
      end

      def equal?
        clean_html(rendered_govspeak) == clean_html(current_html)
      end

      def diff
        if Object.const_defined?('Diffy')
          Diffy::Diff.new(rendered_govspeak, current_html, context: 0)
        end
      end

      def write_diff
        if current_html.present? && !equal? && diff.present?
          File.write(self.class.base_path + Govspeak::VERSION + "/#{model.class.to_s.underscore}-#{model.id}.diff", diff)
        end
      end

      def valid_govspeak
        @valid_govspeak ||= Govspeak::HtmlValidator.new(rendered_govspeak).valid?
      end

      def clean_html(html)
        html = html.to_s
        html.gsub!(' rel="external"', '')
        html.gsub!('http://www.dev.gov.uk', 'https://www.gov.uk')
        html.gsub!('http://static.dev.gov.uk', 'https://assets.publishing.service.gov.uk')
        html.gsub!('https://www.integration.publishing.service.gov.uk', 'https://www.gov.uk')
        html.gsub!('https://assets.integration.publishing.service.gov.uk', 'https://assets.publishing.service.gov.uk')

        html.gsub!('href="/government/uploads', 'href="https://assets.publishing.service.gov.uk/government/uploads')

        html.gsub!('<figcaption><p>', '<figcaption>')
        html.gsub!('</p></figcaption>', '</figcaption>')

        html
      end
    end
  end
end
