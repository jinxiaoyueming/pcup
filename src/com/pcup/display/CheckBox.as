package com.pcup.display 
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	
	/** 选择动作完成时调度(可通过 select 来获取选择状态) */
	[Event(name = "select", type = "flash.events.Event")]
	
	
	/**
	 * 复选框。
	 * <p>可通过 CheckBox.select 来获取选择状态</p>
	 * 
	 * @author ph
	 */
	public class CheckBox extends Sprite 
	{
		/** 停止一次：选择动作完成时调度 Event.SELECT 事件。 */
		public var stopEventOnce:Boolean = false;
		
		private var material0:DisplayObject;	// 选中状态素材
		private var material1:DisplayObject;	// 未选中状态素材
		
		private var _select:Boolean;			// 选择状态(true表示选中，false表示未选中)
		
		
		/**
		 * 
		 * @param	material0	素材 - 选中
		 * @param	material1	素材 - 未选中
		 */
		public function CheckBox(material0:DisplayObject, material1:DisplayObject) 
		{
			this.material0 = material0;
			this.material1 = material1;
			
			addChild(material0);
			addChild(material1);
			addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			
			// 默认状态
			buttonMode = true;
			tabEnabled = false;
			mouseChildren = false;
			select = false;
		}
		
		// MOUSE_DOWN
		private function onDown(e:MouseEvent):void 
		{
			select = !select;
		}
		
		/** 选择状态(true表示选中，false表示未选中)。 */
		public function get select():Boolean 
		{
			return _select;
		}
		public function set select(value:Boolean):void 
		{
			_select = value;
			
			material1.visible = _select;
			material0.visible = !_select;
			
			// 调度事件
			if (stopEventOnce) 	stopEventOnce = false;
			else				dispatchEvent(new Event(Event.SELECT));
		}
		
	}

}