
import { fetchChannels, fetchSearchedChannels } from 'mastodon/actions/channel_banner';
import { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import ChannelSearch from '../channel_search';
import ChannelCard from 'mastodon/components/channel_card';
import CollectionCard from 'mastodon/components/collection_card';
import { LoadingIndicator } from 'mastodon/components/loading_indicator';

const Collections = () => {

  const dispatch = useDispatch();
  const [searchTerm, setSearchTerm] = useState('');

  const collections = useSelector(state => state.recommended_channels.get('items'));
  const collectionsLoading = useSelector(state => state.recommended_channels.get('isLoading'));
  const searchChannels = useSelector(state => state.search_channels.get('items'));
  const searchChannelsLoading = useSelector(state => state.search_channels.get('isLoading'));

  const channels = searchTerm ? searchChannels : collections;


  const handleSearch = (term) => {
    setSearchTerm(term);
    if (term.trim()) {
      dispatch(fetchSearchedChannels(term));
    } else {
      dispatch(fetchChannels());
    }
  };

  useEffect(() => {
    if (!searchTerm && collections.size === 0) {
      dispatch(fetchChannels());
    }
  }, [searchTerm, collections.size, dispatch]);

  return (
    <div className='channels'>
      <div className='channels__header'>
        <h2 className='title'>Explore channels</h2>
        <ChannelSearch  onSearch={handleSearch} isLoading={searchChannelsLoading}/>
      </div>
      {searchChannelsLoading || collectionsLoading ? (
        <div className='channels__loading'>
          <LoadingIndicator />
        </div>
      ) : channels.size === 0 ? (
        <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '60vh' }}>
          <p style={{ fontSize:"20px"}}>No channels found.</p>
        </div>
      ) : (
        <div className='channels__list'>
          {channels.map((channel, index) => (
            channel.type === 'channel' ? (
              <ChannelCard key={index} channel={channel} />
            ) : (
              <CollectionCard key={index} channel={channel} />
            )
          ))}
        </div>
      )}
    </div>
  );
};

export default Collections;
