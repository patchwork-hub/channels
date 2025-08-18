# I18n Practical Examples

This file contains practical examples demonstrating how the I18n system works in the Channels project.

## Example 1: Basic Translation Usage

### Backend (Rails)

```ruby
# Example from a controller
class StatusesController < ApplicationController
  def create
    @status = current_account.statuses.build(status_params)
    
    if @status.save
      render json: { message: I18n.t('statuses.created_successfully') }
    else
      render json: { 
        error: I18n.t('statuses.creation_failed'),
        details: @status.errors.full_messages 
      }
    end
  end
end
```

### Corresponding YAML files:

```yaml
# config/locales/en.yml
en:
  statuses:
    created_successfully: "Your post was published successfully!"
    creation_failed: "Failed to publish your post"
    
# config/locales/es.yml  
es:
  statuses:
    created_successfully: "¡Tu publicación se publicó con éxito!"
    creation_failed: "Error al publicar tu contenido"
```

## Example 2: Complex Translation with Interpolation

### Backend Usage:

```ruby
# In a mailer
class NotificationMailer < ApplicationMailer
  def new_follower(user, follower)
    @user = user
    @follower = follower
    
    mail(
      to: @user.email,
      subject: I18n.t('mailer.new_follower.subject', follower_name: @follower.display_name)
    )
  end
end
```

### Translation files:

```yaml
# config/locales/en.yml
en:
  mailer:
    new_follower:
      subject: "%{follower_name} is now following you"
      body: "Hi %{user_name}, %{follower_name} (@%{follower_username}) started following you on %{instance_name}."

# config/locales/es.yml
es:
  mailer:
    new_follower:
      subject: "%{follower_name} ahora te sigue"
      body: "Hola %{user_name}, %{follower_name} (@%{follower_username}) comenzó a seguirte en %{instance_name}."
```

## Example 3: Pluralization

### Backend Usage:

```ruby
# In a helper or model
class AccountsHelper
  def followers_count_text(count)
    I18n.t('accounts.followers_count', count: count)
  end
  
  def posts_count_text(count) 
    I18n.t('accounts.posts_count', count: count)
  end
end
```

### Translation files:

```yaml
# config/locales/en.yml
en:
  accounts:
    followers_count:
      zero: "No followers"
      one: "1 follower"
      other: "%{count} followers"
    posts_count:
      zero: "No posts"
      one: "1 post" 
      other: "%{count} posts"

# config/locales/es.yml
es:
  accounts:
    followers_count:
      zero: "Sin seguidores"
      one: "1 seguidor"
      other: "%{count} seguidores"
    posts_count:
      zero: "Sin publicaciones"
      one: "1 publicación"
      other: "%{count} publicaciones"
```

## Example 4: Frontend React Intl Usage

### Component Definition:

```jsx
// app/javascript/mastodon/features/account/components/header.jsx
import React from 'react';
import { injectIntl, defineMessages } from 'react-intl';

const messages = defineMessages({
  follow: { id: 'account.follow', defaultMessage: 'Follow' },
  unfollow: { id: 'account.unfollow', defaultMessage: 'Unfollow' },
  block: { id: 'account.block', defaultMessage: 'Block @{name}' },
  mute: { id: 'account.mute', defaultMessage: 'Mute @{name}' },
  followers: { 
    id: 'account.followers_counter', 
    defaultMessage: '{count, plural, one {{counter} follower} other {{counter} followers}}' 
  },
});

class AccountHeader extends React.Component {
  render() {
    const { account, intl, relationship } = this.props;
    
    return (
      <div className="account-header">
        <h1>{account.display_name}</h1>
        <p>@{account.username}</p>
        
        <div className="account-stats">
          <span>
            {intl.formatMessage(messages.followers, { 
              count: account.followers_count,
              counter: account.followers_count 
            })}
          </span>
        </div>
        
        <div className="account-actions">
          {relationship.following ? (
            <button onClick={this.handleUnfollow}>
              {intl.formatMessage(messages.unfollow)}
            </button>
          ) : (
            <button onClick={this.handleFollow}>
              {intl.formatMessage(messages.follow)}
            </button>
          )}
          
          <button onClick={this.handleBlock}>
            {intl.formatMessage(messages.block, { name: account.username })}
          </button>
        </div>
      </div>
    );
  }
}

export default injectIntl(AccountHeader);
```

### Corresponding JSON translations:

```json
// app/javascript/mastodon/locales/en.json
{
  "account.follow": "Follow",
  "account.unfollow": "Unfollow", 
  "account.block": "Block @{name}",
  "account.mute": "Mute @{name}",
  "account.followers_counter": "{count, plural, one {{counter} follower} other {{counter} followers}}"
}

// app/javascript/mastodon/locales/es.json
{
  "account.follow": "Seguir",
  "account.unfollow": "Dejar de seguir",
  "account.block": "Bloquear a @{name}",
  "account.mute": "Silenciar a @{name}",
  "account.followers_counter": "{count, plural, one {{counter} seguidor} other {{counter} seguidores}}"
}
```

## Example 5: Dynamic Locale Switching

### User Settings Component:

