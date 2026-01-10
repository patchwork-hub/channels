import { Map as ImmutableMap, List as ImmutableList } from 'immutable';

import {
  CHANNELS_FETCH_REQUEST,
  CHANNELS_FETCH_SUCCESS,
  CHANNELS_FETCH_FAIL,
} from '../actions/channel_banner';

const initialState = ImmutableMap({
  items: ImmutableList(),
  isLoading: false,
  error: null,
});

export default function channelsReducer(state = initialState, action) {
  switch(action.type) {
    case CHANNELS_FETCH_REQUEST:
      return state.get('items').size > 0
      ? state.set('isLoading', false).set('error', null)
      : state.set('isLoading', true).set('items', ImmutableList()).set('error', null);
    case CHANNELS_FETCH_SUCCESS:{
      return state.set('isLoading', false).set('items', ImmutableList(action.channels));
    }
    case CHANNELS_FETCH_FAIL:
      return state.set('isLoading', false).set('error', action.error);
    default:
      return state;
  }
}