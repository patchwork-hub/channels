
import { formatNumber, pluralize } from "mastodon/utils/format_numbert";
import { Icon } from 'mastodon/components/icon';
import ArrowRightUpAltIcon from '@/material-icons/400-24px/arrow_right_up_red?.svg?react';
import { browserHistory } from "./router";

const imgs = [
  "https://s3-eu-west-2.amazonaws.com/patchwork-prod/collections/avatar_images/000/000/001/original/cropped-image.jpg?1734719920",
  "https://s3-eu-west-2.amazonaws.com/patchwork-prod/collections/avatar_images/000/000/002/original/cropped-image.jpg?1734720033",
  "https://s3-eu-west-2.amazonaws.com/patchwork-prod/collections/avatar_images/000/000/003/original/cropped-image.jpg?1734720221",
  "https://s3-eu-west-2.amazonaws.com/patchwork-prod/collections/avatar_images/000/000/004/original/cropped-image.jpg?1734766791",
]


const CollectionCard = ({ channel }) => {
  const count = channel.attributes?.community_count;
  const label = pluralize(count, 'Channel', 'Channels');

  const goToDetail = () => {
    const queryString = `?slug=${encodeURIComponent(channel.attributes.slug)}`;
    browserHistory.push(`/collections/${channel.attributes.name.toLowerCase()}${queryString}`);
  }

  return (

    <div className='card' onClick={goToDetail}>
      {(channel.attributes.avatar_image_url ?? "").startsWith("https") ? (
        <img
          src={channel.attributes.avatar_image_url}
          alt={channel.attributes.name}
          className='image' />
      ) : (
        <div style={{
          display: 'grid',
          gridTemplateColumns: 'repeat(2,1fr)'
        }}>
          {imgs.map(it => <div style={{
            display: 'flex',
            backgroundImage: `url(${it})`,
            backgroundSize: 'cover',
            backgroundRepeat: 'no-repeat'
          }}></div>)}
        </div>
      )}
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
