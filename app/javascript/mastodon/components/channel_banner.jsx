import ArrowRightUpAltIcon from '@/material-icons/400-24px/arrow_right_up_red?.svg?react';
import { Icon } from 'mastodon/components/icon';
import { fetchChannelFeeds, fetchChannels, fetchNewsmastChannels } from '../actions/channel_banner';
import { fetchMyChannel } from '../actions/my_channel';
import { NavLink } from 'react-router-dom';
import { useDispatch, useSelector } from 'react-redux';
import { useEffect } from 'react';
import { identityContextPropShape, withIdentity } from 'mastodon/identity_context';
import { browserHistory } from "./router";

// Dummy images
const dummyImages = {
  communities: "https://s3-eu-west-2.amazonaws.com/patchwork-prod/collections/banner_images/000/000/001/original/cropped-image.jpg?1734719920",
  newsmast: "https://s3-eu-west-2.amazonaws.com/patchwork-prod/collections/banner_images/000/000/003/original/cropped-image.jpg?1734720221",
  channels: "https://s3-eu-west-2.amazonaws.com/patchwork-prod/collections/banner_images/000/000/001/original/cropped-image.jpg?1734719920"
};

const ChannelBanner = (props) => {
  const { signedIn } = props.identity;
  const channels = useSelector(state => state.recommended_channels.get("items"));
  const channel_feeds = useSelector(state => state.channel_feeds.get("items"));
  const newsmast_channels = useSelector(state => state.newsmast_channels.get("items"));
  
  const channelFeed = useSelector(state => state.my_channel.get('item').get("channel_feed"));
  const dispatch = useDispatch();

  useEffect(() => {
    dispatch(fetchChannels());
    dispatch(fetchNewsmastChannels());
    dispatch(fetchMyChannel());
    dispatch(fetchChannelFeeds());
  }, []);

  const navigateToDetail = (channel, basePath) => {
    const queryString = `?slug=${encodeURIComponent(channel.attributes.slug)}`;
    browserHistory.push(`/${basePath}/${channel.attributes.name.toLowerCase()}${queryString}`);
  };

  const renderChannelSection = (data, title, imageUrl, basePath) => {
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
          width: '305px',
          height: '147px',
          padding: '10px',
          borderRadius: '10px',
          background: `linear-gradient(180deg, rgba(43, 43, 43, 0.00) 0%, rgba(37, 37, 37, 0.60) 56.93%), url(${imageUrl}) lightgray 50% / cover no-repeat`
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
                fontFamily: 'source-sans-pro',
                textAlign: 'start',
                margin: 0
              }}>{title}</p>
              <p style={{
                fontSize: '13px',
                fontWeight: 300,
                letterSpacing: '0.13px',
                color: '#fff',
                fontFamily: 'source-sans-pro',
                textAlign: 'start',
                margin: 0
              }}>{channel.attributes.community_count ?? 0} Channels</p>
            </div>
            <Icon
              icon={ArrowRightUpAltIcon}
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
    <div style={{ padding: '20px' }}>
      <div style={{ 
        display: 'flex', 
        justifyContent: 'space-between', 
        alignItems: 'center', 
        marginBottom: '20px' 
      }}>
        <h2 style={{ 
          fontSize: '24px', 
          fontWeight: 'bold', 
          margin: 0 
        }}>Explore channels</h2>
        <NavLink 
          to='/collections' 
          className="see-all"
        >
          See all
        </NavLink>
      </div>
      
      <div style={{ 
        display: 'flex', 
        flexDirection: 'column', 
        gap: '10px' 
      }}>
        {renderChannelSection(channels, 'Communities', dummyImages.communities, 'collections')}
        {renderChannelSection(newsmast_channels, 'Newsmast Channels', dummyImages.newsmast, 'newsmasts')}
        {renderChannelSection(channel_feeds, 'Channels', dummyImages.channels, 'channels')}
      </div>

      {signedIn && channelFeed && channelFeed.id && (
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
            gap: '10px'
          }}
        >
          <span style={{ fontSize: '25px' }}>+</span> Create channel
        </a>
      )}
    </div>
  );
};

ChannelBanner.propTypes = {
  identity: identityContextPropShape
};

export default withIdentity(ChannelBanner);