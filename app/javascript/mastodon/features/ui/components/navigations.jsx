import { defineMessages, useIntl } from 'react-intl';
import { Link } from 'react-router-dom';
import ColumnLink from './column_link';
import PenIcon from '@/material-icons/400-24px/pen_icon.svg?react';
import FeedIcon from '@/material-icons/400-24px/feed_icon.svg?.react';
import PodcastIcon from '@/material-icons/400-24px/podcast.svg?react';
import ChatIcon from '@/material-icons/400-24px/chat.svg?react';
import WebsiteIcon from '@/material-icons/400-24px/website_icon.svg?react';
import RssFeedIcon from '@/material-icons/400-24px/rss_feed.svg?react';
import ButterflyIcon from '@/material-icons/400-24px/butterfly.svg?react';
import ThreadIcon from '@/material-icons/400-24px/thread.svg?react';
import channelOrgImage from '../../../../images/wide_channel_logo.svg';
import { custom_links } from 'mastodon/initial_state';

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
  const navItems = typeof custom_links === 'string' ? JSON.parse(custom_links) : custom_links;

  const icons = {
    "pen":PenIcon,
    "podcast":PodcastIcon,
    "chat":ChatIcon,
    "website":WebsiteIcon,
    "rss-feed":RssFeedIcon,
    "bluesky":ButterflyIcon,
    "thread":ThreadIcon
  }

  return (
    <aside className='navigation-panel sidebar'>
      <div className='navigation-panel__logo' style={{ paddingInline:16 }}>
        <Link to='/' className='nav-header'>
          Channel.org
        </Link>
      </div>
      <div className='nav-links'>
        <ColumnLink
          transparent
          to='/public'
          icon='feed'
          badge={true}
          iconComponent={FeedIcon}
          activeIconComponent={FeedIcon}
          text={intl.formatMessage(messages.feed)}
        />
        {
        Object.values(navItems).map((it,index)=>(
            <ColumnLink
                  key={index}
                  badge={true}
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
              href='https://channel.org/privacy-policy/'
              target='_blank'
              className='footer-link'
            >
              Privacy Policy
            </a>
          </li>
          <li>
            <a
              href='https://github.com/patchwork-hub/'
              target='_blank'
              className='footer-link'
            >
              Source Code
            </a>
          </li>
        </ul>

        <p className='powered-by'>Powered by</p>
        <img src={channelOrgImage} alt='channel org' />
      </footer>
    </aside>
  );
};

export default Navigations;
