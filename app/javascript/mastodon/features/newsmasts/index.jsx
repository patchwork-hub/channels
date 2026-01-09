
import { fetchSearchedChannels } from 'mastodon/actions/channel_banner';
import { useEffect, useState } from 'react';
import { useDispatch, useSelector } from 'react-redux';
import ChannelSearch from '../channel_search';
import { NavLink, useParams } from 'react-router-dom';
import { fetchNewsmastDetail } from 'mastodon/actions/collection_detail';
import ArrowBackIcon from '@/material-icons/400-24px/arrow_back.svg?react';
import { Icon } from 'mastodon/components/icon';
import { Helmet } from 'react-helmet';
import { LoadingIndicator } from 'mastodon/components/loading_indicator';
import CollectionCard from 'mastodon/components/collection_card';

const NewsmastChannels = () => {

  const dispatch = useDispatch();
  const [searchTerm, setSearchTerm] = useState('');
  const { name } = useParams();
//   const [slug, setSlug] = useState("")

  const collectionsDetail = useSelector(state => state.newsmast_detail.get('items'));
  const collectionsDetailLoading = useSelector(state => state.newsmast_detail.get('isLoading'));
  const searchChannels = useSelector(state => 
    state.getIn(['search_channels', 'items']).toJS()
  );
  
  const searchChannelsLoading = useSelector(state => 
    state.getIn(['search_channels', 'isLoading'])
  );
  
  const queryParams = new URLSearchParams(location.search);
  const newSlug = queryParams.get('slug');

  const [title, slugPart] = name?.split('?');
  const slug = slugPart?.replace('slug=', '');
  const decodedSlug = decodeURIComponent(slug);

  const channels = searchTerm ? searchChannels : collectionsDetail;
  const handleSearch = (term) => {
    setSearchTerm(term);
    if (term.trim()) {
      dispatch(fetchSearchedChannels(term));
    } else {
      dispatch(fetchNewsmastDetail("all-collection"));
    }
  };


  useEffect(() => {
    if (!searchTerm) {
      dispatch(fetchNewsmastDetail("all-collection"));
    }
  }, [searchTerm,dispatch, slug, newSlug]);

  return (
    <div className='channels'>
      <Helmet>
        <title>{title.charAt(0).toUpperCase() + title.slice(1)}</title>
      </Helmet>
      <div className='channels__header'>
        <h2 className='title'>Explore channels</h2>
        <ChannelSearch  onSearch={handleSearch} isLoading={searchChannelsLoading}/>
      </div>
     <div>
        <div style={{
            display:'flex',
            alignItems:'end',
            gap: '1rem',
            borderTop: "1px solid #e6e7eb33",
            padding: "30px 20px 0 20px",
            marginTop:"1rem"
        }}>
        <NavLink to='/collections' 
            style={{
                    color: "white",
                    border: "1px solid",
                    borderRadius: "100%",
                    padding: "0.2rem",
                    display: "flex"
            }}>
            <Icon
                id='chevron-left'
                icon={ArrowBackIcon}
                className='column-back-button__icon'
            />
        </NavLink>
        <h4 style={{
            fontWeight: '400',
            fontSize:'30px',
            lineHeight:"30px"
        }}>All</h4>
        </div>
          {searchChannelsLoading || collectionsDetailLoading ? (
            <div className='channels__loading'>
              <LoadingIndicator />
            </div>
          ) : !searchTerm && channels.length === 0 ? (
            <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '60vh' }}>
              <p style={{ fontSize: '20px' }}>No newsmast channels found</p>
            </div>
          ) : channels.length === 0 ? (
            <div style={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '60vh' }}>
              <p style={{ fontSize: '20px' }}>No newsmast channels found</p>
            </div>
          ) : (
            <div className='channels__list'>
              {channels.map((channel, index) => (
                <CollectionCard key={index} channel={channel} type="channel" />
              ))}
            </div>
          )}
     </div>
    </div>
  );
};

export default NewsmastChannels;
