package com.pcup.project 
{
	import flash.events.Event;
	
	/**
	 * 提示事件。
	 * 
	 * @author ph
	 */
	public class TipEvent extends Event 
	{
		static public const SHOW:String = "show";
		
		/** 提示内容。*/
		private var _content:String;
		
		public function TipEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) 
		{ 
			super(type, bubbles, cancelable);
			
		} 
		
		public override function clone():Event 
		{ 
			var e:TipEvent = new TipEvent(type, bubbles, cancelable);
			e._content = _content;
			
			return e;
		} 
		
		public override function toString():String 
		{ 
			return formatToString("TipEvent", "type", "bubbles", "cancelable", "eventPhase", "content"); 
		}
		
		
		/** 提示内容。*/
		public function get content():String 
		{
			return _content;
		}
		public function set content(value:String):void 
		{
			_content = value;
		}
		
	}
	
}