
import { formatNumber, pluralize } from "mastodon/utils/format_numbert";
import { Icon } from 'mastodon/components/icon';
import ArrowRightUpAltIcon from '@/material-icons/400-24px/arrow_right_up_red?.svg?react';

const CollectionCard = ({ channel }) => {
  const count = channel.attributes?.community_count;
  const label = pluralize(count, 'Channel', 'Channels');

  return (
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
          <Icon icon={ArrowRightUpAltIcon} id={''} className='icon' />
        </div>
      </div>
  );
};

export default CollectionCard;
