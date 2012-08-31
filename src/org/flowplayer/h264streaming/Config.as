package org.flowplayer.h264streaming
{
	public class Config extends Object
	{
		private var _queryString:String = "?start=${start}";
		
		public function Config()
		{
			return;
		}// end function
		
		public function get queryString() : String
		{
			return _queryString;
		}// end function
		
		public function set queryString(param1:String) : void
		{
			_queryString = param1;
			return;
		}// end function
		
	}
}