```jsx
// app/javascript/mastodon/features/settings/components/language_selector.jsx
import React from 'react';
import { injectIntl, defineMessages } from 'react-intl';

const messages = defineMessages({
  selectLanguage: { id: 'settings.select_language', defaultMessage: 'Select Language' },
  currentLanguage: { id: 'settings.current_language', defaultMessage: 'Current: {language}' },
});

class LanguageSelector extends React.Component {
  handleLanguageChange = (event) => {
    const newLocale = event.target.value;
    
    // Update user preference via API
    this.props.onLanguageChange(newLocale);
    
    // Reload page with new locale
    window.location.href = `${window.location.pathname}?lang=${newLocale}`;
  };

  render() {
    const { intl, currentLocale, availableLocales } = this.props;
    
    return (
      <div className="language-selector">
        <label htmlFor="language-select">
          {intl.formatMessage(messages.selectLanguage)}
        </label>
        
        <select 
          id="language-select"
          value={currentLocale} 
          onChange={this.handleLanguageChange}
        >
          {availableLocales.map(([code, name]) => (
            <option key={code} value={code}>
              {name}
            </option>
          ))}
        </select>
        
        <p className="current-language">
          {intl.formatMessage(messages.currentLanguage, { 
            language: intl.locale 
          })}
        </p>
      </div>
    );
  }
}

export default injectIntl(LanguageSelector);
```

## Example 6: Error Messages with Context

### Form Validation:

```ruby
# app/models/status.rb
class Status < ApplicationRecord
  MAX_CHARS = 500
  
  validates :text, length: { 
    maximum: MAX_CHARS,
    message: -> (record, data) { 
      I18n.t('activerecord.errors.models.status.attributes.text.too_long', 
             max: MAX_CHARS, current: data[:value]&.length || 0) 
    }
  }
  
  validates :spoiler_text, length: {
    maximum: 100,
    message: -> (record, data) {
      I18n.t('activerecord.errors.models.status.attributes.spoiler_text.too_long',
             max: 100)
    }
  }
end
```

### Error message translations:

```yaml
# config/locales/activerecord.en.yml
en:
  activerecord:
    errors:
      models:
        status:
          attributes:
            text:
              too_long: "Status is too long (maximum is %{max} characters, you entered %{current})"
            spoiler_text:
              too_long: "Content warning is too long (maximum is %{max} characters)"

# config/locales/activerecord.es.yml  
es:
  activerecord:
    errors:
      models:
        status:
          attributes:
            text:
              too_long: "El estado es demasiado largo (máximo %{max} caracteres, ingresaste %{current})"
            spoiler_text:
              too_long: "La advertencia de contenido es demasiado larga (máximo %{max} caracteres)"
```

## Example 7: Time and Date Localization

### Usage in views and helpers:

```ruby
# app/helpers/application_helper.rb
module ApplicationHelper
  def time_ago_in_words_with_context(time)
    if time > 1.day.ago
      I18n.t('time.recent', time: time_ago_in_words(time))
    elsif time > 1.week.ago  
      I18n.t('time.this_week', day: l(time, format: :weekday))
    else
      I18n.t('time.older', date: l(time, format: :short))
    end
  end
  
  def format_account_created_at(account)
    I18n.t('accounts.joined_date', date: l(account.created_at, format: :long))
  end
end
```

### Time format translations:

```yaml
# config/locales/en.yml
en:
  time:
    recent: "%{time} ago"
    this_week: "on %{day}"
    older: "on %{date}"
  accounts:
    joined_date: "Joined %{date}"
    
  date:
    formats:
      short: "%b %d"
      long: "%B %d, %Y"
    day_names: [Sunday, Monday, Tuesday, Wednesday, Thursday, Friday, Saturday]
    month_names: [~, January, February, March, April, May, June, July, August, September, October, November, December]

# config/locales/es.yml
es:
  time:
    recent: "hace %{time}"
    this_week: "el %{day}"
    older: "el %{date}"
  accounts:
    joined_date: "Se unió el %{date}"
    
  date:
    formats:
      short: "%d %b"
      long: "%d de %B de %Y"
    day_names: [domingo, lunes, martes, miércoles, jueves, viernes, sábado]
    month_names: [~, enero, febrero, marzo, abril, mayo, junio, julio, agosto, septiembre, octubre, noviembre, diciembre]
```

## Example 8: API Responses with I18n

### API Controller:

```ruby
# app/controllers/api/v1/accounts_controller.rb
class Api::V1::AccountsController < Api::BaseController
  def create
    @account = Account.new(account_params)
    
    if @account.save
      render json: { 
        message: I18n.t('api.accounts.created'),
        account: AccountSerializer.new(@account)
      }
    else
      render json: { 
        error: I18n.t('api.accounts.creation_failed'),
        details: @account.errors.full_messages.map { |msg| 
          # Ensure error messages are also translated
          msg 
        }
      }, status: 422
    end
  end
  
  def follow
    relationship = current_account.follow!(@account)
    
    render json: { 
      message: I18n.t('api.accounts.follow_success', name: @account.display_name),
      relationship: RelationshipSerializer.new(relationship)
    }
  rescue Mastodon::ValidationError => e
    render json: { 
      error: I18n.t('api.accounts.follow_failed'),
      details: e.message 
    }, status: 422
  end
end
```

### API-specific translations:

```yaml
# config/locales/en.yml
en:
  api:
    accounts:
      created: "Account created successfully"
      creation_failed: "Failed to create account"
      follow_success: "You are now following %{name}"
      follow_failed: "Unable to follow this account"

# config/locales/es.yml
es:
  api:
    accounts:
      created: "Cuenta creada exitosamente"
      creation_failed: "Error al crear la cuenta"
      follow_success: "Ahora sigues a %{name}"
      follow_failed: "No se pudo seguir esta cuenta"
```

This demonstrates how the I18n system works throughout the entire application stack, from API responses to user interface elements, providing a consistent multilingual experience.