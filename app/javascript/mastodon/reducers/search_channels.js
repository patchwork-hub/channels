import { Map as ImmutableMap, List as ImmutableList } from 'immutable';
import {
  SEARCH_CHANNELS_FETCH_REQUEST,
  SEARCH_CHANNELS_FETCH_SUCCESS,
  SEARCH_CHANNELS_FETCH_FAIL,
} from '../actions/channel_banner';

const initialState = ImmutableMap({
  items: ImmutableList(),
  isLoading: false,
  error: null,
});

export default function searchChannelsReducer(state = initialState, action) {
  switch (action.type) {
    case SEARCH_CHANNELS_FETCH_REQUEST:
      return state.set('isLoading', true).set('error', null);
    case SEARCH_CHANNELS_FETCH_SUCCESS:
      return state
        .set('isLoading', false)
        .set('items', ImmutableList(action.channels.map(channel => ImmutableMap(channel))));
    case SEARCH_CHANNELS_FETCH_FAIL:
      return state.set('isLoading', false).set('error', action.error);
    default:
      return state;
  }
}