import { defineMessages, useIntl } from 'react-intl';

import FeedIcon from '@/material-icons/400-24px/feed_icon.svg?.react';
import { custom_links } from 'mastodon/initial_state';

import ColumnLink from './column_link';
import { icons } from './navIcons';
import { ServerInformation } from './server_information';
import { Logo } from './logo';

const messages = defineMessages({
  home: { id: 'tabs_bar.home', defaultMessage: 'Home' },
  notifications: {
    id: 'tabs_bar.notifications',
    defaultMessage: 'Notifications',
  },
  blog: { id: 'blog.title', defaultMessage: 'Blog' },
  explore: { id: 'explore.title', defaultMessage: 'Explore' },
  feed: { id: 'feed.title', defaultMessage: 'Feed' },
  podcast: { id: 'podcast.title', defaultMessage: 'Podcast' },
  chat: { id: 'chat.title', defaultMessage: 'Chat/Forum' },
  website: { id: 'globe.title', defaultMessage: 'Website' },
  rss: { id: 'rss.title', defaultMessage: 'RSS Feed' },
  bluesky: { id: 'bluesky.title', defaultMessage: 'Bluesky Account' },
  thread: { id: 'thread.title', defaultMessage: 'Threads Account' },
});

const Navigations = () => {

  const intl = useIntl();
  const navItems = custom_links && typeof custom_links === 'string' ? JSON.parse(custom_links) : custom_links;

  return (
    <aside className='navigation-panel navigation-panel__sidebar sidebar'>
      <div>
        <Logo />
        <div className='nav-links'>
          <ColumnLink
            transparent
            to='/public'
            icon='feed'
            badge
            iconComponent={FeedIcon}
            activeIconComponent={FeedIcon}
            text={intl.formatMessage(messages.feed)}
          />
          {
            Object.values(navItems).map((it, index) => (
              <ColumnLink
                key={index}
                badge
                transparent
                href={it.url}
                icon={it.icon}
                target='_blank'
                iconComponent={icons[it.icon]}
                activeIconComponent={icons[it.icon]}
                text={it.name}
              />
            ))}
        </div>

        <footer className='footer'>
          <ul>
            <li>
              <a
                href='https://channel.org/terms/'
                target='_blank'
                className='footer-link' rel='noopener'
              >
                Terms & Conditions
              </a>
            </li>
            <li>
              <a
                href='https://channel.org/privacy-policy/'
                target='_blank'
                className='footer-link' rel='noopener'
              >
                Privacy Policy
              </a>
            </li>
            <li>
              <a
                href='https://github.com/patchwork-hub/'
                target='_blank'
                className='footer-link' rel='noopener'
              >
                Source Code
              </a>
            </li>
          </ul>

          <ServerInformation />
        </footer>
      </div>
      <div className='navigation-panel__sidebar__bottom'>
        <p>
          <a href="https://channel.org/public" className="link label ml-0">channel.org: </a>
          <a href="#" className="link underline">About</a><span>·</span>
          <a href="https://home.channel.org/search" className="link underline">Channel Directory</a><span>·</span>
          <a href="#" className="link underline">Get the App</a><span>·</span>
          <a href="#" className="link underline">Privacy Policy</a>
          <a href="https://github.com/patchwork-hub/channels/" className="link underline">View source code</a>
        </p>

        <p>
          <a href="#" className="link label ml-0">Mastodon: </a>
          <a href="https://joinmastodon.org/" className="link underline">About</a><span>·</span>
          <a href="https://github.com/mastodon/mastodon" className="link underline">View source code</a>
        </p>
      </div>
    </aside>
  );
};

export default Navigations;
