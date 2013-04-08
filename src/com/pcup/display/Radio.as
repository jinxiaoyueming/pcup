package com.pcup.display 
{
	import flash.display.Bitmap;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	/** 选择动作完成时调度(可以通过 selectIndex 来获当前选择项的索引) */
	[Event(name = "select", type = "flash.events.Event")]
	
	/**
	 * 单选按钮组
	 * <p>可通过 Radio.selectIndex 来获取或设置选择项</p>
	 * 
	 * @author ph
	 */
	public class Radio extends Sprite 
	{
		/** 停止一次：选择动作完成时调度 Event.SELECT 事件。 */
		public var stopEventOnce:Boolean = false;
		
		private var _checkBoxList:Vector.<CheckBox>;
		private var _selectIndex:uint;
		
		
		/**
		 * 
		 * @param	checkBoxList	所有按钮。
		 * @param	positionList	所有按钮的位置。
		 */
		public function Radio(checkBoxList:Vector.<CheckBox>, positionList:Vector.<Point>) 
		{
			_checkBoxList = checkBoxList;
			
			// 创建按钮
			for (var i:* in _checkBoxList) 
			{
				_checkBoxList[i].x = positionList[i].x;
				_checkBoxList[i].y = positionList[i].y;
				addChild(_checkBoxList[i]);
				_checkBoxList[i].addEventListener(Event.SELECT, selectHandler);
			}
		}
		private function selectHandler(e:Event):void 
		{
			var index:uint = _checkBoxList.indexOf(e.currentTarget as CheckBox);
			select(index);
		}
		
		/** 选择一个项 */
		private function select(index:uint):void
		{
			_selectIndex = index;
			
			for (var i:* in _checkBoxList) 
			{
				_checkBoxList[i].stopEventOnce = true;
				_checkBoxList[i].select = (i == index);
			}
			
			// 调度事件
			if (stopEventOnce) 	stopEventOnce = false;
			else				dispatchEvent(new Event(Event.SELECT));
		}
		
		/** 当前选择项的索引 */
		public function get selectIndex():uint 
		{
			return _selectIndex;
		}
		public function set selectIndex(value:uint):void 
		{
			select(value);
		}
		
	}

}