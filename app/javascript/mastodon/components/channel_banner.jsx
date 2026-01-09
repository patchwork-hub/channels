
import { NavLink } from 'react-router-dom';
import { useDispatch, useSelector } from 'react-redux';
import { useEffect } from 'react';
import ArrowRightUpRed from '@/material-icons/400-24px/arrow_right_up_red.svg?react';
import { Icon } from 'mastodon/components/icon';
import { fetchChannelFeeds, fetchChannels, fetchNewsmastChannels } from '../actions/channel_banner';
import { browserHistory } from "./router";

const dummyImages = {
  communities: "https://s3-eu-west-2.amazonaws.com/patchwork-prod/collections/banner_images/000/000/001/original/cropped-image.jpg?1734719920",
  newsmast: "https://s3-eu-west-2.amazonaws.com/patchwork-prod/collections/banner_images/000/000/001/original/cropped-image.jpg?1734719920",
  channels: "https://s3-eu-west-2.amazonaws.com/patchwork-prod/collections/banner_images/000/000/001/original/cropped-image.jpg?1734719920"
};


const ChannelBanner = () => {
  const channel_feeds = useSelector(state => state.channel_feeds.get("items")?.toJS() || []);
  const newsmast_channels = useSelector(state => state.newsmast_channels.get("items")?.toJS() || []);
  const channels = useSelector(state => state.recommended_channels.get("items")?.toJS() || []);
  const dispatch = useDispatch();

  useEffect(() => {
    dispatch(fetchChannels());
    dispatch(fetchNewsmastChannels());
    // dispatch(fetchMyChannel());
    dispatch(fetchChannelFeeds());
  }, []);
  const navigateToDetail = (channel, basePath) => {
    const queryString = `?slug=${encodeURIComponent(channel.attributes.slug)}`;
    console.log(`Navigating to /${basePath}/${channel.attributes.name.toLowerCase()}${queryString}`);
    browserHistory.push(`/${basePath}/${channel.attributes.name.toLowerCase()}${queryString}`);
  };
  const getImageUrl = (channel, fallbackUrl) => {
    const url = channel?.attributes?.avatar_image_url;
    return url && typeof url === 'string' && url.startsWith("https") ? url : fallbackUrl;
  };

  const renderChannelSection = (data, title, imageUrl, basePath) => {
    const imageOne = getImageUrl(data?.[1], dummyImages.channels);
      const imageTwo = getImageUrl(data?.[2], dummyImages.channels);
      const imageThree = getImageUrl(data?.[3], dummyImages.channels);
      const imageFour = getImageUrl(data?.[4], dummyImages.channels);

    return data?.slice(0, 1).map((channel, index) => (
      <button
        key={index}
        onClick={() => navigateToDetail(channel, basePath)}
        style={{ 
          padding: 0, 
          border: 0, 
          background: 'transparent', 
          cursor: 'pointer' 
        }}
      >
        <div style={{
          display: 'flex',
          alignItems: 'flex-end',
          width: 'auto',
          height: '147px',
          padding: '10px',
          borderRadius: '10px',
          background: `
          linear-gradient(180deg, rgba(43, 43, 43, 0.00) 0%, rgba(37, 37, 37, 0.60) 56.93%),
        
          url(${imageOne}) 0% 0% / 175.5px 85px no-repeat,
          url(${imageTwo}) 100% 0% / 175.5px 85px no-repeat,
          url(${imageThree}) 0% 100% / 175.5px 85px no-repeat,
          url(${imageFour}) 100% 100% / 175.5px 85px no-repeat
        `,
        }}>
          <div style={{
            display: 'flex',
            alignItems: 'flex-end',
            justifyContent: 'space-between',
            width: '100%'
          }}>
            <div style={{ 
              display: 'flex', 
              flexDirection: 'column' 
            }}>
              <p style={{
                fontSize: '15px',
                fontWeight: 600,
                color: '#fff',
                letterSpacing: '0.15px',
                fontFamily: "'source-sans-pro', sans-serif",
                textAlign: 'start',
                margin: 0
              }}>{title}</p>
              <p style={{
                fontSize: '13px',
                fontWeight: 300,
                letterSpacing: '0.13px',
                color: '#fff',
                fontFamily: "'source-sans-pro', sans-serif",
                textAlign: 'start',
                margin: 0
              }}>{channel.attributes.community_count ?? 0} Channels</p>
            </div>
            <Icon
              icon={ArrowRightUpRed}
              id={''}
              style={{
                color: '#ff3c26',
                paddingRight: '10px',
                width: '13px',
                height: '13px'
              }}
            />
          </div>
        </div>
      </button>
    ));
  };

  return (
    <div className='channel-banner'>
      <div style={{ padding: '20px 0' }}>
        <div
          style={{
            display: 'flex',
            justifyContent: 'space-between',
            alignItems: 'center',
            marginBottom: '20px',
          }}
        >
          <h2
            style={{
              fontSize: '24px',
              fontWeight: 'bold',
              margin: 0,
            }}
          >
            Explore channels
          </h2>
          <NavLink to='/collections' className='see-all'>
            See all
          </NavLink>
        </div>

        <div
          style={{
            display: 'flex',
            flexDirection: 'column',
            gap: '10px',
          }}
        >
          {renderChannelSection(
            channel_feeds,
            'Channels',
            dummyImages.channels,
            'channels',
          )}
          {renderChannelSection(
            newsmast_channels,
            'Newsmast Channels',
            dummyImages.newsmast,
            'newsmasts',
          )}
          {renderChannelSection(
            channels,
            'Communities',
            dummyImages.communities,
            'collections',
          )}
        </div>

        {/* {signedIn && channelFeed && channelFeed.id && ( */}
        {false && (
          <a
            href='https://home.channel.org/create-channel'
            style={{
              marginTop: '20px',
              borderRadius: '8px',
              background: '#FF3C26',
              border: 'none',
              color: 'white',
              padding: '9px 15px',
              fontSize: '17px',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              textDecoration: 'none',
              gap: '10px',
            }}
          >
            <span style={{ fontSize: '25px' }}>+</span> Create channel
          </a>
        )}
      </div>
    </div>
  );
};

export default ChannelBanner;
