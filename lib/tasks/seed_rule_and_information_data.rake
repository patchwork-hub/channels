# frozen_string_literal: true

namespace :db do
  desc 'Seed rule and information data'
  task seed_rule_and_information_data: :environment do
    begin
      server_rules = JSON.parse(ENV.fetch('RULES', nil))
      information = JSON.parse(ENV.fetch('INFORMATION', nil))
      site_contact_email = ENV.fetch('SITE_CONTACT_EMAIL', nil)

      server_rules.each_value do |rule|
        Rule.create(text: rule, hint: rule)
      end

      information.each_value do |info|
        Setting.create(var: 'site_extended_description', value: info['text'])
      end

      Setting.create(var: 'site_contact_email', value: site_contact_email)

      owner_role = UserRole.find_by(name: 'Owner')
      owner_user = User.find_by(role: owner_role)
      owner_account = owner_user&.account
      Setting.create(var: 'site_contact_username', value: owner_account&.username)

      puts 'Seeding completed successfully!'
    rescue JSON::ParserError => e
      puts "Error parsing JSON data: #{e.message}"
    rescue => e
      puts "An error occurred: #{e.message}"
    end
  end
end
