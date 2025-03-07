# frozen_string_literal: true

namespace :db do
  desc 'Set Channel Data'
  task set_channel_data: :environment do
    begin
      server_rules = JSON.parse(ENV.fetch('RULES', '{}'))
      information = JSON.parse(ENV.fetch('INFORMATION', '{}'))
      site_contact_email = ENV.fetch('SITE_CONTACT_EMAIL', nil)
      channel_type = ENV.fetch('CHANNEL_TYPE', nil)

      server_rules.each_value do |rule|
        Rule.find_or_create_by(text: rule) do |r|
          r.hint = rule
        end
      end

      Setting.where(var: 'site_extended_description').delete_all
      formatted_info = information.values.map { |info| info['text'] }.join("\n")
      Setting.create(var: 'site_extended_description', value: formatted_info)

      setting = Setting.find_or_initialize_by(var: 'site_contact_email')
      setting.value = site_contact_email
      setting.save

      admin_role = UserRole.find_by(name: 'Admin')
      admin_user = User.find_by(role: admin_role)
      admin_account = admin_user&.account

      setting = Setting.find_or_initialize_by(var: 'site_contact_username')
      setting.value = admin_account&.username
      setting.save

      is_lock = channel_type == 'group_channel'
      Chewy.strategy(:atomic) do
        admin_account.update(locked: is_lock)
      end

      puts 'Seeding completed successfully!'
    rescue JSON::ParserError => e
      puts "Error parsing JSON data: #{e.message}"
    rescue => e
      puts "An error occurred: #{e.message}"
    end
  end
end
