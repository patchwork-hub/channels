import { useEffect, useRef, useState } from 'react';
import SearchIcon from '@/material-icons/400-24px/channel_org_search.svg?react';

interface ChannelSearchProps {
  onSearch: (term: string) => void;
  isLoading: boolean;
}

export default function ChannelSearch({
  onSearch,
  isLoading,
}: ChannelSearchProps) {
  const [searchTerm, setSearchTerm] = useState<string>('');
  const debounceRef = useRef<NodeJS.Timeout | null>(null);

  useEffect(() => {
    if (debounceRef.current) clearTimeout(debounceRef.current);

    debounceRef.current = setTimeout(() => {
      onSearch(searchTerm.trim());
    }, 500);

    return () => {
      if (debounceRef.current) clearTimeout(debounceRef.current);
    };
  }, [searchTerm]);

  const handleSearch = (e: React.ChangeEvent<HTMLInputElement>) => {
    setSearchTerm(e.target.value);
  };

  const handleKeyDown = (e: React.KeyboardEvent<HTMLInputElement>) => {
    if (e.key === 'Enter' && searchTerm.trim() !== '') {
      if (debounceRef.current) clearTimeout(debounceRef.current);
      onSearch(searchTerm.trim());
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
            onChange={handleSearch}
            onKeyDown={handleKeyDown}
            placeholder='Search for a channel...'
            className='searchInput'
          />

          <button
            className='searchButton hiddenOnMobile'
            onClick={() => {
              handleSearch;
            }}
            disabled={!searchTerm.trim() || isLoading}
          >
            <span>Search channels</span>
          </button>
        </div>
      </div>
      <button
        className='mobileSearchButton visibleOnMobile'
        onClick={() => {
          handleSearch;
        }}
        disabled={!searchTerm.trim()}
      >
        Search channels
      </button>
    </>
  );
}
