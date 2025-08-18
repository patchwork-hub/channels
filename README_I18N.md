# Understanding Ruby I18n in the Channels Project

This document provides a comprehensive overview of how Ruby I18n (Internationalization) is implemented in the Channels project.

## 📚 Documentation Files

1. **[I18N_GUIDE.md](docs/I18N_GUIDE.md)** - Complete technical guide covering:
   - Backend Rails I18n configuration and usage
   - Frontend React Intl implementation
   - Locale detection and switching mechanisms
   - Translation file structure and management
   - Best practices and conventions

2. **[I18N_EXAMPLES.md](docs/I18N_EXAMPLES.md)** - Practical code examples showing:
   - Backend translation usage with interpolation and pluralization
   - Frontend React component internationalization
   - API responses with localized messages
   - Error handling and validation messages
   - Dynamic locale switching

3. **[I18N_TESTS.md](docs/I18N_TESTS.md)** - Testing strategies and examples:
   - RSpec tests for backend I18n functionality
   - Jest tests for frontend React Intl components
   - Integration tests for locale detection
   - Translation completeness validation
   - Performance testing approaches

4. **[i18n_demo.rb](scripts/i18n_demo.rb)** - Interactive demonstration script

## 🌍 Key Features

The Channels project implements a sophisticated I18n system with:

- **80+ Supported Languages** including regional variants (en-GB, es-AR, pt-BR, etc.)
- **Automatic Locale Detection** via URL parameters, user preferences, and browser headers
- **Dual Translation System** with Rails I18n for backend and React Intl for frontend
- **Dynamic Locale Loading** for optimal performance
- **Translation Services Integration** for real-time content translation
- **Comprehensive Validation** to ensure translation completeness

## 🏗️ Architecture Overview

### Backend (Rails I18n)
```
config/initializers/i18n.rb     # Configuration
app/controllers/concerns/localized.rb  # Locale detection
config/locales/                 # Translation files
  ├── en.yml, es.yml, fr.yml... # Main translations
  ├── activerecord.*.yml        # Model validations
  ├── devise.*.yml              # Authentication
  └── doorkeeper.*.yml          # OAuth
```

### Frontend (React Intl)
```
app/javascript/mastodon/locales/
  ├── en.json, es.json, fr.json... # UI translations
  ├── intl_provider.tsx            # React Intl setup
  └── load_locale.ts               # Dynamic loading
```

## 🚀 Quick Start

### Using Backend Translations
```ruby
# Basic translation
I18n.t('accounts.followers.other')

# With interpolation
I18n.t('about.hosted_on', domain: 'example.com')

# With pluralization
I18n.t('accounts.followers', count: user.followers_count)

# Temporary locale switch
I18n.with_locale(:es) { I18n.t('welcome') }
```

### Using Frontend Translations
```jsx
import { defineMessages, injectIntl } from 'react-intl';

const messages = defineMessages({
  follow: { id: 'account.follow', defaultMessage: 'Follow' }
});

// In component
intl.formatMessage(messages.follow)
```

### Switching Locales
```ruby
# Via URL parameter
/path?lang=es

# Via user preference
current_user.update(locale: 'es')

# Via Accept-Language header (automatic)
```

## 🔍 Locale Detection Priority

1. **URL Parameter** (`?lang=es`) - Highest priority
2. **User Preference** (`current_user.locale`) - If authenticated
3. **Browser Header** (`Accept-Language`) - If no default locale set
4. **Default Locale** (`ENV['DEFAULT_LOCALE']` or `:en`) - Fallback

## 📝 Adding New Translations

### 1. Backend (YAML)
```yaml
# config/locales/en.yml
en:
  statuses:
    character_limit: "Character limit: %{max}"

# config/locales/es.yml  
es:
  statuses:
    character_limit: "Límite de caracteres: %{max}"
```

### 2. Frontend (JSON)
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

## 🛠️ Development Tools

### Validation
```bash
# Check locale files completeness
bundle exec rake repo:check_locales

# Validate YAML syntax
bundle exec rake i18n:check_completeness
```

### Testing
```bash
# Run I18n related tests
bundle exec rspec spec/ --tag i18n

# Frontend translation tests
npm test -- --testPathPattern=locales
```

### Demo
```bash
# Run interactive demonstration
ruby scripts/i18n_demo.rb
```

## 📖 Further Reading

- [Rails I18n Guide](https://guides.rubyonrails.org/i18n.html)
- [React Intl Documentation](https://formatjs.io/docs/react-intl/)
- [Project Translation Files](config/locales/)
- [Frontend Locale Files](app/javascript/mastodon/locales/)

## 🤝 Contributing Translations

The project welcomes contributions for new languages and improvements to existing translations. See the [CONTRIBUTING.md](CONTRIBUTING.md) file for translation guidelines and the [AUTHORS.md](AUTHORS.md) file for a list of translators who have contributed to the project.

---

This implementation demonstrates enterprise-level internationalization supporting a global user base with automatic locale detection, comprehensive translation management, and seamless user experience across all supported languages.