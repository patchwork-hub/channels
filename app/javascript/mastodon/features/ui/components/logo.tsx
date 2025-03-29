import { Link } from "react-router-dom";

import { logo_image } from 'mastodon/initial_state';

export const Logo = () => {
    const subdomain = window.location.hostname.split('.')[0];
    const isMainChannel = window.location.hostname === 'channel.org';
    return (
        <div className='navigation-panel__logo' style={{ paddingInline: 16 }}>
            <Link to='/' className='nav-header'>
                {(subdomain === 'news') ? <img width='175px' src='./temp-images/newsmast.png' alt='news logo' /> : subdomain === 'informationtechnology' ? <img width='150px' alt='information technology logo' src='./temp-images/binarylab.png' /> : (logo_image && logo_image !== "/logo_images/original/missing.png") ? <img src={logo_image} width={250} alt='channel logo' /> : <span style={{ textTransform: 'capitalize' }}>{isMainChannel ? "Channels" : subdomain}</span>}
            </Link>
        </div>
    );
};

export const MobileLogo = () => {
    const subdomain = window.location.hostname.split('.')[0];
    const isMainChannel = window.location.hostname === 'channel.org';
    return (
        (subdomain === 'news') ? <img width='120px' src='./temp-images/newsmast.png' alt='news logo' /> : subdomain === 'informationtechnology' ? <img width='120px' alt='information technology logo' src='./temp-images/binarylab.png' /> : (logo_image && logo_image !== "/logo_images/original/missing.png") ? <img src={logo_image} width='auto' height={33} alt='channel logo' /> : <span style={{ textTransform:'capitalize' }}>{isMainChannel ? "Channels" : subdomain}</span>
    );
};