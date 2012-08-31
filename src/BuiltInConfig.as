package  {
	import org.flowplayer.controls.Controls;
	import org.flowplayer.h264streaming.H264StreamProvider;
	import org.flowplayer.view.Launcher;

//import org.flowplayer.rtmp.RTMPStreamProvider;
//import org.flowplayer.controls.Controls;
//    import org.flowplayer.shareembed.ShareEmbed;
//    import org.flowplayer.pseudostreaming.PseudoStreaming;
    
	public class BuiltInConfig 
	{
//    private var pseudo:org.flowplayer.rtmp.RTMPStreamProvider;
//    private var controls:org.flowplayer.controls.Controls;
//    private var share:org.flowplayer.shareembed.ShareEmbed;
//    private var pseudo:org.flowplayer.pseudostreaming.PseudoStreamProvider;

    [Embed(source="../assets/play.png")]
    public var PlayButton:Class;

	[Embed(source="../assets/CanvasLogo.swf")]
	public static var CanvasLogo:Class;
	
	[Embed(source="../assets/PlayOverlay.swf")]
	public static var PlayOverlay:Class;
	
	[Embed(source="../assets/BufferAnimation.swf")]
	public static var BufferAnimation:Class;
	
	[Embed(source="../assets/LabelHolder.swf")]
	public static var LabelHolder:Class;
	
	[Embed(source="../assets/LabelHolderLeft.swf")]
	public static var LabelHolderLeft:Class;
	
	[Embed(source="../assets/LabelHolderRight.swf")]
	public static var LabelHolderRight:Class;
	
	[Embed(source="../assets/logo.png")]
    public var Logo:Class;

	private var _hsp : org.flowplayer.h264streaming.H264StreamProvider = null;
	private var _ctl : org.flowplayer.controls.Controls = null;
	//private var _lct : org.flowplayer.view.Launcher = null;
	
    public static const config:Object = { 
       "plugins": {
		   "h264streaming": {
			   "url": 'org.flowplayer.h264streaming.H264StreamProvider'
		   },
//           "psuedo": {
//               "url": 'org.flowplayer.psuedostreaming.PseudoStreamProvider'
//           }
//        "rtmp": {
//            "url": 'org.flowplayer.rtmp.RTMPStreamProvider'
//        },
        "controls": {
            "url": 'org.flowplayer.controls.Controls'
		}
//           viral: {
//               url: 'org.flowplayer.shareembed.ShareEmbed'
           }
       }
    }; 
}