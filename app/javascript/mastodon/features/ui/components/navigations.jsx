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
  firehose: { id: 'column.firehose', defaultMessage: 'Live feeds' },
  direct: { id: 'navigation_bar.direct', defaultMessage: 'Private mentions' },
  favourites: { id: 'navigation_bar.favourites', defaultMessage: 'Favorites' },
  bookmarks: { id: 'navigation_bar.bookmarks', defaultMessage: 'Bookmarks' },
  lists: { id: 'navigation_bar.lists', defaultMessage: 'Lists' },
  preferences: {
    id: 'navigation_bar.preferences',
    defaultMessage: 'Preferences',
  },
  followsAndFollowers: {
    id: 'navigation_bar.follows_and_followers',
    defaultMessage: 'Follows and followers',
  },
  about: { id: 'navigation_bar.about', defaultMessage: 'About' },
  search: { id: 'navigation_bar.search', defaultMessage: 'Search' },
  advancedInterface: {
    id: 'navigation_bar.advanced_interface',
    defaultMessage: 'Open in advanced web interface',
  },
  openedInClassicInterface: {
    id: 'navigation_bar.opened_in_classic_interface',
    defaultMessage:
      'Posts, accounts, and other specific pages are opened by default in the classic web interface.',
  },
  followRequests: {
    id: 'navigation_bar.follow_requests',
    defaultMessage: 'Follow requests',
  },
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
          to='/explore'
          icon='explore'
          iconComponent={SearchIcon}
          activeIconComponent={SearchIcon}
          text={intl.formatMessage(messages.explore)}
        />
        <ColumnLink
          transparent
          to='/blog'
          icon='blog'
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
          to='/website'
          icon='website'
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

      {/* <nav className='nav'>
        <ul>
          <li>
            <NavLink
              to='/explore'
              className={({ isActive }) =>
                isActive ? 'nav-item active' : 'nav-item'
              }
            >
              Explore
            </NavLink>
          </li>
          <li>
            <NavLink
              to='/blog'
              className={({ isActive }) =>
                isActive ? 'nav-item active' : 'nav-item'
              }
            >
              <span className='icon'>✍️</span> Blog
            </NavLink>
          </li>
          <li>
            <NavLink
              to='/podcast'
              className={({ isActive }) =>
                isActive ? 'nav-item active' : 'nav-item'
              }
            >
              <span className='icon'>🎙️</span> Podcast
            </NavLink>
          </li>
          <li>
            <NavLink
              to='/chat'
              className={({ isActive }) =>
                isActive ? 'nav-item active' : 'nav-item'
              }
            >
              <span className='icon'>💬</span> Chat/Forum
            </NavLink>
          </li>
          <li>
            <NavLink
              to='/website'
              className={({ isActive }) =>
                isActive ? 'nav-item active' : 'nav-item'
              }
            >
              <span className='icon'>🌐</span> Website
            </NavLink>
          </li>
          <li>
            <NavLink
              to='/rss'
              className={({ isActive }) =>
                isActive ? 'nav-item active' : 'nav-item'
              }
            >
              <span className='icon'>📡</span> RSS Feed
            </NavLink>
          </li>
          <li>
            <NavLink
              to='/bluesky'
              className={({ isActive }) =>
                isActive ? 'nav-item active' : 'nav-item'
              }
            >
              <span className='icon'>🦋</span> Bluesky Account
            </NavLink>
          </li>
          <li>
            <NavLink
              to='/threads'
              className={({ isActive }) =>
                isActive ? 'nav-item active' : 'nav-item'
              }
            >
              <span className='icon'>⚡</span> Threads Account
            </NavLink>
          </li>
        </ul>
      </nav> */}

      <footer className='footer'>
        <ul>
          <li>
            <NavLink to='/terms' className='footer-link'>
              Terms & Conditions
            </NavLink>
          </li>
          <li>
            <NavLink to='/privacy' className='footer-link'>
              Privacy Policy
            </NavLink>
          </li>
          <li>
            <NavLink to='/source' className='footer-link'>
              Source Code
            </NavLink>
          </li>
        </ul>
        <p>© {new Date().getFullYear()} Patchwork</p>
      </footer>
    </aside>
  );
};

export default Navigations;
