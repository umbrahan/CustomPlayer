/*    
 *    Copyright (c) 2008, 2009 Flowplayer Oy
 *
 *    This file is part of Flowplayer.
 *
 *    Flowplayer is free software: you can redistribute it and/or modify
 *    it under the terms of the GNU General Public License as published by
 *    the Free Software Foundation, either version 3 of the License, or
 *    (at your option) any later version.
 *
 *    Flowplayer is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License
 *    along with Flowplayer.  If not, see <http://www.gnu.org/licenses/>.
 */

package org.flowplayer.view {
	
	import flash.net.NetStreamPlayOptions;
	import flash.net.NetStreamPlayTransitions;
	import flash.net.NetStream;
	
	import flash.media.Video;	
	import flash.media.StageVideo;	
	import flash.media.StageVideoAvailability;
	
	import flash.geom.Rectangle;
	import flash.geom.Point;
	
	import flash.display.Stage;
	
	import flash.events.Event;
	import flash.events.StageVideoAvailabilityEvent;
	import flash.events.StageVideoEvent;

	import org.flowplayer.model.Clip;
	import org.flowplayer.model.ClipEventType;
	import org.flowplayer.util.Log;

	import flash.utils.*;

	/**
	 * @author api
	 */
	public class StageVideoWrapper extends Video {

		private var _stageVideo:StageVideo;
		private var _stage:Stage;
		
		private var _clip:Clip;
		
		private var _netStream:NetStream = null;
		private var _hasStageVideo:Boolean = false;
		private var _visible:Boolean = true;
		
		private var log:Log = new Log(this);
		
		public function StageVideoWrapper(clip:Clip) {
			super();
			
			_clip = clip;
			addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
			addEventListener(Event.REMOVED_FROM_STAGE, onRemovedFromStage);
		}
		
		private function onAddedToStage(event:Event):void {
			_stage = stage;
			_stage.addEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY, onAvailabilityChanged);
		}
		
		private function onRemovedFromStage(event:Event):void {
			_stage.removeEventListener(StageVideoAvailabilityEvent.STAGE_VIDEO_AVAILABILITY, onAvailabilityChanged);
			_stage = null;
		}

		public function get stageVideo():StageVideo {
			return hasStageVideo ? _stageVideo : null;
		}

		public function get hasStageVideo():Boolean {
			return _hasStageVideo;
		}

		private function onAvailabilityChanged(event:StageVideoAvailabilityEvent):void {
			log.debug("StageVideo Availability changed: " + event.availability);
			
			var availableNow:Boolean = event.availability == StageVideoAvailability.AVAILABLE;
			useStageVideo(availableNow)
		}

		private function useStageVideo(availableNow:Boolean):void {
			log.debug("useStageVideo : "+ availableNow);
				
			_hasStageVideo = availableNow;
			
			if ( _hasStageVideo && _stage.stageVideos.length ) {
				_stageVideo = _stage.stageVideos[0];
				super.visible = false;
			} else {
				super.visible = true;
				_hasStageVideo = false;
			}
			
			attachNetStream(_netStream);
		}

		override public function attachNetStream(netStream:NetStream):void {
			_netStream = netStream;
			if ( hasStageVideo ) {
				log.info("Attaching netstream to stageVideo");
				
				stageVideo.attachNetStream(_netStream);
				stageVideo.addEventListener(StageVideoEvent.RENDER_STATE, _displayStageVideo);
				
			} else {
				log.info("Attaching netstream to video");
				
				super.attachNetStream(_netStream);
				
				if ( _stageVideo != null ) 
					_stageVideo.attachNetStream(null);
					
				visible = _visible;
				_clip.dispatch(ClipEventType.STAGE_VIDEO_STATE_CHANGE, stageVideo);
			}
		}
		
		private function _displayStageVideo(event:StageVideoEvent):void {
			if(event.status != 'software')
				return;
				
			stageVideo.removeEventListener(StageVideoEvent.RENDER_STATE, _displayStageVideo);
			super.attachNetStream(null);
			
			visible = _visible;
			_clip.dispatch(ClipEventType.STAGE_VIDEO_STATE_CHANGE, stageVideo);
		}
		
		override public function get videoWidth():int {
			return hasStageVideo ? stageVideo.videoWidth : super.videoWidth;
		}

		override public function get videoHeight():int {
			return hasStageVideo ? stageVideo.videoHeight : super.videoHeight;
		}
	
		override public function set visible(value:Boolean):void {
            log.debug("set visible " + value);
			_visible = value;
			if ( hasStageVideo ) {
				_updateStageVideo();
				super.visible = false;
			} else {
				super.visible = _visible;
			}
		}
		
		override public function get visible():Boolean {
			return _visible;
		}
	
		private function _updateStageVideo():void {
			if ( ! hasStageVideo )
				return;
			
			var p:Point = localToGlobal(new Point(x, y));
			var r:Rectangle = _visible ? new Rectangle(p.x, p.y, width, height) : new Rectangle(0, 0, 0, 0);
			log.debug("Resizing view port to "+ r.width + "x"+ r.height + " - "+r.x+";"+r.y);
			_stageVideo.viewPort = r;
			
			_clip.dispatch(ClipEventType.STAGE_VIDEO_STATE_CHANGE, stageVideo);
		}

		override public function set width(value:Number):void {
			super.width = value;
			_updateStageVideo();
		}
		
		override public function set height(value:Number):void {
			super.height = value;
			_updateStageVideo();
		}

		override public function set x(value:Number):void {
			super.x = value;
			_updateStageVideo();
		}
		
		override public function set y(value:Number):void {
			super.y = value;
			_updateStageVideo();
		}
    }
}
