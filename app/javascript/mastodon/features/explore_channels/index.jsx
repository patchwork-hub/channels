import ArrowRightUpAltIcon from '@/material-icons/400-24px/arrow_right_up_red?.svg?react';
import { Icon } from 'mastodon/components/icon';
import { Link } from 'react-router-dom';
const channels = [
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
  {
    title: 'Science',
    subtitle: 'Curated',
    imgSrc: 'temp-images/science.jpg',
    link: 'https://science.channel.org/public',
  },
];

const ExploreChannels = () => {
  return (
    <div className='channels'>
      <div className='channels__header'>
        <h2 className='title'>Explore channels</h2>
        <div className='text'>
          Explore the power of Channel.org through our five demo channels
        </div>
      </div>
      <div className='channels__list'>
        {channels.map((channel, index) => (
          <a key={index} target='_blank' href={channel.link}>
            <div className='card'>
              <img src={channel.imgSrc} alt={channel.title} className='image' />
              <div className='overlay' />
              <div className='info'>
                <p className='info__detail'>
                  <span className='title'>{channel.title}</span>
                  <span className='subtitle'>{channel.subtitle}</span>
                </p>
                <Icon icon={ArrowRightUpAltIcon} id={''} className='icon' />
              </div>
            </div>
          </a>
        ))}
      </div>
    </div>
  );
};

export default ExploreChannels;
