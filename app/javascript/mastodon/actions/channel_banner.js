import axios from 'axios';

export const CHANNELS_FETCH_REQUEST = 'CHANNELS_FETCH_REQUEST';
export const CHANNELS_FETCH_SUCCESS = 'CHANNELS_FETCH_SUCCESS';
export const CHANNELS_FETCH_FAIL = 'CHANNELS_FETCH_FAIL';

export const NEWSMAST_CHANNELS_FETCH_REQUEST = 'NEWSMAST_CHANNELS_FETCH_REQUEST';
export const NEWSMAST_CHANNELS_FETCH_SUCCESS = 'NEWSMAST_CHANNELS_FETCH_SUCCESS';
export const NEWSMAST_CHANNELS_FETCH_FAIL = 'NEWSMAST_CHANNELS_FETCH_FAIL';

export const CHANNELS_FEED_FETCH_REQUEST = 'CHANNELS_FEED_FETCH_REQUEST';
export const CHANNELS_FEED_FETCH_SUCCESS = 'CHANNELS_FEED_FETCH_SUCCESS';
export const CHANNELS_FEED_FETCH_FAIL = 'CHANNELS_FEED_FETCH_FAIL';

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

export function fetchNewsmastChannels() {
  return (dispatch) => {
    dispatch(fetchNewmastChannelsRequest());

    axios
      .get('https://dashboard.channel.org/api/v1/collections/newsmast_collections')
      .then((response) => {
        dispatch(fetchNewmastChannelsSuccess(response.data.data));
      })
      .catch((error) => {
        dispatch(fetchNewmastChannelsFail(error));
      });
  };
}

export function fetchChannelFeeds() {
  return (dispatch) => {
    dispatch(fetchChannelFeedsRequest());

    axios
      .get('https://dashboard.channel.org/api/v1/collections/channel_feed_collections')
      .then((response) => {
        dispatch(fetchChannelFeedsSuccess(response.data.data));
      })
      .catch((error) => {
        dispatch(fetchChannelFeedsFail(error));
      });
  };
}


export function fetchSearchedChannels(searchTerm) {
  return (dispatch) => {
    dispatch(fetchSearchChannelsRequest());

    axios
      .post(`https://dashboard.channel.org/api/v1/search?q=${searchTerm}`)
      .then((response) => {
       
        const communities = response.data.communities.data || [];
        const channelFeeds = response.data.channel_feeds.data || [];
        const newsmastChannels = response.data.newsmast_channels.data || [];
        const allChannels = [
          ...communities,
          ...channelFeeds,
          ...newsmastChannels
        ];
        
        dispatch(fetchSearchChannelsSuccess(allChannels));
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

export function fetchNewmastChannelsRequest() {
  return {
    type: NEWSMAST_CHANNELS_FETCH_REQUEST,
    skipLoading: true,
  };
}

export function fetchNewmastChannelsSuccess(channels) {
  return {
    type: NEWSMAST_CHANNELS_FETCH_SUCCESS,
    channels,
    skipLoading: true,
  };
}

export function fetchNewmastChannelsFail(error) {
  return {
    type: NEWSMAST_CHANNELS_FETCH_FAIL,
    error,
    skipLoading: true,
    skipAlert: true,
  };
}
export function fetchChannelFeedsRequest() {
  return {
    type: CHANNELS_FEED_FETCH_REQUEST,
    skipLoading: true,
  };
}

export function fetchChannelFeedsSuccess(channels) {
  return {
    type: CHANNELS_FEED_FETCH_SUCCESS,
    channels,
    skipLoading: true,
  };
}

export function fetchChannelFeedsFail(error) {
  return {
    type: CHANNELS_FEED_FETCH_FAIL,
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