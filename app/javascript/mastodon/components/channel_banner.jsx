import ArrowRightUpAltIcon from '@/material-icons/400-24px/arrow_right_up_red?.svg?react';
import { Icon } from 'mastodon/components/icon';
import { fetchChannels } from '../actions/channel_banner';
import { NavLink } from 'react-router-dom';
import { useDispatch, useSelector } from 'react-redux';
import { useEffect } from 'react';

const ChannelBanner = () => {

  const channels = useSelector(state => state.recommended_channels.get("items"));

  const dispatch = useDispatch();

  useEffect(() => {
    dispatch(fetchChannels());
  }, []);

  return (
    <div>
      <div className='explore-channels'>
        <div className='header'>
          <h2 className='channel-header'>Explore channels</h2>
          <NavLink to='/explore-channels' className='see-all'>
            See all
          </NavLink>
        </div>
        <div className='channel-grid'>
          {channels?.slice(0, 4).map((channel, index) => (
            <a key={index} target='_blank' href={'https://' + channel.attributes.domain_name}>
              <div className='channel-card'>
                <img
                  src={channel.attributes.avatar_image_url}
                  alt={channel.attributes.name}
                  className='channel-image'
                />
                <div className='channel-overlay' />
                <div className='channel__info'>
                  <p className='channel__info-detail'>
                    <span className='channel-title'>{channel.attributes.name}</span>
                    <span className='channel-subtitle'>{channel.attributes.community_type.data !== null ? channel.attributes.community_type.data.attributes.name : ''}</span>
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
    </div>
  );
};

export default ChannelBanner;
