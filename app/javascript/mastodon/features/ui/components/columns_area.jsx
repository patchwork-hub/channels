import PropTypes from 'prop-types';
import { Children, cloneElement, useCallback } from 'react';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';

import { supportsPassiveEvents } from 'detect-passive-events';

import { scrollRight } from '../../../scroll';
import BundleContainer from '../containers/bundle_container';
import {
  Compose,
  NotificationsWrapper,
  HomeTimeline,
  CommunityTimeline,
  PublicTimeline,
  HashtagTimeline,
  DirectTimeline,
  FavouritedStatuses,
  BookmarkedStatuses,
  ListTimeline,
  Directory,
} from '../util/async-components';
import { useColumnsContext } from '../util/columns_context';

import BundleColumnError from './bundle_column_error';
import { ColumnLoading } from './column_loading';
import ComposePanel from './compose_panel';
import DrawerLoading from './drawer_loading';
import Navigations from './navigations';
import { Link } from 'react-router-dom';
import Logo from "@/images/icons/icon-logo.svg";
import BurgerMenu from '@/images/icons/icon-burger-menu.svg';
import BurgerMenuClose from '@/images/icons/icon-burger-menu-close.svg';
import FeedIcon from '@/material-icons/400-24px/feed_icon.svg?.react';
import ColumnLink from './column_link';
import { channel_display_name, custom_links, logo_image } from 'mastodon/initial_state';
import { icons } from './navIcons';

const componentMap = {
  COMPOSE: Compose,
  HOME: HomeTimeline,
  NOTIFICATIONS: NotificationsWrapper,
  PUBLIC: PublicTimeline,
  REMOTE: PublicTimeline,
  COMMUNITY: CommunityTimeline,
  HASHTAG: HashtagTimeline,
  DIRECT: DirectTimeline,
  FAVOURITES: FavouritedStatuses,
  BOOKMARKS: BookmarkedStatuses,
  LIST: ListTimeline,
  DIRECTORY: Directory,
};

const TabsBarPortal = () => {
  const { setTabsBarElement } = useColumnsContext();

  const setRef = useCallback(
    (element) => {
      if (element) setTabsBarElement(element);
    },
    [setTabsBarElement],
  );

  return <div id='tabs-bar__portal' ref={setRef} />;
};

export default class ColumnsArea extends ImmutablePureComponent {
  static propTypes = {
    columns: ImmutablePropTypes.list.isRequired,
    isModalOpen: PropTypes.bool.isRequired,
    singleColumn: PropTypes.bool,
    children: PropTypes.node,
  };

  // Corresponds to (max-width: $no-gap-breakpoint + 285px - 1px) in SCSS
  mediaQuery =
    'matchMedia' in window && window.matchMedia('(max-width: 1174px)');

  state = {
    renderComposePanel: !(this.mediaQuery && this.mediaQuery.matches),
    isMenuOpen: false,
    currentYear: new Date().getFullYear()
  };

  componentDidMount() {
    if (!this.props.singleColumn) {
      this.node.addEventListener(
        'wheel',
        this.handleWheel,
        supportsPassiveEvents ? { passive: true } : false,
      );
    }

    if (this.mediaQuery) {
      if (this.mediaQuery.addEventListener) {
        this.mediaQuery.addEventListener('change', this.handleLayoutChange);
      } else {
        this.mediaQuery.addListener(this.handleLayoutChange);
      }
      this.setState({ renderComposePanel: !this.mediaQuery.matches });
    }

    this.isRtlLayout = document
      .getElementsByTagName('body')[0]
      .classList.contains('rtl');
  }

  UNSAFE_componentWillUpdate(nextProps) {
    if (
      this.props.singleColumn !== nextProps.singleColumn &&
      nextProps.singleColumn
    ) {
      this.node.removeEventListener('wheel', this.handleWheel);
    }
  }

  componentDidUpdate(prevProps) {
    if (
      this.props.singleColumn !== prevProps.singleColumn &&
      !this.props.singleColumn
    ) {
      this.node.addEventListener(
        'wheel',
        this.handleWheel,
        supportsPassiveEvents ? { passive: true } : false,
      );
    }
  }

  componentWillUnmount() {
    if (!this.props.singleColumn) {
      this.node.removeEventListener('wheel', this.handleWheel);
    }

    if (this.mediaQuery) {
      if (this.mediaQuery.removeEventListener) {
        this.mediaQuery.removeEventListener('change', this.handleLayoutChange);
      } else {
        this.mediaQuery.removeListener(this.handleLayoutChange);
      }
    }
  }

  handleChildrenContentChange() {
    if (!this.props.singleColumn) {
      const modifier = this.isRtlLayout ? -1 : 1;
      this._interruptScrollAnimation = scrollRight(
        this.node,
        (this.node.scrollWidth - window.innerWidth) * modifier,
      );
    }
  }

  handleLayoutChange = (e) => {
    this.setState({ renderComposePanel: !e.matches });
  };

  handleWheel = () => {
    if (typeof this._interruptScrollAnimation !== 'function') {
      return;
    }

    this._interruptScrollAnimation();
  };

