import { Map as ImmutableMap } from 'immutable';

import {
    MY_CHANNEL_FETCH_REQUEST,
    MY_CHANNEL_FETCH_SUCCESS,
    MY_CHANNEL_FETCH_FAIL,
} from '../actions/my_channel';

const initialState = ImmutableMap({
    item: ImmutableMap(),
    isLoading: false,
    error: null,
});

export default function myChannelReducer(state = initialState, action) {
    switch (action.type) {
        case MY_CHANNEL_FETCH_REQUEST:
            return state.set('isLoading', true).set('error', null);
        case MY_CHANNEL_FETCH_SUCCESS: {
            return state.set('isLoading', false).set('item', ImmutableMap(action.payload));
        }
        case MY_CHANNEL_FETCH_FAIL:
            return state.set('isLoading', false).set('error', action.error);
        default:
            return state;
    }
}
