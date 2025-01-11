
const SignInWithMastodonModal = () => {
    return (
        <div className="modal-root__modal" style={{
            display: 'flex',
            flexDirection: 'column',
            alignItems: 'center',
            gap: '30px',
            maxWidth: '530px',
            background: '#16161D',
            border: '1px solid rgba(230, 231, 235, 0.2)',
            borderRadius: '10px',
            padding: '40px'
        }}>
            <h1 style={{
                fontSize: 30,
                fontWeight: 700,
                fontFamily: "ibm-plex-sans",
                fontFeatureSettings: "liga off, clig off",
                lineHeight: '120%',
                background: 'linear-gradient(180deg, #F8F8FF 50.5%, #BABAF8 100%)',
                backgroundClip: 'text',
                ['-webkit-background-clip']: 'text',
                ['-webkit-text-fill-color']: 'transparent',
            }}>Sign in with Mastodon</h1>
            <p style={{
                color: '#D2D2FF',
                fontSize: 16,
                fontWeight: 400,
                fontFamily: 'source-sans-pro',
                textAlign: 'center',
                lineHeight: '148%'
            }}>Enter your server name below to login with Mastodon.</p>
            <div style={{
                alignSelf:'stretch',
                display:'flex',
                flexDirection:'column',
                gap:10,
            }}>
            <label htmlFor="server-input" style={{
                fontFamily:'source-sans-pro',
                fontSize:16,
                fontWeight:400,
                lineHeight:'148%',
                color:'#D2D2FF',
            }}>Server name <span style={{ color:'#E42021' }}>*</span></label>
            <input id="server-input" placeholder="Example mastodon.social" style={{
                padding:'14px 16px',
                borderRadius:3,
                border:'1px solid rgba(255, 255, 255, 0.50)',
                background:'transparent',
                color:'#fff'
            }}/>
            </div>
            <button style={{
                alignSelf: 'stretch',
                borderRadius: 8,
                border: 0,
                color: '#fff',
                background: '#FF3C26',
                padding: '9px 15px',
                display: 'flex',
                justifyContent: 'center',
                alignItems: 'center',
                gap: 10,
                fontSize: 17,
                fontWeight: 400,
                fontFamily: 'source-sans-pro',
                lineHeight: '148%'
            }}>Sign In</button>
        </div>
    )
}

export default SignInWithMastodonModal;