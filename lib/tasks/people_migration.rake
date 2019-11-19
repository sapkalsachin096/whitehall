namespace :people_migration do
  desc "Check content store"
  task check_content_store: :environment do |_task, args|
    Person.find_each do |person|
      person.translations.find_each do |translation|
        base_path = "/government/people/#{person.slug}"
        base_path += ".#{translation.locale}" if translation.locale != :en

        puts "#{base_path}"

        content_item = GdsApi.content_store.content_item(base_path)

        if Whitehall::GovspeakRenderer.new.bare_govspeak_to_html(translation.biography) != content_item["details"]["body"]
          puts "Biography for #{base_path} doesn't match"
        end
      end
    end
  end
end
