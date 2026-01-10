import axios from 'axios';

import { getAccessToken } from 'mastodon/initial_state';

export const MY_CHANNEL_FETCH_REQUEST = 'MY_CHANNEL_FETCH_REQUEST';
export const MY_CHANNEL_FETCH_SUCCESS = 'MY_CHANNEL_FETCH_SUCCESS';
export const MY_CHANNEL_FETCH_FAIL = 'MY_CHANNEL_FETCH_FAIL';

export function fetchMyChannel() {
  return (dispatch) => {
    dispatch(fetchMyChannelRequest());

    axios
      .get('https://dashboard.channel.org/api/v1/channels/my_channel',{
        headers:{
          Authorization:'Bearer ' + getAccessToken()
        }
      })
      .then((response) => {
        dispatch(fetchMyChannelSuccess(response.data.data));
      })
      .catch((error) => {
        dispatch(fetchMyChannelFail(error));
      });
  };
}

export function fetchMyChannelRequest() {
  return {
    type: MY_CHANNEL_FETCH_REQUEST,
    skipLoading: true,
  };
}

export function fetchMyChannelSuccess(payload) {
  return {
    type: MY_CHANNEL_FETCH_SUCCESS,
    payload,
    skipLoading: true,
  };
}

export function fetchMyChannelFail(error) {
  return {
    type: MY_CHANNEL_FETCH_FAIL,
    error,
    skipLoading: true,
    skipAlert: true,
  };
}
