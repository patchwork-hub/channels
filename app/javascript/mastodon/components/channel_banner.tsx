import ArrowRightUpAltIcon from '@/material-icons/400-24px/arrow_right_up_red?.svg?react';
import { Icon } from 'mastodon/components/icon';
import { Link } from 'react-router-dom';

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
    link: 'https://newsmast.channel.org/public',
  },
  {
    title: 'WeDistribute',
    subtitle: 'Multi-platform',
    imgSrc: 'temp-images/wedistribute.jpg',
    link: 'https://wedistribute.channel.org/public',
  },
  {
    title: 'FediForum',
    subtitle: 'Multi-contributor',
    imgSrc: 'temp-images/mastodon.jpg',
    link: 'https://fediforum.channel.org/public',
  },
  {
    title: 'KamalaHarrisWin',
    subtitle: 'Group',
    imgSrc: 'temp-images/kamala.jpg',
    link: 'https://kamalaharriswin.channel.org/public',
  },
];

const ChannelBanner = () => {
  return (
    <div className='explore-channels'>
      <div className='header'>
        <h2 className='channel-header'>Explore channels</h2>
        <button className='see-all'>See all</button>
      </div>
      <div className='channel-grid'>
        {channels.map((channel, index) => (
          <a key={index} target='_blank' href={channel.link}>
            <div className='channel-card'>
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
            </div>
          </a>
        ))}
      </div>
    </div>
  );
};

export default ChannelBanner;
