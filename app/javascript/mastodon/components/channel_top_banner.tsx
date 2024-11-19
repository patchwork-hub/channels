import { header_image } from "mastodon/initial_state";

const ChannelTopBanner:React.FC = ()=>{

    return (
        <div style={{
            display:'flex',
            flexDirection:'column-reverse',
            padding:20,
            width:'100%',
            aspectRatio:'1.96',
            background:`white, url(${header_image}) lightgray 50% / cover no-repeat`
        }}> </div>
    )
}

export default ChannelTopBanner;