import { useCallback } from 'react';

import { FormattedMessage } from 'react-intl';


import { openModal } from 'mastodon/actions/modal';
import { registrationsOpen, sso_redirect, is_hub, singleUserMode } from 'mastodon/initial_state';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

const SignInBanner = () => {
  const dispatch = useAppDispatch();

  const openClosedRegistrationsModal = useCallback(
    () => dispatch(openModal({ modalType: 'CLOSED_REGISTRATIONS' })),
    [dispatch],
  );

  let signupButton;

  // const baseUrl = typeof window !== 'undefined' ? `${window.location.protocol}//${window.location.host}` : '';
  // const signupUrl = useAppSelector((state) =>
  //   state.getIn(['server', 'server', 'registrations', 'url'], null) || `${baseUrl}/auth/sign_up`
  // );

  // const signupUrl = useAppSelector((state) => state.getIn(['server', 'server', 'registrations', 'url'], null) || 'https://newsmast.social/auth/sign_up');
  

  console.log('is_hub', is_hub);
  console.log('singleUserMode', singleUserMode);
  console.log('registrationsOpen', registrationsOpen);

  const signupUrl = useAppSelector((state) => {
    const defaultUrl = state.getIn(['server', 'server', 'registrations', 'url'], null) || 'https://newsmast.social/auth/sign_up';
  
    if (is_hub && (singleUserMode || registrationsOpen)) {
      return 'https://newsmast.social/auth/sign_up';
    }
    
    if (registrationsOpen && !is_hub) {
      return 'https://mastodon.social/auth/sign_up';
    }
    return defaultUrl;
    
  });
  if (sso_redirect) {
    return (
      <div className='sign-in-banner'>
        <p><strong>Follow and interact with this channel by creating an  account.</strong></p>
        <p><FormattedMessage id='sign_in_banner.follow_anyone' defaultMessage='Follow anyone across the fediverse and see it all in chronological order. No algorithms, ads, or clickbait in sight.' /></p>
        <a href={sso_redirect} data-method='post' className='button button--block button-tertiary'><FormattedMessage id='sign_in_banner.sso_redirect' defaultMessage='Login or Register' /></a>
      </div>
    );
  }

  if (registrationsOpen) {
    signupButton = (
      <a href={signupUrl} className='button button--block' target='_blank'>
        Create a social web account
      </a>
    );
  }

  return (
    <div className='sign-in-banner'>
      <p>Follow and interact with this Channel by creating a social web account.</p>
      {signupButton}
      <a href='/auth/sign_in' className='button button--block button-tertiary'>Sign in</a>
    </div>
  );
};

export default SignInBanner;
