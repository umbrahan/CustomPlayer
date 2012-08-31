/*    
 *    Copyright (c) 2008-2011 Flowplayer Oy *
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

package org.flowplayer.util {
	/**
	 * @author api
	 */
	public class MaskConfiguration {
		private var _wp : Number = 0;
		private var _hp : Number = 0;
        private var _url : String = "";
		
		public function get widthPercent():Number {
			return _wp;
		}
		
		public function set widthPercent(val : Number):void {
			_wp = val;
		}
		
		public function get heightPercent():Number {
			return _hp;
		}
		
		public function set heightPercent(val : Number):void {
			_hp = val;
		}

        public function get url():String {
            return _url;
        }

        public function set url(val:String):void {
            _url = val;
        }
    }
}
