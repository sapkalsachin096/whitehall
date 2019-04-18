desc "Compare Govspeak"
task compare_govspeak: :environment  do
  require 'govspeak/compare/attachment'
  require 'govspeak/compare/edition'

  ActiveRecord::Base.logger = ActionController::Base.logger = ActionView::Base.logger = nil
  puts "Govspeak #{Govspeak::VERSION}"
  puts 'Attachments'
  Govspeak::Compare::Attachment.run
  puts 'Editions'
  Govspeak::Compare::Edition.run
end
