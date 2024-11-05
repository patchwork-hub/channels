# frozen_string_literal: true

namespace :db do
  desc 'Set Channel Data'
  task set_channel_data: :environment do
    begin
      server_rules = JSON.parse(ENV.fetch('RULES', '{}'))
      information = JSON.parse(ENV.fetch('INFORMATION', '{}'))
      site_contact_email = ENV.fetch('SITE_CONTACT_EMAIL', nil)
      content_type = ENV.fetch('CONTENT_TYPE', nil)

      server_rules.each_value do |rule|
        Rule.find_or_create_by(text: rule) do |r|
          r.hint = rule
        end
      end

      information.each_value do |info|
        formatted_text = YAML.dump(info['text']).strip
        Setting.create(var: 'site_extended_description', value: info['text']) unless Setting.where(var: 'site_extended_description', value: formatted_text).exists?
      end

      setting = Setting.find_or_initialize_by(var: 'site_contact_email')
      setting.value = site_contact_email
      setting.save

      owner_role = UserRole.find_by(name: 'Owner')
      owner_user = User.find_by(role: owner_role)
      owner_account = owner_user&.account

      setting = Setting.find_or_initialize_by(var: 'site_contact_username')
      setting.value = owner_account&.username
      setting.save

      is_lock = content_type == 'group_channel'
      Chewy.strategy(:atomic) do
        owner_account.update(locked: is_lock)
      end

      puts 'Seeding completed successfully!'
    rescue JSON::ParserError => e
      puts "Error parsing JSON data: #{e.message}"
    rescue => e
      puts "An error occurred: #{e.message}"
    end
  end
end
