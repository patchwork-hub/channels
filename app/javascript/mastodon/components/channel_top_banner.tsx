import { header_image } from 'mastodon/initial_state';

const ChannelTopBanner = () => {
  return (
    <div
      className='channel-header'
      style={
        { '--header-image': `url(${header_image})` } as React.CSSProperties
      }
    />
  );
};

export default ChannelTopBanner;
