import { header_image } from 'mastodon/initial_state';

const ChannelTopBanner = () => {
  return (
    <div
      className='channel-header'
      style={{
        backgroundImage: `
          linear-gradient(
            180deg,
            rgba(0,0,0,0) 0%,
            rgba(0,0,0,0.35) 70%
          ),
          url(${header_image})
        `,
      }}
    />
  );
};

export default ChannelTopBanner;
