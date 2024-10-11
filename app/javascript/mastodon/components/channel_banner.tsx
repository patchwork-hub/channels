import React from 'react';
import ArrowRightUpAltIcon from '@/material-icons/400-24px/arrow_right_up_red?.svg?react';
import { Icon } from 'mastodon/components/icon';

// Define the types for a channel
interface Channel {
  title: string;
  subtitle: string;
  imgSrc: string;
  link: string;
}

// Mock data for channels
const channels: Channel[] = [
  {
    title: 'Newsmast',
    subtitle: 'Broadcast',
    imgSrc: 'temp-images/newsmast.jpg',
    link: '#',
  },
  {
    title: 'WeDistribute',
    subtitle: 'Multi-platform',
    imgSrc: 'temp-images/wedistribute.jpg',
    link: '#',
  },
  {
    title: 'FediForum',
    subtitle: 'Multi-contributor',
    imgSrc: 'temp-images/mastodon.jpg',
    link: '#',
  },
  {
    title: 'KamalaHarrisWin',
    subtitle: 'Group',
    imgSrc: 'temp-images/kamala.jpg',
    link: '#',
  },
];

const ChannelBanner: React.FC = () => {
  return (
    <div className='explore-channels'>
      <div className='header'>
        <h2 className='channel-header'>Explore channels</h2>
        <button className='see-all'>See all</button>
      </div>
      <div className='channel-grid'>
        {channels.map((channel, index) => (
          <div key={index} className='channel-card'>
            <img
              src={channel.imgSrc}
              alt={channel.title}
              className='channel-image'
            />
            <div className='channel-overlay' />
            <div className='channel__info'>
              <p className='channel__info-detail'>
                <span className='channel-title'>{channel.title}</span>
                <span className='channel-subtitle'>{channel.subtitle}</span>
              </p>
              <Icon
                icon={ArrowRightUpAltIcon}
                id={''}
                className='channel__info-icon'
              />
            </div>
            {/* <div className='channel-details'>
              <p className='channel-info'>
                <span className='channel-title'>{channel.title}</span>
                <span className='channel-subtitle'>{channel.subtitle}</span>
              </p>
              <a href={channel.link}>a</a>
            </div> */}
            {/* <div className='channel-info'>
              <h3>{channel.title}</h3>
              <p>{channel.subtitle}</p>
              <a href={channel.link} className='channel-link'>
                <span className='arrow-icon'>↗</span>
              </a>
            </div> */}
          </div>
        ))}
      </div>
    </div>
  );
};

export default ChannelBanner;
