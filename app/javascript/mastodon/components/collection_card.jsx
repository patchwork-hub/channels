import { formatNumber, pluralize } from '../utils/format_numbert';
import { Icon } from 'mastodon/components/icon';
import ArrowRightUpRed from '@/material-icons/400-24px/arrow_right_up_red.svg?react';
import { browserHistory } from 'mastodon/components/router';

const images = {
  communities:
    'https://s3-eu-west-2.amazonaws.com/patchwork-prod/collections/banner_images/000/000/001/original/cropped-image.jpg?1734719920',
  newsmast:
    'https://s3-eu-west-2.amazonaws.com/patchwork-prod/collections/banner_images/000/000/003/original/cropped-image.jpg?1734720221',
  channels:
    'https://s3-eu-west-2.amazonaws.com/patchwork-prod/collections/banner_images/000/000/001/original/cropped-image.jpg?1734719920',
};

const CollectionCard = ({
  channel,
  type,
  from,
  isFourTiles = false,
  collections = {},
  channel_feeds = {},
  newsmast_channels = {},
}) => {
  const count = channel?.attributes?.community_count ?? 0;
  const label = pluralize(count, 'Channel', 'Channels');
  const path =
    type === 'newsmast'
      ? 'newsmasts'
      : type === 'channel'
        ? 'channels'
        : 'collections';

  const getExternalUrlFromHandle = (handle) => {
    if (!handle || typeof handle !== 'string') return null;

    const parts = handle.split('@');
    if (parts.length < 3) return null;

    const username = parts[1];
    const domain = parts[2];

    return `https://${domain}/@${username}`;
  };

  const goToDetail = () => {
    const queryString = `?slug=${encodeURIComponent(channel?.attributes?.slug || '')}`;

    if (!channel || !channel.attributes) {
      console.error('Invalid channel data');
      return;
    }

    const { name, community_admin } = channel.attributes;
    const handle = community_admin?.username;
    const externalUrl = getExternalUrlFromHandle(handle);

    if (type === 'newsmast' || type === 'channel') {
      const basePath =
        type === 'newsmast'
          ? 'newsmasts/newsmast-channels'
          : 'channels/channels';
      browserHistory.replace(`/${basePath}?slug=all-collection`);

      if (externalUrl) {
        window.open(externalUrl, '_blank');
      } else if (channel.attributes.domain_name && handle) {
        const fallbackUrl = `https://${channel.attributes.domain_name}/${handle}`;
        window.open(fallbackUrl, '_blank');
      }
      return;
    }

    if (type === 'all') {
      if (name === 'Communities') {
        browserHistory.push(`/collections/communities?slug=all-collection`);
      } else if (name === 'Newsmast Channels') {
        browserHistory.push(`/newsmasts/newsmast-channels?slug=all-collection`);
      } else if (name === 'Channels') {
        browserHistory.push(`/channels/channels?slug=all-collection`);
      }
      return;
    }

    browserHistory.push(`/${path}/${name.toLowerCase()}${queryString}`);
  };

  const hasImage = (channel) =>
    (channel?.attributes?.avatar_image_url ?? '').startsWith('https');

  return (
    <div
      className={`card ${hasImage(channel) ? '' : 'bg-grid'}`}
      onClick={goToDetail}
    >
      {hasImage(channel) && !isFourTiles ? (
        <img
          src={
            hasImage(channel)
              ? channel.attributes.avatar_image_url
              : images.newsmast
          }
          alt={channel.attributes.name}
          className='image'
        />
      ) : null}

      {isFourTiles && channel?.attributes?.name === 'Communities' && (
        <div
          style={{
            display: 'flex',
            alignItems: 'flex-end',
            width: '155px',
            height: '155px',
            padding: '10px',
            borderRadius: '10px',
            background: `
            linear-gradient(180deg, rgba(43, 43, 43, 0.00) 0%, rgba(37, 37, 37, 0.60) 56.93%),
            url(${collections.tiles[0]}) 0% 0% / 50% 50% no-repeat,
            url(${collections.tiles[1]}) 100% 0% / 50% 50% no-repeat,
            url(${collections.tiles[2]}) 0% 100% / 50% 50% no-repeat,
            url(${collections.tiles[3]}) 100% 100% / 50% 50% no-repeat
          `,
          }}
        />
      )}

      {isFourTiles && channel?.attributes?.name === 'Channels' && (
        <div
          style={{
            display: 'flex',
            alignItems: 'flex-end',
            width: '155px',
            height: '155px',
            padding: '10px',
            borderRadius: '10px',
            background: `
                  linear-gradient(180deg, rgba(43, 43, 43, 0.00) 0%, rgba(37, 37, 37, 0.60) 56.93%),
                  url(${channel_feeds.tiles[0]}) 0% 0% / 50% 50% no-repeat,
                  url(${channel_feeds.tiles[1]}) 100% 0% / 50% 50% no-repeat,
                  url(${channel_feeds.tiles[2]}) 0% 100% / 50% 50% no-repeat,
                  url(${channel_feeds.tiles[3]}) 100% 100% / 50% 50% no-repeat
                `,
          }}
        />
      )}

      {isFourTiles && channel?.attributes?.name === 'Newsmast Channels' && (
        <div
          style={{
            display: 'flex',
            alignItems: 'flex-end',
            width: '155px',
            height: '155px',
            padding: '10px',
            borderRadius: '10px',
            background: `
                  linear-gradient(180deg, rgba(43, 43, 43, 0.00) 0%, rgba(37, 37, 37, 0.60) 56.93%),
                  url(${newsmast_channels.tiles[0]}) 0% 0% / 50% 50% no-repeat,
                  url(${newsmast_channels.tiles[1]}) 100% 0% / 50% 50% no-repeat,
                  url(${newsmast_channels.tiles[2]}) 0% 100% / 50% 50% no-repeat,
                  url(${newsmast_channels.tiles[3]}) 100% 100% / 50% 50% no-repeat
                `,
          }}
        />
      )}
      <div className='overlay' />
      <div className='info'>
        <p className='info__detail'>
          <span className='title'>
            {channel?.attributes?.name || 'Unnamed'}
          </span>
          {type === 'newsmast' || type === 'channel'
            ? null
            : from === 'community' && (
                <span className='subtitle'>
                  {formatNumber(count)} {label}
                </span>
              )}
        </p>

        <Icon
          icon={ArrowRightUpRed}
          id={''}
          style={{
            color: '#ff3c26',
            paddingRight: '10px',
            width: '13px',
            height: '13px',
          }}
        />

        {/* <Icon icon={ArrowRightUpAltIcon} id='' className='icon' /> */}
      </div>
    </div>
  );
};

export default CollectionCard;
