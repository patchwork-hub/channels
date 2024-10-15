import { defineMessages, injectIntl, useIntl } from 'react-intl';
import { Link } from 'react-router-dom';
import { NavLink } from 'react-router-dom';
import ColumnLink from './column_link';
import HomeActiveIcon from '@/material-icons/400-24px/home-fill.svg?react';
import HomeIcon from '@/material-icons/400-24px/home.svg?react';
import SearchIcon from '@/material-icons/400-24px/search.svg?react';
import PenIcon from '@/material-icons/400-24px/pen_icon.svg?react';
import PodcastIcon from '@/material-icons/400-24px/podcast.svg?react';
import ChatIcon from '@/material-icons/400-24px/chat.svg?react';
import WebsiteIcon from '@/material-icons/400-24px/website_icon.svg?react';
import RssFeedIcon from '@/material-icons/400-24px/rss_feed.svg?react';
import ButterflyIcon from '@/material-icons/400-24px/butterfly.svg?react';
import ThreadIcon from '@/material-icons/400-24px/thread.svg?react';

const messages = defineMessages({
  home: { id: 'tabs_bar.home', defaultMessage: 'Home' },
  notifications: {
    id: 'tabs_bar.notifications',
    defaultMessage: 'Notifications',
  },
  blog: { id: 'blog.title', defaultMessage: 'Blog' },
  explore: { id: 'explore.title', defaultMessage: 'Explore' },
  podcast: { id: 'podcast.title', defaultMessage: 'Podcast' },
  chat: { id: 'chat.title', defaultMessage: 'Chat/Forum' },
  website: { id: 'globe.title', defaultMessage: 'Website' },
  rss: { id: 'rss.title', defaultMessage: 'RSS Feed' },
  bluesky: { id: 'bluesky.title', defaultMessage: 'Bluesky Account' },
  thread: { id: 'thread.title', defaultMessage: 'Threads Account' },
});

const Navigations = () => {
  const intl = useIntl();
  return (
    <aside className='navigation-panel sidebar'>
      <div className='navigation-panel__logo'>
        <Link to='/' className='column-link column-link--logo nav-header'>
          Channel.org
        </Link>
      </div>
      <div className='nav-links'>
        <ColumnLink
          transparent
          to='/explore-channels'
          icon='explore-channels'
          iconComponent={SearchIcon}
          activeIconComponent={SearchIcon}
          text={intl.formatMessage(messages.explore)}
        />
        <ColumnLink
          transparent
          href='https://www.blog-pat.ch/'
          icon='blog'
          target='_blank'
          iconComponent={PenIcon}
          activeIconComponent={PenIcon}
          text={intl.formatMessage(messages.blog)}
        />
        <ColumnLink
          transparent
          to='/podcast'
          icon='podcast'
          iconComponent={PodcastIcon}
          activeIconComponent={PodcastIcon}
          text={intl.formatMessage(messages.podcast)}
        />
        <ColumnLink
          transparent
          to='/chat'
          icon='chat'
          iconComponent={ChatIcon}
          activeIconComponent={ChatIcon}
          text={intl.formatMessage(messages.chat)}
        />
        <ColumnLink
          transparent
          href='https://home.channel.org/'
          icon='website'
          target='_blank'
          iconComponent={WebsiteIcon}
          activeIconComponent={WebsiteIcon}
          text={intl.formatMessage(messages.website)}
        />
        <ColumnLink
          transparent
          to='/rss-feed'
          icon='rss-feed'
          iconComponent={RssFeedIcon}
          activeIconComponent={RssFeedIcon}
          text={intl.formatMessage(messages.rss)}
        />
        <ColumnLink
          transparent
          to='/bluesky'
          icon='bluesky'
          iconComponent={ButterflyIcon}
          activeIconComponent={ButterflyIcon}
          text={intl.formatMessage(messages.bluesky)}
        />
        <ColumnLink
          transparent
          to='/thread'
          icon='thread'
          iconComponent={ThreadIcon}
          activeIconComponent={ThreadIcon}
          text={intl.formatMessage(messages.thread)}
        />
      </div>

      <footer className='footer'>
        <ul>
          <li>
            <NavLink to='/terms' className='footer-link'>
              Terms & Conditions
            </NavLink>
          </li>
          <li>
            <a href='https://channel.org/privacy-policy/' target='_blank' className='footer-link'>
              Privacy Policy
            </a>
          </li>
          <li>
            <a href='https://github.com/patchwork-hub/' target='_blank' className='footer-link'>
              Source Code
            </a>
          </li>
        </ul>
        <p>© {new Date().getFullYear()} Patchwork</p>
      </footer>
    </aside>
  );
};

export default Navigations;
