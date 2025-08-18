#!/usr/bin/env ruby
# I18n System Demonstration Script
# This script demonstrates how the I18n system works in the Channels project

# This script would normally be run in a Rails console context
# For demonstration purposes, it shows the concepts

puts "=" * 60
puts "Ruby I18n System Demonstration for Channels Project"
puts "=" * 60
puts

# 1. Basic Translation Lookup
puts "1. Basic Translation Examples:"
puts "-" * 30

# These would work in actual Rails context:
# puts "English: #{I18n.t('accounts.followers.other')}"
# puts "Spanish: #{I18n.with_locale(:es) { I18n.t('accounts.followers.other') }}"

puts "English: Followers"
puts "Spanish: Seguidores"
puts "French: Abonnés"
puts

# 2. Interpolation Examples
puts "2. Translation with Interpolation:"
puts "-" * 35

# These would work in actual Rails context:
# puts "English: #{I18n.t('about.hosted_on', domain: 'example.com')}"
# puts "Spanish: #{I18n.with_locale(:es) { I18n.t('about.hosted_on', domain: 'example.com') }}"

puts "English: Mastodon hosted on example.com"
puts "Spanish: Mastodon alojado en example.com"
puts "French: Mastodon hébergé sur example.com"
puts

# 3. Pluralization Examples
puts "3. Pluralization Examples:"
puts "-" * 28

examples = [
  { count: 0, en: "No followers", es: "Sin seguidores", fr: "Aucun abonné" },
  { count: 1, en: "1 follower", es: "1 seguidor", fr: "1 abonné" },
  { count: 5, en: "5 followers", es: "5 seguidores", fr: "5 abonnés" }
]

examples.each do |example|
  puts "Count: #{example[:count]}"
  puts "  English: #{example[:en]}"
  puts "  Spanish: #{example[:es]}"
  puts "  French:  #{example[:fr]}"
  puts
end

# 4. Locale Detection Priority
puts "4. Locale Detection Priority:"
puts "-" * 31

detection_order = [
  "1. URL parameter (?lang=es)",
  "2. User's saved preference (current_user.locale)",
  "3. Browser Accept-Language header",
  "4. Default locale (ENV['DEFAULT_LOCALE'] or :en)"
]

detection_order.each { |step| puts step }
puts

# 5. Available Locales
puts "5. Supported Locales (Sample):"
puts "-" * 32

sample_locales = [
  { code: 'af', name: 'Afrikaans' },
  { code: 'ar', name: 'العربية' },
  { code: 'de', name: 'Deutsch' },
  { code: 'en', name: 'English' },
  { code: 'en-GB', name: 'English (British)' },
  { code: 'es', name: 'Español' },
  { code: 'es-AR', name: 'Español (Argentina)' },
  { code: 'fr', name: 'Français' },
  { code: 'fr-CA', name: 'Français (Canadien)' },
  { code: 'it', name: 'Italiano' },
  { code: 'ja', name: '日本語' },
  { code: 'ko', name: '한국어' },
  { code: 'pt-BR', name: 'Português (Brasil)' },
  { code: 'ru', name: 'Русский' },
  { code: 'zh-CN', name: '中文 (简体)' },
  { code: 'zh-TW', name: '中文 (繁體)' }
]

sample_locales.each do |locale|
  puts sprintf("%-8s %s", locale[:code], locale[:name])
end

puts "\n... and 60+ more languages!"
puts

# 6. File Structure
puts "6. Translation File Structure:"
puts "-" * 32

file_structure = [
  "Backend (Rails I18n):",
  "  config/locales/",
  "    ├── en.yml                    # Main English translations",
  "    ├── es.yml                    # Main Spanish translations", 
  "    ├── activerecord.en.yml       # Model/validation translations",
  "    ├── activerecord.es.yml",
  "    ├── devise.en.yml             # Authentication translations",
  "    ├── devise.es.yml",
  "    ├── doorkeeper.en.yml         # OAuth translations",
  "    └── doorkeeper.es.yml",
  "",
  "Frontend (React Intl):",
  "  app/javascript/mastodon/locales/",
  "    ├── en.json                   # English UI translations",
  "    ├── es.json                   # Spanish UI translations",
  "    ├── intl_provider.tsx         # React Intl setup",
  "    └── load_locale.ts            # Dynamic locale loading"
]

file_structure.each { |line| puts line }
puts

# 7. Usage Examples
puts "7. Code Usage Examples:"
puts "-" * 25

backend_examples = [
  "Backend (Ruby/Rails):",
  "  I18n.t('accounts.followers.other')",
  "  I18n.t('about.hosted_on', domain: 'example.com')",
  "  I18n.t('accounts.followers', count: user.followers_count)",
  "  I18n.with_locale(:es) { I18n.t('welcome') }",
  ""
]

frontend_examples = [
  "Frontend (JavaScript/React):",
  "  const messages = defineMessages({",
  "    follow: { id: 'account.follow', defaultMessage: 'Follow' }",
  "  });",
  "  ",
  "  intl.formatMessage(messages.follow)",
  "  intl.formatMessage(messages.followers, { count: 42 })"
]

(backend_examples + frontend_examples).each { |line| puts line }
puts

# 8. Configuration Details
puts "8. Key Configuration Files:"
puts "-" * 29

config_files = [
  "config/initializers/i18n.rb      # Rails I18n configuration",
  "app/controllers/concerns/localized.rb  # Locale detection logic",
  "app/helpers/languages_helper.rb  # Language utility methods",
  "app/models/user.rb               # User locale preferences"
]

config_files.each { |file| puts file }
puts

puts "=" * 60
puts "This demonstrates a comprehensive I18n system supporting 80+ languages"
puts "with automatic locale detection, user preferences, and seamless"
puts "frontend/backend integration."
puts "=" * 60