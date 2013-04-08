package com.pcup.display 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.geom.ColorTransform;
	
	
	/**
	 * 颜色改变时调度此事件。
	 * <p>可以通过 ColorPicker.color 来获取当前颜色的十进制数值。</p>
	 * @eventType	com.pcup.display.ColorPicker.UPDATE
	 */
	[Event(name = "update", type = "com.pcup.display.ColorPicker")]
	
	
	/**
	 * ColorPicker 类的实例是一个颜色选择器。
	 * 
	 * <p>TODO：设置当前颜色值还只能改变色块的颜色，三个颜色轴的值没有同步。</p>
	 * 
	 * @example	
示例：下面的示例展示了如何使用 ColorPicker 类：
<listing version="3.0">
var c:ColorPicker = new ColorPicker();
addChild(c);
c.addEventListener(ColorPicker.UPDATE, function(e:Event):void
{
	trace(e.target.color);
});
</listing>
	 * 
	 * @author PH
	 */
	public class ColorPicker extends Sprite 
	{
		/** 定义 update 事件对象的 type 属性值。 */
		public static const UPDATE:String = "update";
		
		private var _color:uint = 0;										// 当前颜色值
		private var block:Sprite;											// 当前颜色的色块
		
		private var rBar:ValueBar;											// 红轴
		private var gBar:ValueBar;											// 绿轴
		private var bBar:ValueBar;											// 蓝轴
		
		
		/**
		 * 创建一个新的 ColorPicker 实例。
		 */
		public function ColorPicker() 
		{
			// 当前颜色的色块
			block = new Sprite();
			block.graphics.beginFill(0);
			block.graphics.drawRect(0, 0, 20, 20);
			block.graphics.endFill();
			addChild(block);
			
			// RGB轴
			rBar = new ValueBar(255, 0, 100, 10, 0xff0000, 0x808080);
			gBar = new ValueBar(255, 0, 100, 10, 0x00ff00, 0x808080);
			bBar = new ValueBar(255, 0, 100, 10, 0x0000ff, 0x808080);
			rBar.y = block.y + block.height + 5;
			gBar.y = rBar.y + rBar.height + 5;
			bBar.y = gBar.y + gBar.height + 5;
			addChild(rBar);
			addChild(gBar);
			addChild(bBar);
			rBar.addEventListener(ValueBar.UPDATE, update);
			gBar.addEventListener(ValueBar.UPDATE, update);
			bBar.addEventListener(ValueBar.UPDATE, update);
		}
		
		// 更新色块颜色
		private function update(e:Event):void 
		{
			block.transform.colorTransform = new ColorTransform(1, 1, 1, 1, rBar.value, gBar.value, bBar.value);
			
			_color = block.transform.colorTransform.color;
			
			// 调度更新事件
			dispatchEvent(new Event(ColorPicker.UPDATE));
		}
		
		
		
		
		/**
		 * 当前颜色值（10进制形式的整数，缺省值：0）。
		 * 
		 * <p>写本属性即是设置当前参数。</p>
		 */
		public function get color():uint 
		{
			return _color;
		}
		public function set color(value:uint):void 
		{
				 if (value < 0)			_color = 0;
			else if (value > 0xffffff)	_color = 0xffffff;
			else 						_color = value;
			
			// 更新色块的颜色
			var ct:ColorTransform = new ColorTransform();
			ct.color = _color;
			block.transform.colorTransform = ct;
		}
		
		
	}

}