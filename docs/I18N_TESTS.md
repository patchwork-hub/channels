# I18n System Test Demonstration

This file demonstrates how to test the I18n functionality in the Channels project.
Since we cannot run the full test suite without proper Ruby environment setup,
this file serves as documentation of how the I18n system would be tested.

## Test Structure Overview

### 1. Backend I18n Tests (RSpec)

```ruby
# spec/models/user_spec.rb - Testing user locale preferences
require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'locale handling' do
    it 'normalizes valid locales' do
      user = build(:user, locale: 'es')
      expect(user.locale).to eq('es')
    end
    
    it 'rejects invalid locales' do
      user = build(:user, locale: 'invalid_locale')
      expect(user.locale).to be_nil
    end
    
    it 'accepts regional locales' do
      user = build(:user, locale: 'en-GB')
      expect(user.locale).to eq('en-GB')
    end
  end
end

# spec/controllers/concerns/localized_spec.rb - Testing locale detection
require 'rails_helper'

RSpec.describe Localized, type: :controller do
  controller(ApplicationController) do
    def index
      render plain: I18n.locale.to_s
    end
  end

  describe 'locale detection' do
    it 'uses URL parameter when provided' do
      get :index, params: { lang: 'es' }
      expect(response.body).to eq('es')
    end
    
    it 'falls back to user preference' do
      user = create(:user, locale: 'fr')
      sign_in user
      get :index
      expect(response.body).to eq('fr')
    end
    
    it 'uses Accept-Language header as fallback' do
      request.headers['Accept-Language'] = 'de,en;q=0.9'
      get :index
      expect(response.body).to eq('de')
    end
    
    it 'defaults to English when no preference is found' do
      get :index
      expect(response.body).to eq('en')
    end
  end
end

# spec/helpers/languages_helper_spec.rb - Testing language utilities
require 'rails_helper'

RSpec.describe LanguagesHelper, type: :helper do
  describe '#native_locale_name' do
    it 'returns native name for supported locales' do
      expect(helper.native_locale_name('es')).to eq('Español')
      expect(helper.native_locale_name('fr')).to eq('Français')
    end
    
    it 'returns regional names for regional locales' do
      expect(helper.native_locale_name('en-GB')).to eq('English (British)')
      expect(helper.native_locale_name('es-AR')).to eq('Español (Argentina)')
    end
    
    it 'returns locale code for unsupported locales' do
      expect(helper.native_locale_name('xyz')).to eq('xyz')
    end
    
    it 'returns "None" for blank locale' do
      I18n.with_locale(:en) do
        expect(helper.native_locale_name('')).to eq('None')
        expect(helper.native_locale_name('und')).to eq('None')
      end
    end
  end
  
  describe '#valid_locale_or_nil' do
    it 'returns valid locale codes' do
      expect(helper.valid_locale_or_nil('en')).to eq('en')
      expect(helper.valid_locale_or_nil('es-AR')).to eq('es-AR')
    end
    
    it 'extracts base locale from region' do
      expect(helper.valid_locale_or_nil('en_US')).to eq('en')
      expect(helper.valid_locale_or_nil('fr-FR')).to eq('fr')
    end
    
    it 'returns nil for invalid locales' do
      expect(helper.valid_locale_or_nil('invalid')).to be_nil
      expect(helper.valid_locale_or_nil('')).to be_nil
    end
  end
end

# spec/lib/translation_service_spec.rb - Testing translation services
require 'rails_helper'

RSpec.describe TranslationService::LibreTranslate do
  let(:service) { described_class.new('http://example.com', 'api_key') }
  
  describe '#translate' do
    it 'translates text between languages' do
      # Mock HTTP response
      stub_request(:post, 'http://example.com/translate')
        .with(
          body: {
            q: ['Hello world'],
            source: 'en',
            target: 'es',
            format: 'html',
            api_key: 'api_key'
          }.to_json
        )
        .to_return(
          status: 200,
          body: {
            translatedText: ['Hola mundo'],
            detectedLanguage: [{ language: 'en' }]
          }.to_json
        )
      
      result = service.translate(['Hello world'], 'en', 'es')
      
      expect(result).to be_an(Array)
      expect(result.first).to be_a(Translation)
      expect(result.first.text).to eq('Hola mundo')
      expect(result.first.detected_source_language).to eq('en')
      expect(result.first.provider).to eq('LibreTranslate')
    end
  end
end
```

### 2. Frontend I18n Tests (Jest)

