/*
 * This file is part of Flowplayer, http://flowplayer.org
 *
 * By: Arjen Wagenaar, <h264@code-shop.com>
 * Copyright (c) 2009 CodeShop B.V.
 *
 * Released under the MIT License:
 * http://www.opensource.org/licenses/mit-license.php
 *
 * Pseudostreaming is a protocol that can be installed on regular HTTP
 * servers such as Lighttpd, Apache and Nginx. An example of server side
 * technologies that support H264 pseudostreaming can be found here:
 * http://h264.code-shop.com
 */

package org.flowplayer.h264streaming {
	import org.flowplayer.controller.NetStreamControllingStreamProvider;
	import org.flowplayer.model.Clip;
	import org.flowplayer.model.ClipEvent;
	import org.flowplayer.model.ClipEventType;
	import org.flowplayer.model.Plugin;
	import org.flowplayer.model.PluginModel;
	import org.flowplayer.util.Assert;
	import org.flowplayer.util.Log;
	import org.flowplayer.util.PropertyBinder;
	import org.flowplayer.view.Flowplayer;
	
	import flash.events.NetStatusEvent;
	import flash.net.NetStream;		

	/**
	 * @author api
	 */
	public class H264StreamProvider extends NetStreamControllingStreamProvider implements Plugin {
		private var _bufferStart:Number;
		private var _config:Config;
		private var _keyFrameTimes:Array;
		private var _clipWithKeyframeInfo:Clip;
		private var _serverSeekInProgress:Boolean;
		private var _startSeekDone:Boolean;
		private var _model:PluginModel;

    private var _seekTime:Number;

		/**
		 * Called by the player to set my config.
		 */
		override public function onConfig(model:PluginModel):void {
			_model = model;
			_config = new PropertyBinder(new Config(), null).copyProperties(model.config) as Config;
		}
		
		/**
		 * Called by the player to set the Flowplayer API.
		 */
		override public function onLoad(player:Flowplayer):void {
			log.info("onLoad, registering metadata listener");
			_model.dispatchOnLoad();
		}

		override protected function doLoad(event:ClipEvent, netStream:NetStream, clip:Clip):void {
			log.info("onStart");
			_bufferStart = clip.start;
			_startSeekDone = false;
      _seekTime = 0;
			super.doLoad(event, netStream, clip);
		}

		override protected function getClipUrl(clip:Clip):String {
			var requestUrl:String = getClipUrlWithStartParam(clip, 0);
			log.debug("getClipUrl, request url is " + requestUrl);
			return requestUrl;
		}
		
		private function setKeyframeData(metaData:Object):void {
			log.debug("extracting keyframe times and filepositions");
			for (var prop:String in metaData) {
				log.debug(metaData[prop]);
			}
			try {
				Assert.notNull(metaData, "clip does not have any metadata, cannot use h264streaming");
				
				if (! metaData.seekpoints) {
					log.info("No seekpoints in this file, random seeking cannot be done");
					return;
				}

        _keyFrameTimes = new Array();
        for (var j:Number = 0; j != metaData.seekpoints.length; ++j) {
          _keyFrameTimes[j] = Number(metaData.seekpoints[j]['time']);
          log.debug("keyFrame[" + j + "] = " + _keyFrameTimes[j]);
        }
				
			} catch (e:Error) {
				log.error("error getting keyframes " + e.message);
				clip.dispatch(ClipEventType.ERROR, e.message);
			}
		}

		override protected function doSeek(event:ClipEvent, netStream:NetStream, seconds:Number):void {
			var target:Number = getClosestKeyFrame(clip.start + seconds);

			if (isInBuffer(target)) {
				log.debug("seeking inside buffer, target " + target + " seconds");
				netStream.seek(target - _seekTime);
			} else {
				serverSeek(netStream, target);
			} 
		}
		
//		override protected function doStop(event:ClipEvent, netStream:NetStream):void {
//			silentSeek = true;
//			doSeek(null, netStream, 0);
//			netStream.pause();
//			dispatchEvent(event);
//		}
		
		override public function get bufferStart():Number {
			if (! clip) return 0;
			return _bufferStart - clip.start;
		}

		override public function get bufferEnd():Number {
			if (! netStream) return 0;
			if (! clip) return 0;
			return bufferStart + netStream.bytesLoaded/netStream.bytesTotal * (clip.duration - bufferStart);
		}

		override protected function getCurrentPlayheadTime(netStream:NetStream):Number {
			if (! clip) return 0;

			var value:Number = netStream.time - clip.start + _seekTime;
			return value < 0 ? 0 : value;
		}
		
		override public function get allowRandomSeek():Boolean {
			return _keyFrameTimes != null && _keyFrameTimes.length > 0;
		}

		private function getClipUrlWithStartParam(clip:Clip, start:Number = undefined):String {
			var url:String = clip.completeUrl;
			var startPos:Number = start >= 0 ? start : clip.start;
			return appendQueryString(url, startPos);
		}
		
		private function isInBuffer(seconds:Number):Boolean {
			if (!_keyFrameTimes) {
				log.debug("No keyframe data available, can only seek inside the buffer");
				return true;
			}
			return bufferStart <= seconds - clip.start && seconds - clip.start <= bufferEnd;
		}

		private function serverSeek(netStream:NetStream, seconds:Number, setBufferStart:Boolean = true, silent:Boolean = false):void {
      seconds = getClosestKeyFrame(seconds);

      _seekTime = seconds;

			if (setBufferStart)
				_bufferStart = seconds;
			var requestUrl:String = getClipUrlWithStartParam(clip, seconds);
			log.debug("doing server seek, url " + requestUrl);
			if (! silent) {
				_serverSeekInProgress = true;
			}
			netStream.play(requestUrl);
		}

		private function appendQueryString(url:String, start:Number):String {
			return url + _config.queryString.replace("${start}", start);
		}

		private function getClosestKeyFrame(seekPosition: Number, rangeBegin:Number = 0, rangeEnd:Number = 9999999999999):Number {
//      return seekPosition;

			log.debug("finding closest keyframe position, number of positions available " + _keyFrameTimes.length + ", seekPosition " + seekPosition + ", b=" + rangeBegin + ", e=" + rangeEnd);

			if (rangeEnd >= _keyFrameTimes.length) {
				rangeEnd = _keyFrameTimes.length - 1;
			}
			
			if (rangeBegin >= rangeEnd) 
			{
				return _keyFrameTimes[rangeBegin];
			}
			
			var rangeMid:Number = Math.floor((rangeEnd + rangeBegin)/2); 
			if (_keyFrameTimes[rangeMid] >= seekPosition)
				return getClosestKeyFrame(seekPosition, rangeBegin, rangeMid); 
			else
				return getClosestKeyFrame(seekPosition, rangeMid+1, rangeEnd); 
		}
		
		override protected function onMetaData(event:ClipEvent):void {
			if (_startSeekDone) {
				return;
			}
			
			log.info("received metaData for clip" + Clip(event.target));
			log.debug("clip is " + clip);
			if (!_clipWithKeyframeInfo || _clipWithKeyframeInfo != event.target) {
				setKeyframeData(Clip(event.target).metaData);
			}
			_clipWithKeyframeInfo = event.target as Clip;

			clip.dispatch(ClipEventType.START, pauseAfterStart);
			if (pauseAfterStart) {
				clip.dispatch(ClipEventType.PAUSE);
			}
			
			// at this point we seek to the start position if it's greater than zero
			log.debug("seeking to start, pausing after start: " + pauseAfterStart);
			if (clip.start > 0) {
				serverSeek(netStream, clip.start, true, true);
				_startSeekDone = true;

			} else if (pauseAfterStart) {
				netStream.seek(0);
				pauseAfterStart = false;
			}
		}

		override protected function canDispatchBegin():Boolean {
			if (_serverSeekInProgress) return false;
			if (clip.start > 0 && ! _startSeekDone) return false;
			return true;
		}

		override protected function onNetStatus(event:NetStatusEvent):void {
			log.info("onNetStatus: " + event.info.code);
			if (event.info.code == "NetStream.Play.Start") {



				log.debug("started, will pause after start: " + pauseAfterStart);
				// we need to pause here because the stream was started when server-seeking to start pos
				if (paused || pauseAfterStart) {
					log.info("started: pausing to pos 0 in netStream");
					netStream.seek(0);
					pause(null);
					if (_startSeekDone) {
						pauseAfterStart = false;
					}
				}
				// at this stage the server seek is in target, and we can dispatch the seek event
				if (_serverSeekInProgress) {
					_serverSeekInProgress = false;
					clip.dispatch(ClipEventType.SEEK, seekTarget);
				} 
			}
		}
		
		public function getDefaultConfig():Object {
			return null;
		}
	}
}

