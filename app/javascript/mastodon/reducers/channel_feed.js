import { Map as ImmutableMap, List as ImmutableList } from 'immutable';

import {
  CHANNEL_FEED_DETAIL_FETCH_REQUEST,
  CHANNEL_FEED_DETAIL_FETCH_SUCCESS,
  CHANNEL_FEED_DETAIL_FETCH_FAIL,
} from '../actions/collection_detail';

const initialState = ImmutableMap({
  items: ImmutableList(),
  isLoading: false,
  error: null,
});

export default function channelFeedDetailReducer(state = initialState, action) {
  switch (action.type) {
    case CHANNEL_FEED_DETAIL_FETCH_REQUEST:
      return state.get('items').size > 0
      ? state.set('isLoading', false).set('error', null)
      : state.set('isLoading', true).set('items', ImmutableList()).set('error', null);
    case CHANNEL_FEED_DETAIL_FETCH_SUCCESS:
      return state.set('isLoading', false).set('items', ImmutableList(action.channels));
    case CHANNEL_FEED_DETAIL_FETCH_FAIL:
      return state.set('isLoading', false).set('error', action.error);
    default:
      return state;
  }
}
