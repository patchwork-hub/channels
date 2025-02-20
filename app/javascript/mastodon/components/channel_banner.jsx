import ArrowRightUpAltIcon from '@/material-icons/400-24px/arrow_right_up_red?.svg?react';
import { Icon } from 'mastodon/components/icon';
import { fetchChannels } from '../actions/channel_banner';
import { fetchMyChannel } from '../actions/my_channel';
import { NavLink } from 'react-router-dom';
import { useDispatch, useSelector } from 'react-redux';
import { useEffect } from 'react';
import { identityContextPropShape, withIdentity } from 'mastodon/identity_context';
import { browserHistory } from "./router";

const ChannelBanner = (props) => {

  const { signedIn } = props.identity;
  const channels = useSelector(state => state.recommended_channels.get("items"));

  const channelFeed = useSelector(state => state.my_channel.get('item').get("channel_feed"));

  const dispatch = useDispatch();

  useEffect(() => {
    dispatch(fetchChannels());
    dispatch(fetchMyChannel());
  }, []);

  const goToDetail = (channel) => {
    const queryString = `?slug=${encodeURIComponent(channel.attributes.slug)}`;
    browserHistory.push(`/collections/${channel.attributes.name.toLowerCase()}${queryString}`);
  }

  const hasImage = (channel) => (channel.attributes.avatar_image_url ?? "").startsWith("https");

  return (
    <div>
      <div className='explore-channels'>
        <div className='header'>
          <h2 className='channel-header'>Explore channels</h2>
          <NavLink to='/collections' className='see-all'>
            See all
          </NavLink>
        </div>
        <div style={{
          display: 'flex',
          flexDirection: 'column',
          gap: 10
        }}>
          {channels?.slice(0, 3).map((channel, index) => (
            <button
              style={{
                padding: 0,
                border: 0,
                background: 'transparent'
              }}
              key={index}
              onClick={() => goToDetail(channel)}>
              <div
                className={hasImage(channel) ? '' : 'bg-grid'}
                style={{
                  display: 'flex',
                  alignItems: 'end',
                  aspectRatio: '305 / 147',
                  padding: '10px',
                  borderRadius:'10px',
                  ...(hasImage(channel) ? { background: "linear-gradient(180deg, rgba(43, 43, 43, 0.00) 0%, rgba(37, 37, 37, 0.60) 56.93%), url(" + channel.attributes.avatar_image_url + ") lightgray 50% / cover no-repeat" } : {})
                }}>
                <div style={{
                  display: 'flex',
                  alignItems: 'end',
                  justifyContent: 'space-between',
                  width: '100%'
                }}>
                  <div style={{
                    display: 'flex',
                    flexDirection: 'column',
                  }}>
                    <p style={{
                      fontSize: '15px',
                      fontWeight: 600,
                      color: '#fff',
                      letterSpacing: '0.15px',
                      fontFamily: 'source-sans-pro',
                      textAlign:'start'
                    }}>{channel.attributes.name}</p>
                    <p style={{
                      fontSize: '13px',
                      fontWeight: 300,
                      letterSpacing: '0.13px',
                      color: '#fff',
                      fontFamily: 'source-sans-pro',
                      textAlign:'start'
                    }}>{channel.attributes.community_count} Channels</p>
                  </div>
                  <Icon
                    icon={ArrowRightUpAltIcon}
                    id={''}
                    style={{
                      color: '#ff3c26',
                      paddingInlineEnd: '10px',
                      width: '13px',
                      height: '13px'
                    }}
                  />
                </div>
              </div>
            </button>
          ))}
        </div>
        {signedIn && channelFeed && channelFeed.id && <a
          href='https://home.channel.org/create-channel'
          style={{
            marginBlockStart: '20px',
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
          }}>
          <span style={{
            fontSize: '25px',
          }}>+</span> Create channel
        </a>}
      </div>
    </div>
  );
};

ChannelBanner.propTypes = {
  identity: identityContextPropShape
}

export default withIdentity(ChannelBanner);
