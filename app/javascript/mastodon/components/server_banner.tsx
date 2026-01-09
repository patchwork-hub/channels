import { useEffect } from 'react';

import { FormattedMessage, defineMessages } from 'react-intl';

import { fetchServer } from 'mastodon/actions/server';
import { Account } from 'mastodon/components/account';
import { useAppDispatch, useAppSelector } from 'mastodon/store';
import type { Map as ImmutableMap } from 'immutable';

const messages = defineMessages({
    aboutActiveUsers: {
        id: 'server_banner.about_active_users',
        defaultMessage:
            'People using this server during the last 30 days (Monthly Active Users)',
    },
    administered_by: {
        id: 'server_banner.administered_by',
        defaultMessage: 'Administered by:',
    },
});

export const ServerBanner: React.FC = () => {
    const dispatch = useAppDispatch();
    const server = useAppSelector((state) => state.server.get('server')) as ImmutableMap<string, any> | undefined;
    const isLoading = server?.get('isLoading');

    useEffect(() => {
        dispatch(fetchServer());
    }, [dispatch]);

    if (!server || isLoading) {
        return (
            <div className='server-banner'>
                <div className='server-banner__meta'>
                    <div className='server-banner__meta__column'>
                        <h4>
                            <FormattedMessage {...messages.administered_by} />
                        </h4>
                        <div style={{ padding: '8px 0', opacity: 0.5 }}>Loading...</div>
                    </div>
                </div>
            </div>
        );
    }

    const contactAccountId = server.getIn(['contact', 'account', 'id']) as string | undefined;

    return (
        <div className='server-banner'>
            <div className='server-banner__meta'>
                <div className='server-banner__meta__column'>
                    <h4>
                        <FormattedMessage {...messages.administered_by} />
                    </h4>

                    {contactAccountId && (
                        <Account id={contactAccountId} size={36} minimal />
                    )}
                </div>
            </div>
        </div>
    );
};

export default ServerBanner;
