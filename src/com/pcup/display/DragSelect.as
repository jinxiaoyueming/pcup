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
	 * 选择动作完成时调度.
	 * <p>可以通过 DragSelect.selectIndex 来获当前选择项在选择集中的索引.</p>
	 * @eventType	flash.events.Event.SELECT
	 */
	[Event(name = "select", type = "flash.events.Event")]
	
	
	/**
	 * DragSelect 类的实例是一个可拖动的选择集.
	 * <p>传入一个数组作为此选择集的数据来源,拖动选择后会调度 flash.events.Event.SELECT 事件,以便获取当前选择项.</p>
	 * 
	 * @example	
示例：下面的示例展示了如何使用 DragSelect 类：
<listing version="3.0">
//DragSelect.showBackground = true;
var arr:Array = [10, 20, 30, 40, 50, 60];
var d:DragSelect = new DragSelect(false, arr, new TextFormat(null, 24), baseMap, cover, 33);
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
		/** 是否显示背景底（便于调试显示区域） */
		static public var showBackground:Boolean;
		
		/** 停止一次：选择动作完成时调度 Event.SELECT 事件. */
		public var stopEventOnce:Boolean = false;
		
		private var isX:Boolean;		// 拖动方向,true为水平方向,false为垂直方向
		private var baseMap:Bitmap;		// 底图(选择项介于底图和覆盖物之前的中间层)
		private var itemLong:int;		// 一个选择项的长度
		
		private var _selectIndex:uint;	// 当前选择项在选择集中的序号
		private var argArr:Array;		// 选择集
		private var dragCtn:Sprite;		// 所有选择项的容器
		
		private var Pstg:Point;			// MOUSE_DOWN事件时,鼠标的舞台坐标
		private var Pctn:Point;			// MOUSE_DOWN事件时,鼠标的本对象坐标
		
		
		/**
		 * 创建一个新的 DragSelect 实例.
		 * @param	isX				拖动的方向（ture表示水平方向,false表示垂直方向）.
		 * @param	argArr			选择集（数组元素可为任意,但在生成文本显示时会被强制转换为字符串）.
		 * @param	textFormat		显示文本的格式.
		 * @param	baseMap			底图(选择项介于底图和覆盖物之前的中间层).
		 * @param	cover			覆盖物(选择项介于底图和覆盖物之前的中间层).
		 * @param	itemLong		一个选择项的长度.
		 */
		public function DragSelect(isX:Boolean, argArr:Array, textFormat:TextFormat, baseMap:Bitmap, cover:Bitmap, itemLong:int) 
		{
			this.isX = isX;
			this.argArr = argArr;
			this.baseMap = baseMap;
			this.itemLong = itemLong;
			
			// 底图
			addChild(baseMap);
			
			// 拖动容器的容器（嵌套,好让拖动容器的x/y属性为0,这样后面拖动时才好计算）
			var ctn:Sprite = new Sprite();
			ctn.mouseEnabled = false;
			if (isX) ctn.x = (baseMap.width  - itemLong) / 2;
			else	 ctn.y = (baseMap.height - itemLong) / 2;
			addChild(ctn);
			// 拖动容器（所有选择项的容器）
			dragCtn = new Sprite();
			ctn.addChild(dragCtn);
			
			// 覆盖物
			if (cover) 
			{
				cover.width = baseMap.width;
				cover.height = baseMap.height;
				addChild(cover);
			}
			
			// 遮罩
			if (!showBackground)
			{
				var m:Shape = new Shape();
				m.graphics.beginFill(0);
				m.graphics.drawRect(0, 0, baseMap.width, baseMap.height);
				m.graphics.endFill();
				addChild(m);
				mask = m;
			}
			
			// 生成所有选择项
			for (var i:* in argArr) 
			{
				// 创建一个选择项
				var item:Bitmap = buildOneItem(String(argArr[i]), textFormat);
				dragCtn.addChild(item);
				
				// 排位置
				if (isX) item.x = i * itemLong;
				else 	 item.y = i * itemLong;
			}
			
			// 光标样式
			addEventListener(MouseEvent.ROLL_OVER, function ():void { Mouse.cursor = MouseCursor.HAND; } );
			addEventListener(MouseEvent.ROLL_OUT,  function ():void { Mouse.cursor = MouseCursor.AUTO; } );
			
			// 拖动选择
			addEventListener(MouseEvent.MOUSE_DOWN, onDown);
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
			
			// 输入框的中线位置和哪个值最近就对齐到那个值
			var curP:int = isX ? dragCtn.x : dragCtn.y;												// 当前的 dragCtn.x（或y）
			var minP:int = isX ? (-dragCtn.width + itemLong) : (-dragCtn.height + itemLong);		// 拖动时 dragCtn.x（或y）允许的的最小值
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
				index = Math.round(-curP / itemLong);
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
			if (isX) TweenLite.to(dragCtn, 0.5, { x: -_selectIndex * itemLong } );
			else 	 TweenLite.to(dragCtn, 0.5, { y: -_selectIndex * itemLong } );
			
			// 调度事件
			if (stopEventOnce) 	stopEventOnce = false;
			else				dispatchEvent(new Event(Event.SELECT));
		}
		
		
		/**
		 * 创建创建一个选择项.
		 * @param	str				文本内容.
		 * @param	textFormat		文本格式.
		 * @return	创建一个选择项.
		 */
		private function buildOneItem(str:String, textFormat:TextFormat):Bitmap 
		{
			// 容器
			var s:Sprite = new Sprite();
			
			// 画一个填充对象（和本对象的遮罩一样大）.
			var bg:Shape = new Shape();
			if (showBackground) bg.graphics.beginFill(Math.random() * 0xffffff, 0.3);
			else				bg.graphics.beginFill(0, 0);
			if (isX) bg.graphics.drawRect(0, 0, itemLong, baseMap.height);
			else	 bg.graphics.drawRect(0, 0, baseMap.width, itemLong);
			bg.graphics.endFill();
			s.addChild(bg);
			
			// 文本内容（选择集中元素转换得来的字符串）
			var t:TextField = new TextField();
			t.autoSize = TextFieldAutoSize.LEFT;
			if (textFormat) t.defaultTextFormat = textFormat;
			t.text = str;
			t.x = (bg.width  - t.width ) / 2 - (isX ? 1 : 0);
			t.y = (bg.height - t.height) / 2 - (isX ? 0 : 1);	// (isX ? 0 : 1) 是为了修正文本位置偏差
			s.addChild(t);
			
			// 画为一个 Bitmap 对象.
			var bmd:BitmapData = new BitmapData(bg.width, bg.height, true, 0);
			bmd.draw(s);
			
			return new Bitmap(bmd);
		}
		
		
		/**
		 * 当前选择项在选择集中的索引.
		 * 
		 * <p>写本属性即是设置当前选择项.</p>
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
		
		/** 选择集长度. */
		public function get length():uint {
			return argArr.length;
		}
		
	}

}