import { useCallback, useEffect, useLayoutEffect } from 'react';

import { useLayout } from '@/mastodon/hooks/useLayout';
import { useAppDispatch, useAppSelector } from '@/mastodon/store';
import {
  changeComposing,
  mountCompose,
  unmountCompose,
} from 'mastodon/actions/compose';
import { useAppHistory } from 'mastodon/components/router';
import ServerBanner from 'mastodon/components/server_banner';
import { Search } from 'mastodon/features/compose/components/search';
import ComposeFormContainer from 'mastodon/features/compose/containers/compose_form_container';
import ChannelBanner from '@/mastodon/components/channel_banner';
import { useIdentity } from 'mastodon/identity_context';
import { SignInBanner } from '../../navigation_panel/components/sign_in_banner';

export const ComposePanel: React.FC = () => {
  const dispatch = useAppDispatch();
  const handleFocus = useCallback(() => {
    dispatch(changeComposing(true));
  }, [dispatch]);
  const { signedIn } = useIdentity();
  const hideComposer = useAppSelector((state) => {
    const mounted = state.compose.get('mounted');
    if (typeof mounted === 'number') {
      return mounted > 1;
    }
    return false;
  });

  useEffect(() => {
    dispatch(mountCompose());
    return () => {
      dispatch(unmountCompose());
    };
  }, [dispatch]);

  const { singleColumn } = useLayout();

  return (
    <div className='compose-panel' onFocus={handleFocus}>

      {signedIn && !hideComposer && <ComposeFormContainer singleColumn />}
      {signedIn && hideComposer && <div className='compose-form' />}
      <ChannelBanner />
      {!signedIn && (
        <SignInBanner />
      )}
      
    </div>
  );
};

/**
 * Redirect the user to the standalone compose page when the
 * sidebar composer is hidden due to a change in viewport size
 * while a post is being written.
 */

export const RedirectToMobileComposeIfNeeded: React.FC = () => {
  const history = useAppHistory();

  const shouldRedirect = useAppSelector((state) =>
    state.compose.get('should_redirect_to_compose_page'),
  );

  useLayoutEffect(() => {
    if (shouldRedirect) {
      history.push('/publish');
    }
  }, [history, shouldRedirect]);

  return null;
};
