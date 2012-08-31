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

package org.flowplayer.config {

	/**
	 * @author api
	 */
	public class VersionInfo {
		private static const config_version1 : String = "1";
		private static const config_version2 : String = "2";
		private static const config_version3 : String = "3";
		private static const config_commercialVersion : Boolean = true;
		private static const config_versionStatus : Boolean = false;
		
		private static const VERSION_NUMBER:String = config_version1 + "." + config_version2 + "." + config_version3;
		
		private static const VERSION_INFO:String = "Crazy Player " + VERSION_NUMBER;

		public static function get version():Array {
			return [new int(config_version1), new int(config_version2), new int(config_version3), 
				'', config_versionStatus];
		}
		
		public static function versionInfo():String {
			return VERSION_INFO;
		}
		
		public static function get commercial():Boolean {
			return config_commercialVersion;
		}
		
		public static function get controlsVersion():String {
			return VERSION_NUMBER;
		}
		
		public static function get audioVersion():String {
			return VERSION_NUMBER;
		}
	}
	
}
