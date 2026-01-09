import React from 'react';
import { header_image } from 'mastodon/initial_state';

const ChannelTopBanner: React.FC = () => {
    return (
        <div
            style={{
                display: 'flex',
                flexDirection: 'column-reverse',
                width: '100%',
                aspectRatio: '1.96',
                background: `linear-gradient(180deg, rgba(43, 43, 43, 0.00) 0%, rgba(37, 37, 37, 0.60) 56.93%), url(${header_image}) lightgray 50% / cover no-repeat`,
            }}
        >
            {' '}
        </div>
    );
};

export default ChannelTopBanner;
