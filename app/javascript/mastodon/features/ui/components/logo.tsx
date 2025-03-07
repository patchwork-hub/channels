import { Link } from "react-router-dom";

import { logo_image } from 'mastodon/initial_state';

export const Logo = () => {
    const subdomain = window.location.hostname.split('.')[0];
    return (
        <div className='navigation-panel__logo' style={{ paddingInline: 16 }}>
            <Link to='/' className='nav-header'>
                {(subdomain === 'news') ? <img width='175px' src='./temp-images/newsmast.png' alt='news logo' /> : subdomain === 'informationtechnology' ? <img width='150px' alt='information technology logo' src='./temp-images/binarylab.png' /> : (logo_image && logo_image !== "/logo_images/original/missing.png") ? <img src={logo_image} width={250} alt='channel logo' /> : <span style={{ textTransform:'capitalize' }}>{subdomain}</span>}
            </Link>
        </div>
    );
};