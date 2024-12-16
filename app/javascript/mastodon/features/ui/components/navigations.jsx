import { defineMessages, useIntl } from 'react-intl';
import { Link } from 'react-router-dom';
import ColumnLink from './column_link';
import FeedIcon from '@/material-icons/400-24px/feed_icon.svg?.react';
import channelOrgImage from '../../../../images/wide_channel_logo.svg';
import { channel_display_name, custom_links, logo_image } from 'mastodon/initial_state';
import { icons } from './navIcons';

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

  const subdomain = window.location.hostname.split('.')[0];
  return (
    <aside className='navigation-panel sidebar'>
      <div className='navigation-panel__logo' style={{ paddingInline:16 }}>
        <Link to='/' className='nav-header'>
          {(subdomain==='news') ? <img width='175px' src='./temp-images/newsmast.png' alt='news logo' />:subdomain==='informationtechnology'?<img width='150px' alt='information technology logo' src='./temp-images/binarylab.png' />:logo_image?<img src={logo_image} style={{ maxWidth:200 }} alt='channel logo' />:channel_display_name}
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
        <a href='https://home.channel.org/' target='_blank'>
          <img src={channelOrgImage} alt='channel org' />
        </a>
      </footer>
    </aside>
  );
};

export default Navigations;
