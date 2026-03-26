# frozen_string_literal: true

namespace :db do
  desc 'Set Channel Data'
  task set_channel_data: :environment do
    begin
      server_rules = JSON.parse(ENV.fetch('RULES', '{}'))
      information = JSON.parse(ENV.fetch('INFORMATION', '{}'))
      channel_type = ENV.fetch('CHANNEL_TYPE', nil)

      server_rules.each_value do |rule|
        Rule.find_or_create_by(text: rule) do |r|
          r.hint = rule
        end
      end

      formatted_info = information.values.pluck('text').join("\n")
      Setting.site_extended_description = formatted_info

      Setting.registrations_mode = ENV.fetch('REGISTRATION_MODE', 'none')

      Setting.site_contact_email = ENV.fetch('SITE_CONTACT_EMAIL', nil)

      admin_role = UserRole.find_by(name: 'Admin')
      admin_user = User.find_by(role: admin_role)
      admin_account = admin_user&.account

      Setting.site_contact_username = admin_account&.username

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
