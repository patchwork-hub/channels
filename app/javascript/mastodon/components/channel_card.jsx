import { formatNumber, pluralize } from '../utils/format_numbert';
// import { Icon } from 'mastodon/components/icon';
// import ArrowRightUpAltIcon from '@/material-icons/400-24px/arrow_right_up_red?.svg?react';

const ChannelCard = ({ channel, isFourTiles }) => {
  const count = channel.attributes?.follower;
  const label = pluralize(count, 'follower', 'followers');

  return (
    <a style={{ width: '100%' }} target='_blank' href={`https://${channel?.attributes?.domain_name}/public`}>
      <div className='card'>
        <img
          src={channel.attributes.avatar_image_url}
          alt={channel.attributes.name}
          className='image' />
        <div className='overlay' />
        <div className='info'>
          <p className='info__detail'>
            <span className='title'>{channel.attributes.name}</span>
            <span className='subtitle'>{formatNumber(count)} {label}</span>
          </p>
          {/* <Icon icon={ArrowRightUpAltIcon} id={''} className='icon' /> */}
        </div>
      </div>
    </a>
  );
};

export default ChannelCard;
