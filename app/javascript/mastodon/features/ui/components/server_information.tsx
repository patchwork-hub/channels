import ServerBanner from 'mastodon/components/server_banner';

import channelOrgImage from '../../../../images/wide_channel_logo.svg';
import { CSSProperties } from 'react';


export const ServerInformation = ({ className = '', style = {} }: { className?: string, style?: Record<string,CSSProperties> }) => {
    return (
        <div className={className} style={style}>
            <p className='powered-by'>Powered by</p>
            <a href='https://home.channel.org/' target='_blank' rel='noopener'>
                <img src={channelOrgImage} alt='channel org' />
            </a>
            <p style={{
                color: 'rgba(255, 255, 255, 0.70)',
                fontSize: '14px',
                marginBlock: '20px'
            }}>© {new Date().getFullYear()} Channel.org</p>

            <div style={{
                display: 'flex',
                flexDirection: 'column',
                gap: '16px'
            }}>
                <p style={{
                    fontSize: '11px',
                    color: '#fff',
                    fontFeatureSettings: "'liga' off, 'clig' off",
                }}>
                    Channel.org is a safe space where you can create and curate Channel Feeds, distributed across the Fediverse, Bluesky and the wider web through RSS.
                </p>

                <ServerBanner />

                <a href='/#' style={{
                    display: 'flex',
                    justifyContent: 'center',
                    alignItems: 'center',
                    fontSize: '11px',
                    color: '#fff',
                    fontWeight: 700,
                    fontFeatureSettings: "'liga' off, 'clig' off",
                    border: '1px solid #fff',
                    borderRadius: '3px',
                    paddingBlock: '10px',
                    textDecoration: 'none',
                }}>
                    Learn more
                </a>
            </div>
        </div>
    );
};