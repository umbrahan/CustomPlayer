/*
 *    Copyright (c) 2008 - 2010 Flowplayer Oy
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
    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import flash.display.Sprite;
    import flash.display.StageAlign;
    import flash.display.StageDisplayState;
    import flash.display.StageScaleMode;
    import flash.events.Event;
    import flash.events.ProgressEvent;
    import flash.system.ApplicationDomain;
    import flash.utils.*;
    import flash.utils.getDefinitionByName;
    
    import mx.preloaders.IPreloaderDisplay;
    import mx.preloaders.Preloader;
    
    import org.flowplayer.util.Arrange;
    import org.flowplayer.util.Log;
    import org.flowplayer.util.LogConfiguration;

    public class Preloader extends MovieClip implements mx.preloaders.IPreloaderDisplay
	{
        private var _log:Log = new Log(this);
        private var _app:DisplayObject;
        // this variable can be set from external SWF files, if it's set well use it to construct the config
        public var injectedConfig:String;

        public function Preloader() {

            var logConfig:LogConfiguration = new LogConfiguration();
            logConfig.level = "debug";
            logConfig.filter = "org.flowplayer.view.Preloader";
            Log.configure(logConfig);
            _log.debug("Preloader");

            stop();
            addEventListener(Event.ADDED_TO_STAGE, onAddedToStage);
        }
        
        private function onStageResize(e:Event):void{
          setParentDimensions();
        }

        private function setParentDimensions():void{
          if(stage.displayState == StageDisplayState.FULL_SCREEN || (Arrange.set && !Arrange.hasParent)){
            Arrange.parentWidth=stage.stageWidth;
            Arrange.parentHeight=stage.stageHeight;
            return;
          }
          if(Arrange.set && Arrange.hasParent){
            Arrange.parentWidth  = Arrange.localWidth;
            Arrange.parentHeight = Arrange.localHeight;
            return;
          } 
          var p:Object = parent;
          while(p){
            if(p.width !=0 && p.height !=0 && getQualifiedClassName(p) != 'mx.controls::SWFLoader'){
              Arrange.parentWidth =Arrange.localWidth  = p.width;
              Arrange.parentHeight = Arrange.localHeight = p.height;
              Arrange.hasParent = true;
              break;
            }
            p=p.parent;
          }
          if(Arrange.parentWidth == 0 && Arrange.parentHeight == 0){
            Arrange.parentWidth = stage.stageWidth;
            Arrange.parentHeight = stage.stageHeight;
          }
          Arrange.set = true;
        }
        
        private function onAddedToStage(event:Event):void {
            log("onAddedToStage(): stage size is " + Arrange.parentWidth + " x " + Arrange.parentHeight);
            log("onAddedToStage(), bytes loaded " + loaderInfo.bytesLoaded);
            stage.addEventListener(Event.RESIZE, onStageResize, false, 1);
            setParentDimensions();
            
            addEventListener(Event.ENTER_FRAME, enterFrameHandler);
        }

        private function enterFrameHandler(evt:Event):void {
            log("enterFrameHandler() " + loaderInfo.bytesLoaded);

            if (loaderInfo.bytesLoaded == loaderInfo.bytesTotal) {
                log("bytesLoaded == bytesTotal, stageWidth = " + Arrange.parentWidth + " , stageHeight = " + Arrange.parentHeight);
                if (Arrange.parentWidth != 0 && Arrange.parentHeight != 0) {
                    _initialize();
                    removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
                }
            }
        }

        private function _initialize():void {
			
            log("initialize()");
            
			nextFrame();

            if (_app) {
                log("initialize(), _app already instantiated returning");
                return;
            }

            prepareStage();
            try {
                //var mainClass:Class = getAppClass();
                //_app = new mainClass() as DisplayObject;
				_app = new Launcher();
                addChild(_app as DisplayObject);
                log("Launcher instantiated " + _app);
                removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
            } catch (e:Error) {
                log("error instantiating Launcher " + e + ": " + e.message);
                _app = null;
            }
        }

        private function getAppClass():Class {
            try {
                return Class(getDefinitionByName("org.flowplayer.view.Launcher"));
            } catch (e:Error) {
            }
            return null;
        }

        private function prepareStage():void {
            if (! stage) return;
            stage.align = StageAlign.TOP_LEFT;
            stage.scaleMode = StageScaleMode.NO_SCALE;
        }

        private function log(msg:Object):void {
            _log.debug(msg + "");
            trace(msg + "");
        }

        private function get rotationEnabled():Boolean {
            var config:Object = stage.loaderInfo.parameters["config"];
            if (! config) return true;
            if (config.replace(/\s/g, "").indexOf("buffering:null") > 0) return false;
            return true;
        }
		
		//--------------------------------------------------------------------------
		//
		//  Properties: IPreloaderDisplay
		//
		//--------------------------------------------------------------------------
		
		//----------------------------------
		//  backgroundAlpha
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage for the backgroundAlpha property.
		 */
		private var _backgroundAlpha:Number = 1;
		
		/**
		 *  Alpha level of the SWF file or image defined by 
		 *  the <code>backgroundImage</code> property, or the color defined by 
		 *  the <code>backgroundColor</code> property. 
		 *  Valid values range from 0 to 1.0.    
		 *  Override this property to set your own value in a custom class.
		 *
		 *  <p>You can specify either a <code>backgroundColor</code> 
		 *  or a <code>backgroundImage</code>, but not both.</p>
		 *
		 *  @default 1.0
		 *
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get backgroundAlpha():Number
		{
			if (!isNaN(_backgroundAlpha))
				return _backgroundAlpha;
			else
				return 1;
		}
		
		/**
		 *  @private
		 */
		public function set backgroundAlpha(value:Number):void
		{
			_backgroundAlpha = value;
		}
		
		//----------------------------------
		//  backgroundColor
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage for the backgroundColor property.
		 */
		private var _backgroundColor:uint;
		
		/**
		 *  Background color of a download progress bar.
		 *  Override this property to set your own value in a custom class.
		 *
		 *  <p>You can specify either a <code>backgroundColor</code> 
		 *  or a <code>backgroundImage</code>, but not both.</p>
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */ 
		public function get backgroundColor():uint
		{
			return _backgroundColor;
		}
		
		/**
		 *  @private
		 */
		public function set backgroundColor(value:uint):void
		{
			_backgroundColor = value;
		}
		
		//----------------------------------
		//  backgroundImage
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage for the backgroundImage property.
		 */
		private var _backgroundImage:Object;
		
		/**
		 *  The background image of the application,
		 *  which is passed in by the preloader.
		 *  Override this property to set your own value in a custom class.
		 *
		 *  <p>You can specify either a <code>backgroundColor</code> 
		 *  or a <code>backgroundImage</code>, but not both.</p>
		 *
		 *  <p>A value of null means "not set". 
		 *  If this style and the <code>backgroundColor</code> style are undefined, 
		 *  the component has a transparent background.</p>
		 *
		 *  <p>The preloader does not display embedded images. 
		 *  You can only use images loaded at runtime.</p>
		 *
		 *  @default null
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get backgroundImage():Object
		{
			return _backgroundImage;
		}
		
		/**
		 *  @private
		 */
		public function set backgroundImage(value:Object):void
		{
			_backgroundImage = value;
		}
		
		//----------------------------------
		//  backgroundSize
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage for the backgroundSize property.
		 */
		private var _backgroundSize:String = "";
		
		/**
		 *  Scales the image specified by <code>backgroundImage</code>
		 *  to different percentage sizes.
		 *  A value of <code>"100%"</code> stretches the image
		 *  to fit the entire component.
		 *  To specify a percentage value, you must include the percent sign (%).
		 *  A value of <code>"auto"</code>, maintains
		 *  the original size of the image.
		 *
		 *  @default "auto"
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get backgroundSize():String
		{
			return _backgroundSize;
		}
		
		/**
		 *  @private
		 */
		public function set backgroundSize(value:String):void
		{
			_backgroundSize = value;
		}
		
		//----------------------------------
		//  preloader
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage for the preloader property.
		 */
		private var _preloader:Sprite; 
		
		/**
		 *  The Preloader class passes in a reference to itself to the display class
		 *  so that it can listen for events from the preloader.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function set preloader(value:Sprite):void
		{
			_preloader = value;
		}
		
		//----------------------------------
		//  stageHeight
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage for the stageHeight property.
		 */
		private var _stageHeight:Number = 375;
		
		/**
		 *  The height of the stage,
		 *  which is passed in by the Preloader class.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get stageHeight():Number 
		{
			return _stageHeight;
		}
		
		/**
		 *  @private
		 */
		public function set stageHeight(value:Number):void 
		{
			_stageHeight = value;
		}
		
		//----------------------------------
		//  stageWidth
		//----------------------------------
		
		/**
		 *  @private
		 *  Storage for the stageHeight property.
		 */
		private var _stageWidth:Number = 500;
		
		/**
		 *  The width of the stage,
		 *  which is passed in by the Preloader class.
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function get stageWidth():Number 
		{
			return _stageWidth;
		}
		
		/**
		 *  @private
		 */
		public function set stageWidth(value:Number):void 
		{
			_stageWidth = value;
		}
		
		//--------------------------------------------------------------------------
		//
		//  Methods:IPreloaderDisplay
		//
		//--------------------------------------------------------------------------
		
		/**
		 *  Called by the Preloader after the download progress bar
		 *  has been added as a child of the Preloader. 
		 *  This should be the starting point for configuring your download progress bar. 
		 *  
		 *  @langversion 3.0
		 *  @playerversion Flash 10
		 *  @playerversion AIR 1.5
		 *  @productversion Flex 4
		 */
		public function initialize():void
		{
			//_startTime = getTimer();
		}
		

    }
}
