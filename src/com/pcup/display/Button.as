package com.pcup.display 
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	
	/**
	 * 可拖动对象的单击操作发生时调度。
	 * <p>此事件与系统自带的单击事件区别在于如果DOWN与UP的坐标偏差超过指定值，便不会识别为单击。</p>
	 * @eventType	com.pcup.display.Button.DRAG_CLICK
	 */
	[Event(name = "dragClick", type = "com.pcup.display.Button")]
	/**
	 * 可拖动对象在拖动距离超过指定值时调度。
	 * @eventType	com.pcup.display.Button.DRAG_OUT
	 */
	[Event(name = "dragOut", type = "com.pcup.display.Button")]
	
	
	/**
	 * Button 类的实例是一个按钮。由传入的两个素材来实现按钮的普通和激活两个状态。
	 * 
	 * @author ph
	 */
	public class Button extends Sprite 
	{
		/** 定义 dragClick 事件的事件类型 */
		static public const DRAG_CLICK:String = "dragClick";
		/** 定义 dragOut 事件的事件类型 */
		static public const DRAG_OUT:String = "dragOut";
		
		private var auto:Boolean;						// 是否自动切换按钮状态。
		private var drag:Boolean;						// 是否会被拖动。如果会被拖动则在符合条件的情况下会抛出 Button.DRAG_OUT、Button.DRAG_CLICK 事件。
		private var _active:Boolean;					// 按钮状态（true表示激活状态，false表示普通状态）。
		private var _activePlus:Boolean;				// 按钮状态（true表示激活状态，false表示普通状态），与 active 的区别见接口注释。
		
		private var _dragClickDeviation:uint = 20;		// 拖动时识别为单击的最大偏差值（单位：象素；缺省值：20）。
		private var pDown:Point;						// 手动模式下，鼠标按下时的坐标，用以判断拖动偏差。
		
		private var material0:DisplayObject;			// 普通状态素材
		private var material1:DisplayObject;			// 激活状态素材
		
		
		/**
		 * 创建一个新的 Button 实例。
		 * @param	material0	素材-普通。
		 * @param	material1	素材-激活。
		 * @param	auto		是否自动切换按钮状态。
		 * @param	drag		是否会被拖动。如果会被拖动则在符合条件的情况下会抛出 Button.DRAG_OUT、Button.DRAG_CLICK 事件。
		 */
		public function Button(material0:DisplayObject, material1:DisplayObject, auto:Boolean = true, drag:Boolean = false) 
		{
			this.material0 = material0;
			this.material1 = material1;
			this.auto = auto;
			this.drag = drag;
			
			addChild(material0);
			addChild(material1);
			addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			
			// 默认状态
			buttonMode = true;
			tabEnabled = false;
			mouseChildren = false;
			active = false;
		}
		
		// MOUSE_DOWN
		private function onDown(e:MouseEvent):void 
		{
			stage.addEventListener(MouseEvent.MOUSE_UP, onUp);
			
			// 自动切换
			if (auto) 
			{
				addEventListener(MouseEvent.ROLL_OUT, onUp);
				
				active = true;
			}
			
			// 可拖动
			if (drag)
			{
				pDown = new Point(stage.mouseX, stage.mouseY);
				
				stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
			}
		}
		// MOUSE_MOVE
		private function onMove(e:MouseEvent):void 
		{
			// 拖动距离大于指定值时，调度 Button.DRAG_OUT 事件。
			if (Math.abs(stage.mouseX - pDown.x) > _dragClickDeviation || Math.abs(stage.mouseY - pDown.y) > _dragClickDeviation)
			{
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
				
				dispatchEvent(new Event(Button.DRAG_OUT));
			}
		}
		// MOUSE_UP || ROLL_OUT
		private function onUp(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_UP, onUp);
			removeEventListener(MouseEvent.ROLL_OUT, onUp);
			
			// 自动切换
			if (auto) 
			{
				removeEventListener(MouseEvent.ROLL_OUT, onUp);
				
				active = false;
			}
			
			// 可拖动
			if (drag)
			{
				stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
				
				// 拖动距离小于指定值时，判断为单击。
				if (Math.abs(stage.mouseX - pDown.x) < _dragClickDeviation && Math.abs(stage.mouseY - pDown.y) < _dragClickDeviation) 
				{
					dispatchEvent(new Event(Button.DRAG_CLICK));	
				}
			}
		}
		
		
		
		
		
		/**
		 * 按钮状态（true表示激活状态，false表示普通状态）。
		 * <p>写本属性即是设置按钮状态。</p>
		 */
		public function get active():Boolean 
		{
			return _active;
		}
		public function set active(value:Boolean):void 
		{
			_active = value;
			
			material0.visible = !_active;
			material1.visible = _active;
		}
		
		/**
		 * 按钮状态（true表示激活状态，false表示普通状态）。
		 * <p>本属性没有任何内部控制，就是相当于是多定义了一个属性来存储一个自定义值。</p>
		 * <p>此参数和 active 参数的区别在于 active 只表示按钮的显示状态，而此参数可用来判断是否激活了按钮。</p>
		 * <p>例如：在按钮可拖动的情况下，MOUSE_DOWN 时 active 可置为 true，但 activePlus 要等到抛出了 Button.DRAG_CLICK 事件才置为 true。且当接收到 Button.DRAG_OUT 事件时 active 置为 false。</p>
		 * <p>本属性原则上可存储任意值，但建议只用做以上示例的用途。</p>
		 */
		public function get activePlus():Boolean 
		{
			return _activePlus;
		}
		public function set activePlus(value:Boolean):void 
		{
			_activePlus = value;
		}
		
		/**
		 * 拖动时识别为单击的最大偏差值（单位：象素；缺省值：20）。
		 * <p>注意：对象不可拖动时设置此属性是没有意义的。</p>
		 */
		public function get dragClickDeviation():uint 
		{
			return _dragClickDeviation;
		}
		public function set dragClickDeviation(value:uint):void 
		{
			_dragClickDeviation = value;
		}
		
	}

}