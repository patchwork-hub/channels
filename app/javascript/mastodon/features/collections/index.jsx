
import { fetchChannels, fetchSearchedChannels, fetchNewsmastChannels, fetchChannelFeeds} from 'mastodon/actions/channel_banner';
import { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import ChannelSearch from '../channel_search';
import { Helmet } from 'react-helmet';
import ChannelCard from 'mastodon/components/channel_card';
import CollectionCard from 'mastodon/components/collection_card';
import { LoadingIndicator } from 'mastodon/components/loading_indicator';

const Collections = () => {

  const dispatch = useDispatch();
  const [searchTerm, setSearchTerm] = useState('');

  const collections = useSelector(state => state.recommended_channels.get('items'));
  const channel_feeds = useSelector(state => state.channel_feeds.get("items"));
  const newsmast_channels = useSelector(state => state.newsmast_channels.get("items"));
  const collectionsLoading = useSelector(state => state.recommended_channels.get('isLoading'));  
  const searchChannels = useSelector(state => 
    state.getIn(['search_channels', 'items']).toJS()
  );
  
  const searchChannelsLoading = useSelector(state => 
    state.getIn(['search_channels', 'isLoading'])
  );

  const channels = searchTerm 
  ? searchChannels 
  : [
      collections?.size > 0 ? collections.get(0) : null,
      newsmast_channels?.size > 0 ? newsmast_channels.get(0) : null,
      channel_feeds?.size > 0 ? channel_feeds.get(0) : null
    ].filter(item => item !== null);

  const isLoading = searchTerm ? searchChannelsLoading : collectionsLoading;


  const handleSearch = (term) => {
    setSearchTerm(term);
    if (term.trim()) {
      dispatch(fetchSearchedChannels(term));
    } else {
      dispatch(fetchChannels());
      dispatch(fetchNewsmastChannels());
      dispatch(fetchChannelFeeds());
    }
  };
  console.log(searchChannelsLoading, collectionsLoading)
  useEffect(() => {
    if (!searchTerm &&( collections.size === 0 ||  newsmast_channels.size === 0 ||  channel_feeds.size === 0 )&& !collectionsLoading) {
      dispatch(fetchChannels());
      dispatch(fetchNewsmastChannels());
      dispatch(fetchChannelFeeds());
    }
  }, [searchTerm, collections,newsmast_channels, collectionsLoading,channel_feeds, dispatch]);
  

  return (
    <div className='channels'>
       <Helmet>
        <title>Explore channels</title>
      </Helmet>
      <div className='channels__header'>
        <h2 className='title'>Explore channels </h2>
        <ChannelSearch  onSearch={handleSearch} isLoading={searchChannelsLoading}/>
      </div>
      {searchChannelsLoading || isLoading ? (
            <div className='channels__loading'>
              <LoadingIndicator />
            </div>
          ) : !searchTerm && channels.length === 0 ? (
            <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '60vh' }}>
              <p style={{ fontSize: '20px' }}>No channels found</p>
            </div>
          ) : channels.length === 0 ? (
            <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '60vh' }}>
              <p style={{ fontSize: '20px' }}>No channels found</p>
            </div>
          ) : (
            <div className='channels__list'>
              {channels.map((channel, index) => (
                channel.type === 'channel' ? (
                  <ChannelCard key={index} channel={channel} />
                ) : (
                  <CollectionCard key={index} channel={channel} type="all" from="community"/>
                )
              ))}
            </div>
          )}
    </div>
  );
};

export default Collections;
