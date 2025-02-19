
import { fetchChannels, fetchSearchedChannels } from 'mastodon/actions/channel_banner';
import { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import ChannelSearch from '../channel_search';
import ChannelCard from 'mastodon/components/channel_card';
import CollectionCard from 'mastodon/components/collection_card';

const Collections = () => {

  const dispatch = useDispatch();
  const [searchTerm, setSearchTerm] = useState('');

  const recommendedChannels = useSelector(state => state.recommended_channels.get('items'));
  const searchChannels = useSelector(state => state.search_channels.get('items'));
  const searchChannelsLoading = useSelector(state => state.search_channels.get('isLoading'));

  const channels = searchTerm ? searchChannels : recommendedChannels;


  const handleSearch = (term) => {
    setSearchTerm(term);
    if (term.trim()) {
      dispatch(fetchSearchedChannels(term));
    } else {
      dispatch(fetchChannels());
    }
  };

  useEffect(() => {
    if (!searchTerm && recommendedChannels.size === 0) {
      dispatch(fetchChannels());
    }
  }, [searchTerm, recommendedChannels.size, dispatch]);

  return (
    <div className='channels'>
      <div className='channels__header'>
        <h2 className='title'>Explore channels</h2>
        <ChannelSearch  onSearch={handleSearch} isLoading={searchChannelsLoading}/>
      </div>
      <div className='channels__list'>
        {channels.map((channel, index) => (
          channel.type === 'channel' ?
            <ChannelCard key={index} channel={channel} /> :
            <CollectionCard key={index} channel={channel} />
        ))}
      </div>
    </div>
  );
};

export default Collections;
