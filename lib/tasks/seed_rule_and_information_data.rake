# frozen_string_literal: true

namespace :db do
  desc 'Seed rule and information data'
  task seed_rule_and_information_data: :environment do
    begin
      server_rules = JSON.parse(ENV.fetch('RULES', nil))
      information = JSON.parse(ENV.fetch('INFORMATION', nil))

      server_rules.each_value do |rule|
        Rule.create(text: rule, hint: rule)
      end

      information.each_value do |info|
        Setting.create(var: 'site_extended_description', value: info['text'])
      end

      puts 'Seeding completed successfully!'
    rescue JSON::ParserError => e
      puts "Error parsing JSON data: #{e.message}"
    rescue => e
      puts "An error occurred: #{e.message}"
    end
  end
end
