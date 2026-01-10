import { useEffect, useState, useCallback } from 'react';

import { Helmet } from 'react-helmet';

import { useDispatch, useSelector } from 'react-redux';

import {
  fetchChannels,
  fetchSearchedChannels,
  fetchNewsmastChannels,
  fetchChannelFeeds,
} from 'mastodon/actions/channel_banner';
import CollectionCard from '../../components/collection_card';
import ChannelCard from '@/mastodon/components/channel_card';
import { LoadingIndicator } from '@/mastodon/components/loading_indicator';

import ChannelSearch from '../channel_search';

const Collections = () => {
  const dispatch = useDispatch();
  const [searchTerm, setSearchTerm] = useState('');

  const collections = useSelector((state) =>
    state.recommended_channels.get('items'),
  );
  const channel_feeds = useSelector((state) =>
    state.channel_feeds.get('items'),
  );
  const newsmast_channels = useSelector((state) =>
    state.newsmast_channels.get('items'),
  );
  const collectionsLoading = useSelector((state) =>
    state.recommended_channels.get('isLoading'),
  );
  const searchChannels = useSelector((state) =>
    state.getIn(['search_channels', 'items']).toJS(),
  );

  const searchChannelsLoading = useSelector((state) =>
    state.getIn(['search_channels', 'isLoading']),
  );

  const images = {
    communities:
      'https://s3-eu-west-2.amazonaws.com/patchwork-prod/collections/banner_images/000/000/001/original/cropped-image.jpg?1734719920',
    newsmast:
      'https://s3-eu-west-2.amazonaws.com/patchwork-prod/collections/banner_images/000/000/003/original/cropped-image.jpg?1734720221',
    channels:
      'https://s3-eu-west-2.amazonaws.com/patchwork-prod/collections/banner_images/000/000/001/original/cropped-image.jpg?1734719920',
  };

  const channels = searchTerm
    ? searchChannels
    : [
        channel_feeds?.size > 0 ? channel_feeds.get(0) : null,
        newsmast_channels?.size > 0 ? newsmast_channels.get(0) : null,
        collections?.size > 0 ? collections.get(0) : null,
      ].filter((item) => item !== null);

  const isLoading = searchTerm ? searchChannelsLoading : collectionsLoading;

  const collectionsTiles =
    collections?.size > 0
      ? {
          tiles: [
            collections.get(1)?.attributes?.avatar_image_url.startsWith('https')
              ? collections.get(1)?.attributes?.avatar_image_url
              : images.channels,
            collections.get(2)?.attributes?.avatar_image_url.startsWith('https')
              ? collections.get(2)?.attributes?.avatar_image_url
              : images.channels,
            collections.get(3)?.attributes?.avatar_image_url.startsWith('https')
              ? collections.get(3)?.attributes?.avatar_image_url
              : images.channels,
            collections.get(4)?.attributes?.avatar_image_url.startsWith('https')
              ? collections.get(4)?.attributes?.avatar_image_url
              : images.channels,
          ],
          collection: true,
          channel: false,
          newsmast: false,
        }
      : { tiles: [], collection: true, channel: false, newsmast: false };

  const channelsTiles =
    channel_feeds?.size > 0
      ? {
          tiles: [
            channel_feeds
              .get(1)
              ?.attributes?.avatar_image_url.startsWith('https')
              ? channel_feeds.get(1)?.attributes?.avatar_image_url
              : images.channels,
            channel_feeds
              .get(2)
              ?.attributes?.avatar_image_url.startsWith('https')
              ? channel_feeds.get(2)?.attributes?.avatar_image_url
              : images.channels,
            channel_feeds
              .get(3)
              ?.attributes?.avatar_image_url.startsWith('https')
              ? channel_feeds.get(3)?.attributes?.avatar_image_url
              : images.channels,
            channel_feeds
              .get(4)
              ?.attributes?.avatar_image_url.startsWith('https')
              ? channel_feeds.get(4)?.attributes?.avatar_image_url
              : images.channels,
          ],
          collection: false,
          channel: true,
          newsmast: false,
        }
      : { tiles: [], collection: false, channel: true, newsmast: false };

  const newsmastTiles =
    newsmast_channels?.size > 0
      ? {
          tiles: [
            newsmast_channels
              .get(1)
              ?.attributes?.avatar_image_url.startsWith('https')
              ? newsmast_channels.get(1)?.attributes?.avatar_image_url
              : images.channels,
            newsmast_channels
              .get(2)
              ?.attributes?.avatar_image_url.startsWith('https')
              ? newsmast_channels.get(2)?.attributes?.avatar_image_url
              : images.channels,
            newsmast_channels
              .get(3)
              ?.attributes?.avatar_image_url.startsWith('https')
              ? newsmast_channels.get(3)?.attributes?.avatar_image_url
              : images.channels,
            newsmast_channels
              .get(4)
              ?.attributes?.avatar_image_url.startsWith('https')
              ? newsmast_channels.get(4)?.attributes?.avatar_image_url
              : images.channels,
          ],
          collection: false,
          channel: false,
          newsmast: true,
        }
      : { tiles: [], collection: false, channel: false, newsmast: true };

  const handleSearch = useCallback(
    (term) => {
      setSearchTerm(term);
      if (term.trim()) {
        dispatch(fetchSearchedChannels(term));
      } else {
        dispatch(fetchChannels());
        dispatch(fetchNewsmastChannels());
        dispatch(fetchChannelFeeds());
      }
    },
    [dispatch],
  );

  const renderChannelCard = useCallback(
    (channel, index) => {
      if (channel.type === 'channel') {
        return <ChannelCard key={index} channel={channel} isFourTiles />;
      } else {
        return (
          <CollectionCard
            key={index}
            channel={channel}
            type='all'
            from='community'
            isFourTiles
            collections={collectionsTiles}
            channel_feeds={channelsTiles}
            newsmast_channels={newsmastTiles}
          />
        );
      }
    },
    [collectionsTiles, channelsTiles, newsmastTiles],
  );

  useEffect(() => {
    if (
      !searchTerm &&
      (collections.size === 0 ||
        newsmast_channels.size === 0 ||
        channel_feeds.size === 0) &&
      !collectionsLoading
    ) {
      dispatch(fetchChannels());
      dispatch(fetchNewsmastChannels());
      dispatch(fetchChannelFeeds());
    }
  }, [
    searchTerm,
    collections,
    newsmast_channels,
    collectionsLoading,
    channel_feeds,
    dispatch,
  ]);
  return (
    <div className='channels'>
      <Helmet>
        <title>Explore channels</title>
      </Helmet>
      <div className='channels__header'>
        <h2 className='title'>Explore channels </h2>
        <ChannelSearch
          onSearch={handleSearch}
          isLoading={searchChannelsLoading}
        />
      </div>
      {searchChannelsLoading || isLoading ? (
        <div className='channels__loading'>
          <LoadingIndicator />
        </div>
      ) : !searchTerm && channels.length === 0 ? (
        <div
          style={{
            display: 'flex',
            justifyContent: 'center',
            alignItems: 'center',
            height: '60vh',
          }}
        >
          <p style={{ fontSize: '20px' }}>No channels found</p>
        </div>
      ) : channels.length === 0 ? (
        <div
          style={{
            display: 'flex',
            justifyContent: 'center',
            alignItems: 'center',
            height: '60vh',
          }}
        >
          <p style={{ fontSize: '20px' }}>No channels found</p>
        </div>
      ) : (
        <div className='channels__list'>{channels.map(renderChannelCard)}</div>
      )}
    </div>
  );
};

export default Collections;