  handleOpenMenu = () => {
    this.setState((prevState) => ({
      isMenuOpen: !prevState.isMenuOpen,
    }));
  };

  setRef = (node) => {
    this.node = node;
  };

  renderLoading = (columnId) => () => {
    return columnId === 'COMPOSE' ? (
      <DrawerLoading />
    ) : (
      <ColumnLoading multiColumn />
    );
  };

  renderError = (props) => {
    return <BundleColumnError multiColumn errorType='network' {...props} />;
  };

  render() {
    const { columns, children, singleColumn, isModalOpen } = this.props;
    const { renderComposePanel, isMenuOpen } = this.state;

    const navItems = custom_links && typeof custom_links === 'string' ? JSON.parse(custom_links) : custom_links;

    const subdomain = window.location.hostname.split('.')[0];
    if (singleColumn) {
      return (
        <div className='columns-area__panels'>
          <div className='columns-area__panels__pane columns-area__panels__pane--compositional'>
            <div className='columns-area__panels__pane__inner'>
              {renderComposePanel && <ComposePanel />}
            </div>
          </div>

          <div className='columns-area__panels__main'>
            <div className='tabs-bar__wrapper'>
              <TabsBarPortal />
            </div>
            <div className='columns-area columns-area--mobile'>
              <div className='columns-area__top-nav-wrap'>
                <nav className='columns-area__top-nav'>
                  <div className='columns-area__top-nav__burger-menu'>
                    <button className='columns-area__top-nav__burger-menu__btn' onClick={this.handleOpenMenu}>
                      <img
                        src={isMenuOpen ? BurgerMenuClose : BurgerMenu}
                        className='columns-area__top-nav__burger-menu__icon'
                        alt='menu'
                      />
                    </button>
                    <Link to='/'>
                      {(subdomain==='news') ? <img width='120px' src='./temp-images/newsmast.png' alt='news logo' />:subdomain==='informationtechnology'?<img width='120px' alt='information technology logo' src='./temp-images/binarylab.png' />:logo_image?<img src={logo_image} width={120} style={{ aspectRatio:'36 / 10'}} alt='channel logo' />:channel_display_name}
                    </Link>
                  </div>

                  <div className='columns-area__top-nav__explore-channels'>
                    <Link to='/explore-channels'>
                      <button>Explore channels</button>
                    </Link>
                  </div>
                </nav>
              </div>
              <div className={`columns-area__sidebar ${isMenuOpen && 'columns-area__sidebar__open'}`}>
                <div className='nav-links'>
                  <ColumnLink
                    transparent
                    badge={true}
                    to='/public'
                    icon='feed'
                    iconComponent={FeedIcon}
                    activeIconComponent={FeedIcon}
                    text='Feed'
                  />
                  {
                    Object.values(navItems).map((it, index) => (
                      <ColumnLink
                        key={index}
                        badge={true}
                        transparent
                        href={it.url}
                        icon={it.icon}
                        target='_blank'
                        iconComponent={icons[it.icon]}
                        activeIconComponent={icons[it.icon]}
                        text={it.name}
                      />
                    ))}
                </div>

                <footer className='footer'>
                  <ul>
                    {/* <li>
                            <NavLink to='/terms' className='footer-link'>
                              Terms & Conditions
                            </NavLink>
                          </li> */}
                    <li>
                      <a
                        href='https://channel.org/privacy-policy/'
                        target='_blank'
                        className='footer-link'
                      >
                        Privacy Policy
                      </a>
                    </li>
                    <li>
                      <a
                        href='https://github.com/patchwork-hub/'
                        target='_blank'
                        className='footer-link'
                      >
                        Source Code
                      </a>
                    </li>
                  </ul>
                  <a href='https://home.channel.org/' target='_blank'>
                    <img src={Logo} className='columns-area__footer-logo' alt='logo' />
                  </a>
                </footer>
              </div>
              <main className='columns-area__main'>
                {children}
              </main>
            </div>
          </div>

          <div className='columns-area__panels__pane columns-area__panels__pane--start columns-area__panels__pane--navigational'>
            <div className='columns-area__panels__pane__inner'>
              {/* <NavigationPanel /> */}
              <Navigations />
            </div>
          </div>
        </div>
      );
    }

    return (
      <div
        className={`columns-area ${isModalOpen ? 'unscrollable' : ''}`}
        ref={this.setRef}
      >
        {columns.map((column) => {
          const params =
            column.get('params', null) === null
              ? null
              : column.get('params').toJS();
          const other = params && params.other ? params.other : {};

          return (
            <BundleContainer
              key={column.get('uuid')}
              fetchComponent={componentMap[column.get('id')]}
              loading={this.renderLoading(column.get('id'))}
              error={this.renderError}
            >
              {(SpecificComponent) => (
                <SpecificComponent
                  columnId={column.get('uuid')}
                  params={params}
                  multiColumn
                  {...other}
                />
              )}
            </BundleContainer>
          );
        })}

        {Children.map(children, (child) =>
          cloneElement(child, { multiColumn: true }),
        )}
      </div>
    );
  }
}
