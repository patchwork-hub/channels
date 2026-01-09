import { useCallback } from 'react';

import { closeModal } from 'mastodon/actions/modal';
import { useAppDispatch } from 'mastodon/store';

export const SignInWithMastodonModal: React.FC = () => {
  const dispatch = useAppDispatch();

  const handleClose = useCallback(() => {
    dispatch(
      closeModal({ modalType: 'SIGNIN_WITH_MASTODON', ignoreFocus: false }),
    );
  }, [dispatch]);

  return (
    <div
      className='modal-root__modal signin-with-mastodon-modal'
      style={{
        display: 'flex',
        flexDirection: 'column',
        alignItems: 'center',
        gap: '30px',
        maxWidth: '530px',
        background: '#16161D',
        border: '1px solid rgba(230, 231, 235, 0.2)',
        borderRadius: '10px',
        padding: '40px',
      }}
    >
      <h1
        style={{
          fontSize: 30,
          fontWeight: 700,
          fontFamily: 'ibm-plex-sans',
          fontFeatureSettings: 'liga off, clig off',
          lineHeight: '120%',
          background: 'linear-gradient(180deg, #F8F8FF 50.5%, #BABAF8 100%)',
          backgroundClip: 'text',
          WebkitBackgroundClip: 'text',
          WebkitTextFillColor: 'transparent',
        }}
      >
        Sign in with Mastodon
      </h1>
      <p
        style={{
          color: '#D2D2FF',
          fontSize: 16,
          fontWeight: 400,
          fontFamily: 'source-sans-pro',
          textAlign: 'center',
          lineHeight: '148%',
        }}
      >
        Enter your server name below to login with Mastodon.
      </p>
      <form
        action='/users/auth/mastodon/callback'
        method='get'
        style={{
          alignSelf: 'stretch',
          display: 'flex',
          flexDirection: 'column',
          gap: 10,
        }}
      >
        <label
          htmlFor='server-input'
          style={{
            fontFamily: 'source-sans-pro',
            fontSize: 16,
            fontWeight: 400,
            lineHeight: '148%',
            color: '#D2D2FF',
          }}
        >
          Server name <span style={{ color: '#E42021' }}>*</span>
        </label>
        <input
          id='server-input'
          name='domain'
          placeholder='Example mastodon.social'
          required
          style={{
            padding: '14px 16px',
            borderRadius: 3,
            border: '1px solid rgba(255, 255, 255, 0.50)',
            background: 'transparent',
            color: '#fff',
          }}
        />
        <button
          type='submit'
          style={{
            alignSelf: 'stretch',
            borderRadius: 8,
            border: 0,
            color: '#fff',
            background: '#FF3C26',
            padding: '9px 15px',
            display: 'flex',
            justifyContent: 'center',
            alignItems: 'center',
            gap: 10,
            fontSize: 17,
            fontWeight: 400,
            fontFamily: 'source-sans-pro',
            lineHeight: '148%',
            marginTop: 20,
            cursor: 'pointer',
          }}
        >
          Sign In
        </button>
      </form>
      <button
        onClick={handleClose}
        style={{
          background: 'transparent',
          border: 'none',
          color: '#D2D2FF',
          cursor: 'pointer',
          fontSize: 14,
          textDecoration: 'underline',
        }}
      >
        Cancel
      </button>
    </div>
  );
};

export default SignInWithMastodonModal;
