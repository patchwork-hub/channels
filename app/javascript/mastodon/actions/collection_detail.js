import axios from 'axios';

export const NEWSMAST_DETAIL_FETCH_REQUEST = 'NEWSMAST_DETAIL_FETCH_REQUEST';
export const NEWSMAST_DETAIL_FETCH_SUCCESS = 'NEWSMAST_DETAIL_FETCH_SUCCESS';
export const NEWSMAST_DETAIL_FETCH_FAIL = 'NEWSMAST_DETAIL_FETCH_FAIL';


export const COLLECTION_DETAIL_FETCH_REQUEST = 'COLLECTION_DETAIL_FETCH_REQUEST';
export const COLLECTION_DETAIL_FETCH_SUCCESS = 'COLLECTION_DETAIL_FETCH_SUCCESS';
export const COLLECTION_DETAIL_FETCH_FAIL = 'COLLECTION_DETAIL_FETCH_FAIL';


export const CHANNEL_FEED_DETAIL_FETCH_REQUEST = 'CHANNEL_FEED_DETAIL_FETCH_REQUEST';
export const CHANNEL_FEED_DETAIL_FETCH_SUCCESS = 'CHANNEL_FEED_DETAIL_FETCH_SUCCESS';
export const CHANNEL_FEED_DETAIL_FETCH_FAIL = 'CHANNEL_FEED_DETAIL_FETCH_FAIL';


export function fetchCollectionDetail(slug) {
  return (dispatch) => {
    dispatch(fetchCollectionDetailRequest());

    axios
      .get(`https://dashboard.channel.org/api/v1/collections/fetch_channels?slug=${slug}&type=channel`)
      .then((response) => {
        dispatch(fetchCollectionDetailSuccess(response.data.data));
      })
      .catch((error) => {
        dispatch(fetchCollectionDetailFail(error));
      });
  };
}

export function fetchNewsmastDetail(slug) {
  return (dispatch) => {
    dispatch(fetchNewsmastDetailRequest());

    axios
      .get(`https://dashboard.channel.org/api/v1/collections/fetch_channels?slug=${slug}&type=newsmast`)
      .then((response) => {
        dispatch(fetchNewsmastDetailSuccess(response.data));
      })
      .catch((error) => {
        dispatch(fetchNewsmastDetailFail(error));
      });
  };
}

export function fetchChannelFeedDetail(slug) {
  return (dispatch) => {
    dispatch(fetchChannelFeedDetailRequest());

    axios
      .get(`https://dashboard.channel.org/api/v1/collections/fetch_channels?slug=${slug}&type=channel_feed`)
      .then((response) => {
        dispatch(fetchChannelFeedDetailSuccess(response.data.data));
      })
      .catch((error) => {
        dispatch(fetchChannelFeedDetailFail(error));
      });
  };
}


export function fetchCollectionDetailRequest() {
  return {
    type: COLLECTION_DETAIL_FETCH_REQUEST,
    skipLoading: true,
  };
}

export function fetchCollectionDetailSuccess(channels) {
  return {
    type: COLLECTION_DETAIL_FETCH_SUCCESS,
    channels,
    skipLoading: true,
  };
}

export function fetchCollectionDetailFail(error) {
  return {
    type: COLLECTION_DETAIL_FETCH_FAIL,
    error,
    skipLoading: true,
    skipAlert: true,
  };
}

export function fetchNewsmastDetailRequest() {
  return {
    type: NEWSMAST_DETAIL_FETCH_REQUEST,
    skipLoading: true,
  };
}

export function fetchNewsmastDetailSuccess(channels) {
  return {
    type: NEWSMAST_DETAIL_FETCH_SUCCESS,
    channels,
    skipLoading: true,
  };
}

export function fetchNewsmastDetailFail(error) {
  return {
    type: NEWSMAST_DETAIL_FETCH_FAIL,
    error,
    skipLoading: true,
    skipAlert: true,
  };
}


export function fetchChannelFeedDetailRequest() {
  return {
    type: CHANNEL_FEED_DETAIL_FETCH_REQUEST,
    skipLoading: true,
  };
}

export function fetchChannelFeedDetailSuccess(channels) {
  return {
    type: CHANNEL_FEED_DETAIL_FETCH_SUCCESS,
    channels,
    skipLoading: true,
  };
}

export function fetchChannelFeedDetailFail(error) {
  return {
    type: CHANNEL_FEED_DETAIL_FETCH_FAIL,
    error,
    skipLoading: true,
    skipAlert: true,
  };
}
