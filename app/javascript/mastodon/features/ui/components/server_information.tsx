import type { CSSProperties } from 'react';

import ServerBanner from 'mastodon/components/server_banner';

import channelOrgImage from '../../../../images/wide_channel_logo.svg';

export const ServerInformation = ({
  className = '',
  style = {},
}: {
  className?: string;
  style?: CSSProperties;
}) => {
  return (
    <div className={`server-information ${className}`} style={style}>
      <p className='powered-by'>Powered by</p>
      <a
        href='https://home.channel.org/'
        target='_blank'
        rel='noopener noreferrer'
      >
        <img src={channelOrgImage} alt='Channel.org' />
      </a>

      <div className='server-information__content'>
        <p className='server-information__description'>
          Channel.org is a safe space where you can create and curate Channel
          Feeds, distributed across the Fediverse, Bluesky and the wider web
          through RSS.
        </p>

        <ServerBanner />

        <a
          href='https://home.channel.org/'
          target='_blank'
          rel='noopener noreferrer'
          className='server-information__learn-more'
        >
          Learn more
        </a>
      </div>
    </div>
  );
};