```javascript
// app/javascript/mastodon/locales/__tests__/load_locale.test.ts
import { loadLocale } from '../load_locale';
import { isLocaleLoaded, getLocale } from '../global_locale';

// Mock dynamic imports
jest.mock('../en.json', () => ({
  'account.follow': 'Follow',
  'account.unfollow': 'Unfollow'
}), { virtual: true });

jest.mock('../es.json', () => ({
  'account.follow': 'Seguir', 
  'account.unfollow': 'Dejar de seguir'
}), { virtual: true });

describe('loadLocale', () => {
  beforeEach(() => {
    // Reset locale state
    jest.clearAllMocks();
    
    // Mock HTML lang attribute
    document.documentElement.lang = 'en';
  });

  it('loads English locale by default', async () => {
    await loadLocale();
    
    expect(isLocaleLoaded()).toBe(true);
    
    const { locale, messages } = getLocale();
    expect(locale).toBe('en');
    expect(messages['account.follow']).toBe('Follow');
  });
  
  it('loads Spanish locale when HTML lang is es', async () => {
    document.documentElement.lang = 'es';
    
    await loadLocale();
    
    const { locale, messages } = getLocale();
    expect(locale).toBe('es');
    expect(messages['account.follow']).toBe('Seguir');
  });
  
  it('only loads locale once per session', async () => {
    const importSpy = jest.spyOn(require, 'import');
    
    await loadLocale();
    await loadLocale(); // Second call
    
    // Import should only be called once
    expect(importSpy).toHaveBeenCalledTimes(1);
  });
});

// app/javascript/mastodon/components/__tests__/account_header.test.jsx
import React from 'react';
import { render, screen } from '@testing-library/react';
import { IntlProvider } from 'react-intl';
import AccountHeader from '../account_header';

const mockAccount = {
  id: '1',
  username: 'testuser',
  display_name: 'Test User',
  followers_count: 42,
};

const mockRelationship = {
  following: false,
};

const renderWithIntl = (component, locale = 'en', messages = {}) => {
  const defaultMessages = {
    'account.follow': 'Follow',
    'account.unfollow': 'Unfollow',
    'account.block': 'Block @{name}',
    'account.followers_counter': '{count, plural, one {{counter} follower} other {{counter} followers}}',
    ...messages
  };
  
  return render(
    <IntlProvider locale={locale} messages={defaultMessages}>
      {component}
    </IntlProvider>
  );
};

describe('AccountHeader', () => {
  it('displays follow button in English', () => {
    renderWithIntl(
      <AccountHeader 
        account={mockAccount} 
        relationship={mockRelationship}
      />
    );
    
    expect(screen.getByText('Follow')).toBeInTheDocument();
    expect(screen.getByText('42 followers')).toBeInTheDocument();
  });
  
  it('displays follow button in Spanish', () => {
    const spanishMessages = {
      'account.follow': 'Seguir',
      'account.followers_counter': '{count, plural, one {{counter} seguidor} other {{counter} seguidores}}',
    };
    
    renderWithIntl(
      <AccountHeader 
        account={mockAccount} 
        relationship={mockRelationship}
      />,
      'es',
      spanishMessages
    );
    
    expect(screen.getByText('Seguir')).toBeInTheDocument();
    expect(screen.getByText('42 seguidores')).toBeInTheDocument();
  });
  
  it('interpolates username in block button', () => {
    renderWithIntl(
      <AccountHeader 
        account={mockAccount} 
        relationship={mockRelationship}
      />
    );
    
    expect(screen.getByText('Block @testuser')).toBeInTheDocument();
  });
  
  it('handles pluralization correctly', () => {
    const singleFollowerAccount = { ...mockAccount, followers_count: 1 };
    
    renderWithIntl(
      <AccountHeader 
        account={singleFollowerAccount} 
        relationship={mockRelationship}
      />
    );
    
    expect(screen.getByText('1 follower')).toBeInTheDocument();
  });
});
```

### 3. Integration Tests

```ruby
# spec/requests/api/v1/accounts_spec.rb - Testing API I18n
require 'rails_helper'

RSpec.describe 'Accounts API', type: :request do
  let(:user) { create(:user) }
  let(:token) { create(:accessible_access_token, resource_owner_id: user.id) }
  
  describe 'POST /api/v1/accounts' do
    context 'with English locale' do
      before { user.update!(locale: 'en') }
      
      it 'returns English error messages' do
        post '/api/v1/accounts', 
             params: { username: '' }, # Invalid data
             headers: { 'Authorization' => "Bearer #{token.token}" }
        
        expect(response).to have_http_status(422)
        expect(json_response['error']).to eq('Failed to create account')
      end
    end
    
    context 'with Spanish locale' do
      before { user.update!(locale: 'es') }
      
      it 'returns Spanish error messages' do
        post '/api/v1/accounts',
             params: { username: '' }, # Invalid data  
             headers: { 'Authorization' => "Bearer #{token.token}" }
        
        expect(response).to have_http_status(422)
        expect(json_response['error']).to eq('Error al crear la cuenta')
      end
    end
  end
end

# spec/features/locale_switching_spec.rb - Testing user locale switching
require 'rails_helper'

RSpec.feature 'Locale switching', type: :feature do
  let(:user) { create(:user, locale: 'en') }
  
  scenario 'user changes language via URL parameter' do
    sign_in user
    visit root_path(lang: 'es')
    
    # Check that interface elements are in Spanish
    expect(page).to have_content('Configuración')  # Settings in Spanish
    expect(page).not_to have_content('Settings')    # English version
  end
  
  scenario 'user changes language in settings' do
    sign_in user
    visit edit_user_registration_path
    
    select 'Español', from: 'user_locale'
    click_button 'Update'
    
    expect(page).to have_content('Tu cuenta ha sido actualizada') # Spanish success message
    expect(user.reload.locale).to eq('es')
  end
  
  scenario 'browser language is detected for new users' do
    page.driver.header 'Accept-Language', 'fr,en;q=0.9'
    visit root_path
    
    # Should show French interface elements
    expect(page).to have_content('Connexion') # French for "Sign in"
  end
end
```

