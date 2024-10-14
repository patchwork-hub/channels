import { ShortNumber } from 'mastodon/components/short_number';
import { ParticipantsCounter } from './counters';

interface ChannelTopBannerProps {
    src:string;
    name:string;
    participants:number;
}

const ChannelTopBanner:React.FC<ChannelTopBannerProps> = ({
    src,name,participants
})=>{
    return (
        <div style={{
            display:'flex',
            flexDirection:'column-reverse',
            padding:20,
            width:'100%',
            aspectRatio:'1.96',
            background: `linear-gradient(180deg, rgba(43, 43, 43, 0.00) 0%, rgba(37, 37, 37, 0.60) 56.93%), url(${src}) lightgray 50% / cover no-repeat`
        }}>
            <div style={{ display:'flex', flexDirection:'column', gap:5 }}>
                <p 
                className="channel_name_in_top_banner"
                style={{
                    color:'#fff',
                    fontSize:24,
                    fontWeight:600,
                    letterSpacing:0.24
                }}>{name}</p>
                <div 
                    className="participants_counter">
                    <ShortNumber value={participants} renderer={ParticipantsCounter} />
                </div>
            </div>
        </div>
    )
}

export default ChannelTopBanner;