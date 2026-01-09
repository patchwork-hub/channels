import type { CSSProperties } from 'react';
import ServerBanner from 'mastodon/components/server_banner';
import wideChannelLogo from '@/images/wide_channel_logo.svg';

export const ServerInformation: React.FC<{
    className?: string;
    style?: CSSProperties;
}> = ({ className = '', style = {} }) => {
    return (
        <div className={className} style={style}>
            <p className='powered-by' style={{ marginBottom: '8px', fontSize: '12px', opacity: 0.7 }}>Powered by</p>
            <a href='https://home.channel.org/' target='_blank' rel='noopener' style={{ display: 'block', marginBottom: '16px' }}>
                <img src={wideChannelLogo} alt='channel org' style={{ maxWidth: '100%', height: 'auto' }} />
            </a>

            <div
                style={{
                    display: 'flex',
                    flexDirection: 'column',
                    gap: '16px',
                }}
            >
                <p
                    style={{
                        fontSize: '11px',
                        color: 'inherit',
                        fontFeatureSettings: "'liga' off, 'clig' off",
                        lineHeight: '1.5',
                    }}
                >
                    Channel.org is a safe space where you can create and curate Channel
                    Feeds, distributed across the Fediverse, Bluesky and the wider web
                    through RSS.
                </p>

                <ServerBanner />

                <a
                    href='#'
                    style={{
                        display: 'flex',
                        justifyContent: 'center',
                        alignItems: 'center',
                        fontSize: '11px',
                        color: 'inherit',
                        fontWeight: 700,
                        fontFeatureSettings: "'liga' off, 'clig' off",
                        border: '1px solid currentColor',
                        borderRadius: '3px',
                        paddingBlock: '10px',
                        textDecoration: 'none',
                    }}
                >
                    Learn more
                </a>
            </div>
        </div>
    );
};
