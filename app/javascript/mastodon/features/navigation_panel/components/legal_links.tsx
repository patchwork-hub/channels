import React from 'react';
import { useIntl, defineMessages } from 'react-intl';
import { useAppSelector } from 'mastodon/store';

const messages = defineMessages({
    about: { id: 'navigation_bar.about', defaultMessage: 'About' },
});

export const LegalLinks: React.FC = () => {
    const intl = useIntl();
    const server = useAppSelector(state => state.server.get('server')?.toJS() || {});

    return (
        <div className='navigation-panel__sidebar__bottom'>
            <ul style={{ display: 'flex', alignItems: 'center', gap: '1rem', marginBottom: '1rem', listStyle: 'none', padding: 0 }}>
                <li>
                    <a
                        href='https://www.newsmastfoundation.org/terms-conditions/'
                        target='_blank'
                        className='footer-link'
                        rel='noopener noreferrer'
                    >
                        Terms & Conditions
                    </a>
                </li>
                <li>
                    <a
                        href='https://channel.org/privacy-policy/'
                        target='_blank'
                        className='footer-link'
                        rel='noopener noreferrer'
                    >
                        Privacy Policy
                    </a>
                </li>
            </ul>

            <p>
                <a href="https://channel.org/public" className="link label ml-0" target='_blank' rel='noopener noreferrer'>channel.org: </a>
                <a href="https://github.com/patchwork-hub/channels/" className="link underline" target='_blank' rel='noopener noreferrer'>View source code</a>
            </p>

            <p>
                <a href="#" className="link label ml-0">Mastodon: </a>
                <a href="https://joinmastodon.org/" className="link underline" target='_blank' rel='noopener noreferrer'>{intl.formatMessage(messages.about)}</a>
                <span> · </span>
                <a href="https://github.com/mastodon/mastodon" className="link underline" target='_blank' rel='noopener noreferrer'>View source code</a>
                <br />
                <span className="link label ml-0">{server.version}</span>
            </p>
        </div>
    );
};
