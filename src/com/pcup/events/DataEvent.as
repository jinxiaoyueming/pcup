package com.pcup.events 
{
	import flash.events.Event;
	
	/**
	 * 一个通用的、用来传递数据的、事件。
	 * <p>可用 data 属性来传递任意 Object 类型数据。</p>
	 * 
	 * @author ph
	 */
	public class DataEvent extends Event 
	{
		static public const SHOW:String = "show";
		
		/** 传递的数据 */
		private var _data:Object;
		
		public function DataEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			var e:DataEvent = new DataEvent(type, bubbles, cancelable);
			e._data = _data;
			
			return e;
		} 
		
		public override function toString():String 
		{ 
			return formatToString("DataEvent", "type", "bubbles", "cancelable", "eventPhase", "data"); 
		}
		
		
		/** 传递的数据 */
		public function get data():Object 
		{
			return _data;
		}
		public function set data(value:Object):void 
		{
			_data = value;
		}
		
	}
	
}