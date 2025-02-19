import axios from 'axios';

import { getAccessToken } from 'mastodon/initial_state';

export const CHANNELS_FETCH_REQUEST = 'CHANNELS_FETCH_REQUEST';
export const CHANNELS_FETCH_SUCCESS = 'CHANNELS_FETCH_SUCCESS';
export const CHANNELS_FETCH_FAIL = 'CHANNELS_FETCH_FAIL';

export const SEARCH_CHANNELS_FETCH_REQUEST = 'SEARCH_CHANNELS_FETCH_REQUEST';
export const SEARCH_CHANNELS_FETCH_SUCCESS = 'SEARCH_CHANNELS_FETCH_SUCCESS';
export const SEARCH_CHANNELS_FETCH_FAIL = 'SEARCH_CHANNELS_FETCH_FAIL';

export function fetchChannels() {
  return (dispatch) => {
    dispatch(fetchChannelsRequest());

    axios
      .get('https://dashboard.channel.org/api/v1/collections')
      .then((response) => {
        dispatch(fetchChannelsSuccess(response.data.data));
      })
      .catch((error) => {
        dispatch(fetchChannelsFail(error));
      });
  };
}

export function fetchSearchedChannels(searchTerm) {
  return (dispatch) => {
    dispatch(fetchSearchChannelsRequest());

    axios
      .get(`https://dashboard.channel.org/api/v1/channels/search?q=${searchTerm}`)
      .then((response) => {
        dispatch(fetchSearchChannelsSuccess(response.data.data));
      })
      .catch((error) => {
        dispatch(fetchSearchChannelsFail(error));
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

export function fetchSearchChannelsRequest() {
  return { type: SEARCH_CHANNELS_FETCH_REQUEST, skipLoading: true };
}

export function fetchSearchChannelsSuccess(channels) {
  return { type: SEARCH_CHANNELS_FETCH_SUCCESS, channels, skipLoading: true };
}

export function fetchSearchChannelsFail(error) {
  return { type: SEARCH_CHANNELS_FETCH_FAIL, error, skipLoading: true, skipAlert: true };
}