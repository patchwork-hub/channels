
const SignInModal = () => {
    return (
        <div style={{
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
            }}>Join the conversation</h1>
            <p style={{
                color: '#D2D2FF',
                fontSize: 16,
                fontWeight: 400,
                fontFamily: 'source-sans-pro',
                textAlign: 'center',
                lineHeight: '148%'
            }}>If you already have an account with us then choose an option below to login and join in the conversation.</p>
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
            }}><span style={{
                fontFamily: 'ibm-plex-sans',
                fontSize: 27,
                fontWeight: 700,
                fontFeatureSettings: "'liga' off, 'clig' off",
                background: 'linear-gradient(180deg, #F8F8FF 50.5%, #F8F8FF 100%)',
                ["background-clip"]: 'text',
                ["-webkit-background-clip"]: 'text',
                ["-webkit-text-fill-color"]: 'transparent',
            }}>C</span>Login with Channel.org</button>
            <button style={{
                alignSelf: 'stretch',
                borderRadius: 8,
                border: 0,
                color: '#000',
                background: '#fff',
                padding: '16px 24px',
                display: 'flex',
                justifyContent: 'center',
                alignItems: 'center',
                gap: 10,
                fontSize: 14,
                fontWeight: 400,
                fontFamily: 'source-sans-pro',
                lineHeight: '16px',
            }}>
                <MastodonIcon />
                Login with Mastodon</button>
            <div style={{
                width: '100%',
                display: 'flex',
                alignItems: 'center'
            }}>
                <div style={{ flexGrow: 1, borderBottom: '1px solid rgba(220, 224, 235, 0.4)', height: 0 }}></div>
                <p style={{
                    fontFamily: 'source-sans-pro',
                    fontSize: 14,
                    fontWeight: 400,
                    color: '#fff',
                    flexShrink: 1,
                    paddingInline: 20
                }}>or</p>
                <div style={{ flexGrow: 1, borderBottom: '1px solid rgba(220, 224, 235, 0.4)', height: 0 }}></div>
            </div>
            <button style={{
                alignSelf: 'stretch',
                borderRadius: 8,
                border: '1px solid #D2D2FF',
                color: '#fff',
                background: 'transparent',
                padding: '9px 15px',
                display: 'flex',
                justifyContent: 'center',
                alignItems: 'center',
                gap: 10,
                fontSize: 17,
                fontWeight: 400,
                lineHeight: '148%',
                fontFamily: 'source-sans-pro',
            }}>Continue as a guest</button>
            <p style={{
                fontFamily: 'source-sans-pro',
                fontSize: 16,
                fontWeight: 400,
                lineHeight: '148%',
                color: '#D2D2FF',
                textAlign: 'center'
            }}>Don’t have an account? <a style={{ textDecoration: 'underline' }}>Create one now</a></p>
        </div>
    )
}

const MastodonIcon = () => (
    <svg
        xmlns="http://www.w3.org/2000/svg"
        width="19"
        height="20"
        fill="none"
        viewBox="0 0 19 20"
    >
        <g clipPath="url(#clip0_29_57)">
            <path
                fill="#8C8DFF"
                d="M17.89 6.909c0-3.908-2.59-5.053-2.59-5.053-2.54-1.154-9.289-1.142-11.805 0 0 0-2.59 1.145-2.59 5.053 0 4.651-.268 10.428 4.293 11.622 1.647.43 3.061.523 4.2.459 2.065-.113 3.224-.728 3.224-.728l-.07-1.484s-1.475.459-3.134.407c-1.642-.057-3.373-.177-3.643-2.171a4.081 4.081 0 01-.036-.56c3.48.841 6.448.367 7.265.27 2.28-.27 4.267-1.66 4.52-2.93.399-2.003.366-4.885.366-4.885zm-3.053 5.033h-1.895v-4.59c0-1.999-2.601-2.075-2.601.276v2.513H8.458V7.628c0-2.352-2.601-2.275-2.601-.277v4.59h-1.9c0-4.908-.211-5.945.749-7.035 1.052-1.161 3.244-1.238 4.22.246l.471.784.471-.784c.98-1.492 3.176-1.4 4.22-.246.964 1.098.748 2.131.748 7.036h.001z"
            ></path>
        </g>
        <defs>
            <clipPath id="clip0_29_57">
                <path
                    fill="#fff"
                    d="M0 0H18.208V20.583H0z"
                    transform="translate(.292 -.292)"
                ></path>
            </clipPath>
        </defs>
    </svg>
)

export default SignInModal;