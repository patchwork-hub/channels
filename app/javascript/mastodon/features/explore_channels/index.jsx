import ArrowRightUpAltIcon from '@/material-icons/400-24px/arrow_right_up_red?.svg?react';
import { Icon } from 'mastodon/components/icon';
import { useSelector } from 'react-redux';

const ExploreChannels = () => {

  const channels = useSelector(state => state.recommended_channels.get('items'));

  return (
    <div className='channels'>
      <div className='channels__header'>
        <h2 className='title'>Explore channels</h2>
        <div className='text'>
          Explore the power of Channel.org through our demo channels
        </div>
      </div>
      <div className='channels__list'>
        {channels.map((channel, index) => (
          <a key={index} target='_blank' href={'https://' + channel.attributes.domain_name}>
            <div className='card'>
              <img
                src={channel.attributes.avatar_image_url}
                alt={channel.attributes.name}
                className='image' />
              <div className='overlay' />
              <div className='info'>
                <p className='info__detail'>
                  <span className='title'>{channel.attributes.name}</span>
                  <span className='subtitle'>{channel.attributes.community_type.data.attributes.name}</span>
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
