package com.pcup.display 
{
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	
	/**
	 * 数值改变时调度此事件。
	 * <p>可通过 ValueBar.value 来获取当前值。</p>
	 * @eventType	com.pcup.display.ValueBar.UPDATE
	 */
	[Event(name = "update", type = "com.pcup.display.ValueBar")]
	
	
	/**
	 * ValueBar 类的实例是一个取值条。如同多媒体播放器中的声音调整条。
	 * 
	 * @example	
示例：下面的示例展示了如何使用 ValueBar 类：
<listing version="3.0">
var v:ValueBar = new ValueBar(100);
addChild(v);
v.addEventListener(ValueBar.UPDATE, function(e:Event):void
{
	trace(e.target.value);
});
</listing>
	 * 
	 * @author PH
	 */
	public class ValueBar extends Sprite 
	{
		/** 定义 update 事件对象的 type 属性值。 */
		public static const UPDATE:String = "update";
		
		private var min:int;		// 可取到的最小值
		private var max:int;		// 可取到的最大值
		
		private var _value:int;		// 用相对位置转换来的值
		private var vs:Sprite;		// 前景条，用它的长度来获取对应的数值
		
		
		/**
		 * 创建一个新的 ValueBar 实例。
		 * @param	max			可取到的最大值。
		 * @param	min			可取到的最小值。
		 * @param	w			创建的取值条的宽度。
		 * @param	h			创建的取值条的高度。
		 * @param	colorFront	前景色。
		 * @param	colorBg		背景色。
		 */
		public function ValueBar(max:int, min:int = 0, w:uint = 100, h:uint = 5, colorFront:uint = 0xffffff, colorBg:uint = 0) 
		{
			this.min = min;
			this.max = max;
			
			// 控制显示对象的最小尺寸参数
			w = w < 2 ? 2 : w;
			h = h < 2 ? 2 : h;
			
			// 背景条
			var bg:Sprite = crtRect(w, h, colorBg);
			addChild(bg)
			
			// 前景条
			vs = crtRect(w, h, colorFront);
			vs.width = 0;
			addChild(vs);
			
			// 开始监听鼠标事件
			addEventListener(MouseEvent.MOUSE_DOWN, onDown);
		}
		
		
		// MOUSE_DOWN
		private function onDown(e:MouseEvent):void 
		{
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, onUp);
			stage.addEventListener(MouseEvent.ROLL_OUT, onUp);
			
			updateBar();
		}
		// MOUSE_MOVE
		private function onMove(e:MouseEvent):void 
		{
			updateBar();
		}
		// MOUSE_UP
		private function onUp(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onUp);
			stage.removeEventListener(MouseEvent.ROLL_OUT, onUp);
			
			updateBar();
		}
		
		
		// 更新前景条的长度
		private function updateBar():void 
		{
				 if (mouseX < 0)		vs.width = 0;
			else if (mouseX > width) 	vs.width = width;
			else						vs.width = mouseX;
			
			_value = (max - min) * (vs.width / width) - min;
			
			// 调度更新事件
			dispatchEvent(new Event(ValueBar.UPDATE));
		}
		
		// 创建一个方块
		private function crtRect(w:uint, h:uint, c:uint):Sprite 
		{
			var s:Sprite = new Sprite();
			s.graphics.beginFill(c);
			s.graphics.drawRect(0, 0, w, h);
			s.graphics.endFill();
			
			return s;
		}
		
		
		
		/**
		 * 当前值。
		 * 
		 * <p>写本属性即是设置此参数。</p>
		 */ 
		public function get value():int 
		{
			return _value;
		}
		public function set value(num:int):void 
		{
				 if (num < min) _value = min;
			else if (num > max) _value = max;
			else 				_value = num;
			
			vs.width = width * ((_value - min) / (max - min));
		}
		
	}

}