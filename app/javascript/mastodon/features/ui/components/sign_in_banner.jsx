import { useCallback } from 'react';
import { FormattedMessage } from 'react-intl';
import { openModal } from 'mastodon/actions/modal';
import { registrationsOpen, sso_redirect, singleUserMode, is_newuser_with_approval, is_main_channel } from 'mastodon/initial_state';
import { useAppDispatch, useAppSelector } from 'mastodon/store';

const SignInBanner = () => {
  const dispatch = useAppDispatch();

  const openClosedRegistrationsModal = useCallback(
    () => dispatch(openModal({ modalType: 'CLOSED_REGISTRATIONS' })),
    [dispatch],
  );

  console.log("singleUserMode",singleUserMode)
  console.log("is_newuser_with_approval",is_newuser_with_approval)
  console.log("is_main_channel",is_main_channel)
  console.log("registrationsOpen",registrationsOpen)
  
  const registrationState = useAppSelector((state) => {
    const defaultUrl = state.getIn(['server', 'server', 'registrations', 'url'], null) || 'https://newsmast.social/auth/sign_up';

    
    if (!is_main_channel && singleUserMode && !registrationsOpen) {
      return {
        condition: 'single_user_closed',
        text: <FormattedMessage defaultMessage='Registration is closed here.' />,
        buttons: [
          {
            label: <FormattedMessage  defaultMessage='Create a newsmast.social account' />,
            url: 'https://newsmast.social/auth/sign_up',
            target: '_blank',
            className: 'button button--block',
          },
          {
            label: <FormattedMessage  defaultMessage='Sign in' />,
            url: '/auth/sign_in',
            className: 'button button--block button-tertiary',
          },
        ],
        signupUrl: null,
        onClick: openClosedRegistrationsModal,
      };
    }

    
    if (!is_main_channel && !singleUserMode && registrationsOpen && is_newuser_with_approval) {
      return {
        condition: 'open_with_approval',
        text: <FormattedMessage  defaultMessage='Sign-ups require moderator review.' />,
        buttons: [
          {
            label: <FormattedMessage  defaultMessage='Create a social web account' />,
            url: '/auth/sign_up',
            target: '_blank',
            className: 'button button--block',
          },
          {
            label: <FormattedMessage defaultMessage='Sign in' />,
            url: '/auth/sign_in',
            className: 'button button--block button-tertiary',
          },
        ],
        signupUrl: 'https://newsmast.social/auth/sign_up',
      };
    }

    
    if (!is_main_channel && !singleUserMode && registrationsOpen && !is_newuser_with_approval) {
      return {
        condition: 'open_no_approval',
        text: (
          <FormattedMessage
           
            defaultMessage='Follow and interact with this Channel by creating a social web account.'
          />
        ),
        buttons: [
          {
            label: <FormattedMessage defaultMessage='Create a social web account' />,
            url: '/auth/sign_up',
            target: '_blank',
            className: 'button button--block',
          },
          {
            label: <FormattedMessage defaultMessage='Sign in' />,
            url: '/auth/sign_in',
            className: 'button button--block button-tertiary',
          },
        ],
        signupUrl: 'https://newsmast.social/auth/sign_up',
      };
    }

    
    if (!is_main_channel && !singleUserMode && !registrationsOpen) {
      return {
        condition: 'closed',
        text: <FormattedMessage defaultMessage='Registration is closed here.' />,
        buttons: [
          {
            label: <FormattedMessage defaultMessage='Sign in' />,
            url: '/auth/sign_in',
            className: 'button button--block button-tertiary',
          },
        ],
        signupUrl: null,
        onClick: openClosedRegistrationsModal,
      };
    }

    
    return {
      condition: 'default',
      text: (
        <FormattedMessage
          defaultMessage='Follow and interact with this channel by creating an account.'
        />
      ),
      buttons: [
        {
          label: <FormattedMessage defaultMessage='Create a social web account' />,
          url: defaultUrl,
          target: '_blank',
          className: 'button button--block',
        },
        {
          label: <FormattedMessage defaultMessage='Sign in' />,
          url: '/auth/sign_in',
          className: 'button button--block button-tertiary',
        },
      ],
      signupUrl: defaultUrl,
    };
  });

  
  if (sso_redirect) {
    return (
      <div className='sign-in-banner'>
        <p>
          <strong>
            <FormattedMessage
              defaultMessage='Follow and interact with this channel by creating an account.'
            />
          </strong>
        </p>
        <p>
          <FormattedMessage
            defaultMessage='Follow anyone across the fediverse and see it all in chronological order. No algorithms, ads, or clickbait in sight.'
          />
        </p>
        <a href={sso_redirect} data-method='post' className='button button--block button-tertiary'>
          <FormattedMessage defaultMessage='Login or Register' />
        </a>
      </div>
    );
  }

  
  return (
    <div className='sign-in-banner'>
      <p>{registrationState.text}</p>
      {registrationState.buttons.map((button, index) => (
        <a
          key={index}
          href={button.url || '#'}
          className={button.className}
          target={button.target}
          onClick={button.url ? undefined : registrationState.onClick}
          {...(button.url ? {} : { role: 'button', tabIndex: 0 })}
        >
          {button.label}
        </a>
      ))}
    </div>
  );
};

export default SignInBanner;
