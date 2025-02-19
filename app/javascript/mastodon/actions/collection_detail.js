import axios from 'axios';

export const COLLECTION_DETAIL_FETCH_REQUEST = 'COLLECTION_DETAIL_FETCH_REQUEST';
export const COLLECTION_DETAIL_FETCH_SUCCESS = 'COLLECTION_DETAIL_FETCH_SUCCESS';
export const COLLECTION_DETAIL_FETCH_FAIL = 'COLLECTION_DETAIL_FETCH_FAIL';


export function fetchCollectionDetail(slug) {
  return (dispatch) => {
    dispatch(fetchCollectionDetailRequest());

    axios
      .get(`https://dashboard.channel.org/api/v1/collections/fetch_channels?slug=${slug}`)
      .then((response) => {
        dispatch(fetchCollectionDetailSuccess(response.data.data));
      })
      .catch((error) => {
        dispatch(fetchCollectionDetailFail(error));
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
