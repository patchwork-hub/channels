import { useSearchParams } from '@/hooks/useSearchParam';
import { useState, useTransition } from 'react';
import SearchIcon from '@/material-icons/400-24px/channel_org_search.svg?react';
import { useHistory } from 'react-router-dom';
import { LoadingIndicator } from 'mastodon/components/loading_indicator';

export default function ChannelSearch() {
  const searchParams = useSearchParams();
  const keyword = searchParams.get('key');
  const [searchTerm, setSearchTerm] = useState<string>(keyword ?? '');
  const [isEnabled, setIsEnabled] = useState<boolean>(false);
  const [, startTransition] = useTransition();
  const router = useHistory();

  const handleSearch = () => {
    // setIsEnabled(tr ue);
    // if (searchTerm.trim()) {
    //   startTransition(() => {
    //     router.push(`/search/list?key=${searchTerm}`);
    //   });
    // }
  };

  const handleKeyDown = (event: React.KeyboardEvent<HTMLInputElement>) => {
    if (event.key === 'Enter') {
      handleSearch();
    }
  };

  return (
    <>
      <div className='channelSearchContainer'>
        <div className='searchInputContainer'>
          <div className='searchIcon'>
            <SearchIcon />
          </div>
          <input
            type='text'
            value={searchTerm}
            onChange={(e) => setSearchTerm(e.target.value)}
            onKeyDown={handleKeyDown}
            placeholder='Search for a channel...'
            className='searchInput'
          />

          <button
            className='searchButton hiddenOnMobile'
            onClick={handleSearch}
            disabled={!searchTerm.trim()}
          >
            {isEnabled ? <>...</> : <span>Search channels</span>}
          </button>
        </div>
      </div>
      <button
        className='mobileSearchButton visibleOnMobile'
        onClick={handleSearch}
        disabled={!searchTerm.trim()}
      >
        Search channels
      </button>
    </>
  );
}
