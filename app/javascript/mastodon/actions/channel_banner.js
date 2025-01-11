import axios from 'axios';

export const CHANNELS_FETCH_REQUEST = 'CHANNELS_FETCH_REQUEST';
export const CHANNELS_FETCH_SUCCESS = 'CHANNELS_FETCH_SUCCESS';
export const CHANNELS_FETCH_FAIL = 'CHANNELS_FETCH_FAIL';

export function fetchChannels() {
  return (dispatch) => {
    dispatch(fetchChannelsRequest());

    axios
      .get('https://dashboard.channel.org/api/v1/channels/recommend_channels')
      .then((response) => {
        dispatch(fetchChannelsSuccess(response.data.data));
      })
      .catch((error) => {
        dispatch(fetchChannelsFail(error));
      });
  };
}

export function fetchChannelsRequest() {
  return {
    type: CHANNELS_FETCH_REQUEST,
    skipLoading: true,
  };
}

export function fetchChannelsSuccess(channels) {
  return {
    type: CHANNELS_FETCH_SUCCESS,
    channels,
    skipLoading: true,
  };
}

export function fetchChannelsFail(error) {
  return {
    type: CHANNELS_FETCH_FAIL,
    error,
    skipLoading: true,
    skipAlert: true,
  };
}
