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
    <aside className='navigation-panel navigation-panel__sidebar sidebar'>
      <div>
        <h1 style={{
          color: '#626982',
          fontFeatureSettings: "'liga' off, 'clig' off",
          fontSize: '11px',
          paddingInline: '16px',
          marginBlockEnd: '16px'
        }}>
          <a style={{ color: 'inherit', textDecoration: 'none' }} target='_blank' href='https://home.channel.org/' rel='noopener'>Channel.org</a> is one of the many independent servers you can use to participate in theFediverse.
        </h1>
        <div className='navigation-panel__logo' style={{ paddingInline: 16 }}>
          <Link to='/' className='nav-header'>
            {(subdomain === 'news') ? <img width='175px' src='./temp-images/newsmast.png' alt='news logo' /> : subdomain === 'informationtechnology' ? <img width='150px' alt='information technology logo' src='./temp-images/binarylab.png' /> : logo_image ? <img src={logo_image} width={140} style={{ aspectRatio: '36 / 10' }} alt='channel logo' /> : channel_display_name}
          </Link>
        </div>
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

          <p className='powered-by'>Powered by</p>
          <a href='https://home.channel.org/' target='_blank' rel='noopener'>
            <img src={channelOrgImage} alt='channel org' />
          </a>
          <p style={{
            color: 'rgba(255, 255, 255, 0.70)',
            fontSize: '14px',
            marginBlock: '20px'
          }}>© {new Date().getFullYear()} Channel.org</p>

          <div style={{
            display: 'flex',
            flexDirection: 'column',
            gap: '16px'
          }}>
            <p style={{
              fontSize: '11px',
              color: '#fff',
              fontFeatureSettings: "'liga' off, 'clig' off",
            }}>
              Channel.org is a safe space where you can create and curate Channel Feeds, distributed across the Fediverse, Bluesky and the wider web through RSS.
            </p>

            <div style={{
              display: 'flex',
              justifyContent: 'space-between'
            }}>
              <div style={{
                display: 'flex',
                flexDirection: 'column',
                gap: '8px'
              }}>
                <p style={{
                  color: '#626982',
                  textTransform: 'uppercase',
                  fontSize: '11px',
                  fontWeight: 700
                }}>Contact</p>
                <a style={{
                  color: '#fff',
                  fontSize: '12px',
                  fontFeatureSettings: "'liga' off, 'clig' off",
                  fontWeight: 700,
                  textDecoration: 'none'
                }} href='mailto:support@channel.org'>support@channel.org</a>
              </div>
              <div style={{
                display: 'flex',
                flexDirection: 'column',
                gap: '8px'
              }}>
                <p style={{
                  color: '#626982',
                  textTransform: 'uppercase',
                  fontSize: '11px',
                  fontWeight: 700
                }}>Users</p>
                <p style={{
                  paddingInlineEnd: '16px',
                  fontSize: '12px',
                  color: '#fff',
                  fontWeight: 700,
                  fontFeatureSettings: "'liga' off, 'clig' off",
                }}>
                  475 <span style={{
                    fontSize: '11.5px',
                    color: '#626982',
                    fontWeight: 400
                  }}>active users</span>
                </p>
              </div>
            </div>

            <a href='/#' style={{
              display: 'flex',
              justifyContent: 'center',
              alignItems: 'center',
              fontSize: '11px',
              color: '#fff',
              fontWeight: 700,
              fontFeatureSettings: "'liga' off, 'clig' off",
              border: '1px solid #fff',
              borderRadius: '3px',
              paddingBlock: '10px',
              textDecoration: 'none',
            }}>
              Learn more
            </a>
          </div>
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
