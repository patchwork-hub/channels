# Ruby I18n (Internationalization) Guide for the Channels Project

This guide explains how internationalization (I18n) works in the Channels project, which is based on Mastodon. The project supports over 80 languages with a sophisticated locale detection and management system.

## Table of Contents

1. [Overview](#overview)
2. [Backend I18n (Rails)](#backend-i18n-rails)
3. [Frontend I18n (React Intl)](#frontend-i18n-react-intl)
4. [Locale Detection and Switching](#locale-detection-and-switching)
5. [Configuration](#configuration)
6. [Translation Files Structure](#translation-files-structure)
7. [Usage Examples](#usage-examples)
8. [Adding New Translations](#adding-new-translations)
9. [Best Practices](#best-practices)

## Overview

The Channels project uses a dual I18n approach:
- **Backend**: Rails I18n for server-side translations (emails, API responses, server-rendered content)
- **Frontend**: React Intl for client-side JavaScript translations (UI components, user interactions)

Both systems work together to provide a seamless multilingual experience.

## Backend I18n (Rails)

### Configuration

The Rails I18n system is configured in `config/initializers/i18n.rb`:

```ruby
# Available locales (80+ languages supported)
config.i18n.available_locales = [
  :af, :an, :ar, :ast, :be, :bg, :bn, :br, :bs, :ca, :ckb, :co, :cs, :cy,
  :da, :de, :el, :en, :'en-GB', :eo, :es, :'es-AR', :'es-MX', :et, :eu,
  :fa, :fi, :fo, :fr, :'fr-CA', :fy, :ga, :gd, :gl, :he, :hi, :hr, :hu,
  :hy, :ia, :id, :ie, :ig, :io, :is, :it, :ja, :ka, :kab, :kk, :kn, :ko,
  # ... and many more
]

# Default locale with environment variable support
config.i18n.default_locale = begin
  custom_default_locale = ENV['DEFAULT_LOCALE']&.to_sym
  if Rails.configuration.i18n.available_locales.include?(custom_default_locale)
    custom_default_locale
  else
    :en
  end
end
```

### Locale Detection System

The `Localized` concern (`app/controllers/concerns/localized.rb`) handles automatic locale detection:

```ruby
module Localized
  extend ActiveSupport::Concern

  included do
    around_action :set_locale
  end

  def set_locale(&block)
    I18n.with_locale(requested_locale || I18n.default_locale, &block)
  end

  private

  def requested_locale
    # Priority order for locale detection:
    # 1. URL parameter (?lang=es)
    requested_locale_name   = available_locale_or_nil(params[:lang])
    # 2. User's saved preference
    requested_locale_name ||= available_locale_or_nil(current_user.locale) if respond_to?(:user_signed_in?) && user_signed_in?
    # 3. Browser Accept-Language header
    requested_locale_name ||= http_accept_language if ENV['DEFAULT_LOCALE'].blank?
    requested_locale_name
  end

  def http_accept_language
    HttpAcceptLanguage::Parser.new(request.headers.fetch('Accept-Language'))
      .language_region_compatible_from(I18n.available_locales) if request.headers.key?('Accept-Language')
  end

  def available_locale_or_nil(locale_name)
    locale_name.to_sym if locale_name.present? && I18n.available_locales.include?(locale_name.to_sym)
  end
end
```

### Translation File Structure

Backend translations are stored in `config/locales/` with the following structure:

```
config/locales/
├── en.yml                    # Main English translations
├── es.yml                    # Main Spanish translations
├── activerecord.en.yml       # ActiveRecord model translations
├── activerecord.es.yml
├── devise.en.yml             # Authentication system translations
├── devise.es.yml
├── doorkeeper.en.yml         # OAuth system translations
├── doorkeeper.es.yml
├── simple_form.en.yml        # Form helper translations
└── simple_form.es.yml
```

### Usage Examples

#### Basic Translation

```ruby
# In controllers, models, or views
I18n.t('accounts.followers.one')     # "Follower"
I18n.t('accounts.followers.other')   # "Followers"
```

#### Interpolation

```ruby
# Translation with variables
I18n.t('about.hosted_on', domain: 'example.com')
# Uses: "Mastodon hosted on %{domain}"
# Result: "Mastodon hosted on example.com"
```

#### Pluralization

```yaml
# In locale files
en:
  accounts:
    followers:
      one: Follower
      other: Followers
```

```ruby
# Usage
I18n.t('accounts.followers', count: 1)   # "Follower"
I18n.t('accounts.followers', count: 5)   # "Followers"
```

#### Mailer Example

```ruby
# In app/mailers/user_mailer.rb
def warning(user, warning)
  @user = user
  @warning = warning
  
  mail(
    to: @user.email,
    subject: I18n.t("user_mailer.warning.subject.#{@warning.action}", acct: "@#{user.account.local_username_and_domain}")
  )
end
```

## Frontend I18n (React Intl)

### Configuration

The frontend uses React Intl with dynamic locale loading:

```typescript
// app/javascript/mastodon/locales/load_locale.ts
export async function loadLocale() {
  const locale = document.querySelector<HTMLElement>('html')?.lang || 'en';
  
  await localeLoadingSemaphore.runExclusive(async () => {
    if (isLocaleLoaded()) return;

    // Dynamic import of locale file
    const localeData = (await import(
      /* webpackMode: "lazy" */
      /* webpackChunkName: "locale/[request]" */
      `mastodon/locales/${locale}.json`
    )) as LocaleData['messages'];

    setLocale({ messages: localeData, locale });
  });
}
```

### Frontend Translation Structure

Frontend translations are stored in `app/javascript/mastodon/locales/`:

```
app/javascript/mastodon/locales/
├── en.json
├── es.json
├── fr.json
├── intl_provider.tsx     # React Intl provider setup
├── load_locale.ts        # Dynamic locale loading
└── global_locale.ts      # Locale state management
```

### Usage Examples

#### Component with Translations

```jsx
import { injectIntl, defineMessages } from 'react-intl';

const messages = defineMessages({
  changeLanguage: { 
    id: 'compose.language.change', 
    defaultMessage: 'Change language' 
  },
  search: { 
    id: 'compose.language.search', 
    defaultMessage: 'Search languages...' 
  },
});

class LanguageDropdown extends PureComponent {
  render() {
    const { intl } = this.props;
    
    return (
      <button title={intl.formatMessage(messages.changeLanguage)}>
        <span>{intl.formatMessage(messages.search)}</span>
      </button>
    );
  }
}

export default injectIntl(LanguageDropdown);
```

#### JSON Translation File Format

```json
{
  "account.block": "Block @{name}",
  "account.followers_counter": "{count, plural, one {{counter} follower} other {{counter} followers}}",
  "about.powered_by": "Decentralized social media powered by {mastodon}",
  "compose.language.change": "Change language"
}
```

## Locale Detection and Switching

### User Preference Storage

Users can set their preferred locale, which is stored in the `users` table:

```ruby
# In app/models/user.rb
class User < ApplicationRecord
  # locale column stores user's preferred language
  normalizes :locale, with: ->(locale) { 
    I18n.available_locales.exclude?(locale.to_sym) ? nil : locale 
  }
end
```

### Language Helper Utilities

The `LanguagesHelper` module provides utilities for language handling:

```ruby
# app/helpers/languages_helper.rb
module LanguagesHelper
  SUPPORTED_LOCALES = {}.merge(ISO_639_1).merge(ISO_639_1_REGIONAL).merge(ISO_639_3).freeze

  REGIONAL_LOCALE_NAMES = {
    'en-GB': 'English (British)',
    'es-AR': 'Español (Argentina)',
    'es-MX': 'Español (México)',
    'fr-CA': 'Français (Canadien)',
    'pt-BR': 'Português (Brasil)',
    'pt-PT': 'Português (Portugal)',
    'sr-Latn': 'Srpski (latinica)',
  }.freeze

  def native_locale_name(locale)
    if locale.blank? || locale == 'und'
      I18n.t('generic.none')
    elsif (supported_locale = SUPPORTED_LOCALES[locale.to_sym])
      supported_locale[1]  # Native name
    elsif (regional_locale = REGIONAL_LOCALE_NAMES[locale.to_sym])
      regional_locale
    else
      locale
    end
  end
end
```

## Translation Management

### Validation System

The project includes a Rake task to validate translation completeness:

```ruby
# lib/tasks/repo.rake
task check_locales: :environment do
  missing_yaml_files = I18n.available_locales.reject { |locale| 
    Rails.root.join('config', 'locales', "#{locale}.yml").exist? 
  }
  
  missing_json_files = I18n.available_locales.reject { |locale| 
    Rails.root.join('app', 'javascript', 'mastodon', 'locales', "#{locale}.json").exist? 
  }

  # Validation logic and error reporting...
end
```

### Translation Services

The project supports external translation services:

```ruby
# app/lib/translation_service/libre_translate.rb
class TranslationService::LibreTranslate < TranslationService
  def translate(texts, source_language, target_language)
    body = Oj.dump(
      q: texts, 
      source: source_language.presence || 'auto', 
      target: target_language, 
      format: 'html', 
      api_key: @api_key
    )
    
    request(:post, '/translate', body: body) do |res|
      transform_response(res.body_with_limit, source_language)
    end
  end
end
```

## Adding New Translations

### 1. Backend Translation (YAML)

Add to the appropriate locale file in `config/locales/`:

```yaml
# config/locales/en.yml
en:
  statuses:
    over_character_limit: "Status exceeds maximum length of %{max} characters"
    
# config/locales/es.yml
es:
  statuses:
    over_character_limit: "El estado excede la longitud máxima de %{max} caracteres"
```

### 2. Frontend Translation (JSON)

Add to the appropriate locale file in `app/javascript/mastodon/locales/`:

```json
// app/javascript/mastodon/locales/en.json
{
  "status.character_limit": "Character limit: {max}"
}

// app/javascript/mastodon/locales/es.json
{
  "status.character_limit": "Límite de caracteres: {max}"
}
```

### 3. Usage in Code

```ruby
# Backend usage
I18n.t('statuses.over_character_limit', max: MAX_CHARS)
```

```jsx
// Frontend usage
const messages = defineMessages({
  characterLimit: { 
    id: 'status.character_limit', 
    defaultMessage: 'Character limit: {max}' 
  },
});

// In component
intl.formatMessage(messages.characterLimit, { max: MAX_CHARS })
```

## Best Practices

### 1. Use Descriptive Keys
```yaml
# Good
user.profile.update_success: "Profile updated successfully"

# Avoid
messages.success: "Success"
```

### 2. Group Related Translations
```yaml
admin:
  accounts:
    approve: "Approve"
    reject: "Reject"
    suspend: "Suspend"
```

### 3. Handle Pluralization
```yaml
notifications:
  count:
    one: "1 notification"
    other: "%{count} notifications"
```

### 4. Use Interpolation for Dynamic Content
```yaml
welcome_message: "Welcome, %{name}!"
```

### 5. Provide Context in Comments
```yaml
# Button text for saving user preferences
settings:
  save: "Save"
```

This comprehensive I18n system ensures that the Channels project can serve users worldwide in their native languages, with automatic locale detection and seamless switching between languages.