### 4. Translation Completeness Tests

```ruby
# spec/lib/translation_completeness_spec.rb
require 'rails_helper'

RSpec.describe 'Translation completeness' do
  let(:english_keys) { extract_keys_from_yaml('config/locales/en.yml') }
  
  I18n.available_locales.each do |locale|
    next if locale == :en
    
    describe "#{locale} translations" do
      let(:locale_file) { "config/locales/#{locale}.yml" }
      let(:locale_keys) { extract_keys_from_yaml(locale_file) }
      
      it 'has all required translation keys' do
        missing_keys = english_keys - locale_keys
        
        if missing_keys.any?
          puts "Missing keys in #{locale}: #{missing_keys.join(', ')}"
        end
        
        # Allow for some missing keys in development, but enforce in CI
        if ENV['CI']
          expect(missing_keys).to be_empty, 
            "Missing translation keys in #{locale}: #{missing_keys.join(', ')}"
        end
      end
      
      it 'has valid YAML syntax' do
        expect { YAML.load_file(locale_file) }.not_to raise_error
      end
      
      it 'has corresponding JSON file for frontend' do
        json_file = "app/javascript/mastodon/locales/#{locale}.json"
        expect(File.exist?(json_file)).to be true
      end
    end
  end
  
  private
  
  def extract_keys_from_yaml(file_path)
    return [] unless File.exist?(file_path)
    
    content = YAML.load_file(file_path)
    flatten_hash(content).keys
  end
  
  def flatten_hash(hash, prefix = '')
    hash.flat_map do |key, value|
      new_key = prefix.empty? ? key.to_s : "#{prefix}.#{key}"
      
      if value.is_a?(Hash)
        flatten_hash(value, new_key)
      else
        new_key
      end
    end
  end
end
```

### 5. Performance Tests

```ruby
# spec/performance/i18n_performance_spec.rb
require 'rails_helper'

RSpec.describe 'I18n Performance' do
  it 'loads locales efficiently' do
    expect {
      1000.times { I18n.t('accounts.followers.other') }
    }.to perform_under(100).ms
  end
  
  it 'caches translations properly' do
    # Warm up cache
    I18n.t('accounts.followers.other')
    
    expect {
      100.times { I18n.t('accounts.followers.other') }
    }.to perform_under(10).ms
  end
  
  it 'handles locale switching efficiently' do
    expect {
      10.times do
        I18n.with_locale(:es) { I18n.t('accounts.followers.other') }
        I18n.with_locale(:fr) { I18n.t('accounts.followers.other') }
        I18n.with_locale(:de) { I18n.t('accounts.followers.other') }
      end
    }.to perform_under(50).ms
  end
end
```

## Running Tests

To run these tests in a real environment, you would use:

```bash
# Backend tests
bundle exec rspec spec/models/user_spec.rb
bundle exec rspec spec/controllers/concerns/localized_spec.rb
bundle exec rspec spec/helpers/languages_helper_spec.rb

# Frontend tests  
npm test -- --testPathPattern=locales
npm test -- --testPathPattern=components.*test

# Integration tests
bundle exec rspec spec/requests/
bundle exec rspec spec/features/

# All I18n related tests
bundle exec rspec spec/ --tag i18n

# Check translation completeness
bundle exec rake i18n:check_completeness

# Validate all locale files
bundle exec rake repo:check_locales
```

## Test Coverage Areas

1. **Locale Detection**: URL params, user preferences, browser headers
2. **Translation Interpolation**: Variable substitution, pluralization
3. **Frontend Components**: React Intl integration, message formatting
4. **API Responses**: Localized error messages and responses
5. **User Preferences**: Saving and applying locale settings
6. **Fallback Behavior**: Default to English when translations missing
7. **Performance**: Translation caching and lookup speed
8. **Completeness**: All locales have required translation keys

This comprehensive test suite ensures that the I18n system works correctly across all parts of the application.