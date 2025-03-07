import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { connect } from 'react-redux';

import {
  changeComposing,
  mountCompose,
  unmountCompose,
} from 'mastodon/actions/compose';
import ChannelBanner from 'mastodon/components/channel_banner';
import ComposeFormContainer from 'mastodon/features/compose/containers/compose_form_container';
import { identityContextPropShape, withIdentity } from 'mastodon/identity_context';
import SignInBanner from './sign_in_banner';

class ComposePanel extends PureComponent {
  static propTypes = {
    identity: identityContextPropShape,
    dispatch: PropTypes.func.isRequired,
  };

  onFocus = () => {
    const { dispatch } = this.props;
    dispatch(changeComposing(true));
  };

  onBlur = () => {
    const { dispatch } = this.props;
    dispatch(changeComposing(false));
  };

  componentDidMount() {
    const { dispatch } = this.props;
    dispatch(mountCompose());
  }

  componentWillUnmount() {
    const { dispatch } = this.props;
    dispatch(unmountCompose());
  }

  render() {
    const { signedIn } = this.props.identity;

    return (
      <div className='compose-panel' onFocus={this.onFocus}>

        {signedIn && (
          <>
            <ComposeFormContainer singleColumn />
            <div className='flex-spacer' />
            <div style={{ marginBlock: 30 }}>
              <ChannelBanner />
            </div>
          </>
        )}
        {!signedIn && (
          <>
            <ChannelBanner />
            <SignInBanner />
          </>
        )}



      </div>
    );
  }
}

export default connect()(withIdentity(ComposePanel));
