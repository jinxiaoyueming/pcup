package com.pcup.display 
{
	import com.greensock.TweenLite;
	import flash.ui.Mouse;
	import flash.ui.MouseCursor;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	
	
	/**
	 * 选择动作完成时调度。
	 * <p>可以通过 DragSelect.selectIndex 来获当前选择项在选择集中的索引。</p>
	 * @eventType	flash.events.Event.SELECT
	 */
	[Event(name = "select", type = "flash.events.Event")]
	
	
	/**
	 * DragSelect 类的实例是一个可拖动的选择集。
	 * <p>传入一个数组作为此选择集的数据来源，拖动选择后会调度 flash.events.Event.SELECT 事件，以便获取当前选择项。</p>
	 * 
	 * @example	
示例：下面的示例展示了如何使用 DragSelect 类：
<listing version="3.0">
[Embed(source = "cover.png")]
var ECover:Class;
var arr:Array = [10, 20, 30, 40, 50, 60];
var d:DragSelect = new DragSelect(arr, new Rectangle(0, 0, 100, 50), false, new TextFormat(null, 30), new ECover, true);
addChild(d);
d.selectIndex = 1;	// 设置第二个元素为当前选择项
d.addEventListener(Event.SELECT, function (e:Event):void
{
	trace(arr[e.target.selectIndex]);	// 当前选择项
});
</listing>
	 * 
	 * @author PH
	 */
	public class DragSelect extends Sprite 
	{
		/** 停止一次：选择动作完成时调度 Event.SELECT 事件。 */
		public var stopEventOnce:Boolean = false;
		
		private var _selectIndex:uint;	// 当前选择项在选择集中的序号
		private var argArr:Array;		// 选择集
		
		private var area:Rectangle;		// 一个选择项的尺寸
		private var dragCtn:Sprite;		// 所有选择项的容器
		private var isX:Boolean;		// 拖动方向，true为水平方向，false为垂直方向。
		private var downTip:Bitmap;		// 按下时才显示的拖提示物（显示时是被添加到 stage 中，以显示在最上层）
		
		private var Pstg:Point;			// MOUSE_DOWN事件时，鼠标的舞台坐标。
		private var Pctn:Point;			// MOUSE_DOWN事件时，鼠标的本对象坐标。
		
		
		/**
		 * 创建一个新的 DragSelect 实例。
		 * @param	argArr			选择集（数组元素可为任意，但在生成文本显示时会被强制转换为字符串）。
		 * @param	area			一个选择项的尺寸（不用设置x、y属性）。
		 * @param	isX				拖动的方向（ture表示水平方向，false表示垂直方向）。
		 * @param	textFormat		显示文本的格式。
		 * @param	cover			覆盖物，好让本对象看来有想拖动它的欲望。
		 * @param	downTip			按下时才显示的拖提示物，提示用户可拖动。
		 * @param	showBackground	是否显示背景底（便于调试显示区域）。
		 */
		public function DragSelect(argArr:Array, area:Rectangle, isX:Boolean, textFormat:TextFormat = null, cover:Bitmap = null, downTip:Bitmap = null, showBackground:Boolean = false) 
		{
			this.area = area;
			this.argArr = argArr;
			this.isX = isX;
			this.downTip = downTip;
			
			// 拖动容器的容器（嵌套，好让拖动容器的x、y属性为0，这样后面拖动时才好计算）
			var ctn:Sprite = new Sprite();
			ctn.mouseEnabled = false;
			addChild(ctn);
			// 拖动容器（所有选择项的容器）
			dragCtn = new Sprite();
			dragCtn.addEventListener(MouseEvent.MOUSE_DOWN, onDown);
			ctn.addChild(dragCtn);
			
			// 覆盖物
			if (cover) 
			{
				cover.width = area.width;
				cover.height = area.height;
				addChild(cover);
			}
			
			// 遮罩
			var m:Shape = new Shape();
			m.graphics.beginFill(0);
			m.graphics.drawRect(0, 0, area.width, area.height);
			m.graphics.endFill();
			addChild(m);
			ctn.mask = m;
			
			// 生成所有选择项
			for (var i:* in argArr) 
			{
				// 创建一个选择项
				var item:Bitmap = buildOneItem(String(argArr[i]), textFormat, showBackground);
				dragCtn.addChild(item);
				
				// 排位置
				if (isX) item.x = i * area.width;
				else 	 item.y = i * area.height;
			}
			
			// 光标样式
			addEventListener(MouseEvent.ROLL_OVER, function ():void { Mouse.cursor = MouseCursor.HAND; } );
			addEventListener(MouseEvent.ROLL_OUT,  function ():void { Mouse.cursor = MouseCursor.AUTO; } );
		}
		
		// MOUSE_DOWN
		private function onDown(e:MouseEvent):void 
		{
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, onUp);
			stage.addEventListener(MouseEvent.ROLL_OUT, onUp);
			
			// 存储坐标
			Pstg = new Point(stage.mouseX, stage.mouseY);
			Pctn = new Point(dragCtn.x, dragCtn.y);
			
			// 清除旧缓动
			TweenLite.killTweensOf(dragCtn);
			
			// 按下时才显示的拖提示物
			if (downTip) 
			{
				var p:Point = localToGlobal(new Point((area.width - downTip.width) / 2, (area.height - downTip.height) / 2));
				downTip.x = p.x;
				downTip.y = p.y;
				stage.addChild(downTip);
			}
		}
		// MOUSE_MOVE
		private function onMove(e:MouseEvent):void 
		{
			// 拖动
			if (isX) dragCtn.x = Pctn.x + (stage.mouseX - Pstg.x);
			else	 dragCtn.y = Pctn.y + (stage.mouseY - Pstg.y);
		}
		// MOUSE_UP
		private function onUp(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onUp);
			stage.removeEventListener(MouseEvent.ROLL_OUT, onUp);
			
			// 按下时才显示的拖提示物
			if (downTip) 
			{
				stage.removeChild(downTip);
			}
			
			// 输入框的中线位置和哪个值最近就对齐到那个值
			var curP:int = isX ? dragCtn.x : dragCtn.y;												// 当前的 dragCtn.x（或y）
			var minP:int = isX ? -dragCtn.width + area.width : -dragCtn.height + area.height;		// 拖动时 dragCtn.x（或y）允许的的最小值
			var maxP:int = 0;																		// 拖动时 dragCtn.x（或y）允许的的最大值
			
			var index:uint;
			// 判断离中心最近的一个值的序号
			if (curP < minP)				// 超出最小值按最小值算
			{
				index = argArr.length - 1;
			}
			else if (curP > maxP)			// 超出最大值按最大值算
			{
				index = 0;
			}
			else							// 在正常范围内就按正常方法计算
			{
				index = Math.round(-curP / (isX ? area.width : area.height));
			}
			
			select(index);
		}
		
		/** 选择一个项 */
		private function select(index:uint):void
		{
			_selectIndex = index;
			
			// 清除旧缓动
			TweenLite.killTweensOf(dragCtn);
			
			// 设置容器位置
			if (isX) TweenLite.to(dragCtn, 0.5, { x: -_selectIndex * area.width  } );
			else 	 TweenLite.to(dragCtn, 0.5, { y: -_selectIndex * area.height } );
			
			// 调度事件
			if (stopEventOnce) 	stopEventOnce = false;
			else				dispatchEvent(new Event(Event.SELECT));
		}
		
		
		/**
		 * 创建创建一个选择项。
		 * @param	str				文本内容。
		 * @param	textFormat		文本格式。
		 * @param	showBackground	是否显示背景底。
		 * @return	创建一个选择项。
		 */
		private function buildOneItem(str:String, textFormat:TextFormat, showBackground:Boolean):Bitmap 
		{
			// 容器
			var s:Sprite = new Sprite();
			s.mouseEnabled = false;
			s.mouseChildren = false;
			
			// 画一个填充对象（和本对象的遮罩一样大）。
			var bg:Shape = new Shape();
			bg.graphics.beginFill(0xff0000);
			bg.graphics.drawRect(0, 0, area.width, area.height);
			bg.graphics.endFill();
			bg.alpha = showBackground ? 0.3 : 0;
			s.addChild(bg);
			
			// 文本内容（选择集中元素转换得来的字符串）
			var t:TextField = new TextField();
			if (textFormat) t.defaultTextFormat = textFormat;
			t.selectable = false;
			t.border = showBackground;
			t.autoSize = TextFieldAutoSize.LEFT;
			t.text = str;
			t.x = (bg.width - t.width) / 2;
			t.y = (bg.height - t.height) / 2;
			s.addChild(t);
			
			// 画为一个 Bitmap 对象。
			var bmd:BitmapData = new BitmapData(bg.width, bg.height, true, 0);
			bmd.draw(s);
			
			return new Bitmap(bmd);
		}
		
		
		/**
		 * 当前选择项在选择集中的索引。
		 * 
		 * <p>写本属性即是设置当前选择项。</p>
		 */
		public function get selectIndex():uint 
		{
			return _selectIndex;
		}
		public function set selectIndex(value:uint):void 
		{
			// 过滤无效值
				 if (value < 0)					value = 0;
			else if (value > argArr.length - 1) value = argArr.length - 1;
			
			select(value);
		}
		
		/** 选择集长度。 */
		public function get length():uint {
			return argArr.length;
		}
		
	}

}