package com.pcup.display 
{
	import com.greensock.TweenLite;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	/**
	 * DragSlip 类的实例是一个可拖动的 Sprite 对象。
	 * 
	 * @example	
下面是一个简单的使用示例。首先会创建一个 DragSlip 实例，然后添加拖动子元素，并设置滚动条。
<listing version="3.0">
// 创建实例
var d:DragSlip = new DragSlip(true, 400);
// 设置滚动条
d.scrollBar = new ScrollBar(true, 400);
// 添加拖动子元素
d.addChild(new EA());
addChild(d);
</listing>
	 * 
	 * @see	com.pcup.display.ScrollBar
	 * 
	 * @author PH
	 */
	public class DragSlip extends Sprite 
	{
		private var pStg:Point;							// MOUSE_DOWN事件时，鼠标的舞台坐标。
		private var pCtn:Point;							// MOUSE_DOWN事件时，鼠标的本对象坐标。
		
		private var cover:Shape;						// 防止在白处无法拖动的显示对象
		private var subMask:Shape;						// subContainer 的遮罩。
		private var subContainer:Sprite;				// 子元素的容器。
		
		private var length:uint;						// 可视区域在拖动方向上的长度。
		private var isX:Boolean;						// 拖动方向，true为水平方向，false为垂直方向。
		
		private var _scrollBar:ScrollBar;				// 当此参数有值时，显示滚动条。
		private var _clicked:Boolean;					// 本对象的最近一次拖动操作是否被判断为单击。本参数可以配合子对象自身的 MOUSE_CLICK 事件来判断拖动时子对象是是否被单击了。
		private var _clickDeviation:uint = 10;			// 单击最大偏差值。即拖动操作被判断为单击操作时，DOWN和UP的位置的最大偏差值（单位：象素，缺省值：10）。
		private var _wheelEnabled:Boolean = false;		// 是否允许用鼠标滚轮滚动页面（缺省值：false）。
		private var _wheelDelta:uint = 20;				// 鼠标滚轮事件delta参数加持。加持量为[滚动距离 = MouseEvent.delta * wheelDelta]（单位：象素，缺省值：20）。
		
		
		/**
		 * 创建一个新的 DragSlip 实例。
		 * @param	isX			拖动的方向(ture表示水平方向，false表示垂直方向)。
		 * @param	length		可视区域在拖动方向上的长度(也就是滚动条的长度)。
		 */
		public function DragSlip(isX:Boolean, length:uint) 
		{
			this.isX = isX;
			this.length = length;
			
			// 防止在白处无法拖动的显示对象（和可视区域同样大小）
			var s:Shape = new Shape();
			s.graphics.beginFill(0, 0);
			if (isX) s.graphics.drawRect(0, 0, length, 1);
			else	 s.graphics.drawRect(0, 0, 1, length);
			s.graphics.endFill();
			super.addChild(s);
			cover = s;
			
			// subContainer 的遮罩（和可视区域同样大小）
			s = new Shape();
			s.graphics.beginFill(0);
			if (isX) s.graphics.drawRect(0, 0, length, 1);
			else	 s.graphics.drawRect(0, 0, 1, length);
			s.graphics.endFill();
			super.addChild(s);
			subMask = s;
			
			// 拖动容器
			subContainer = new Sprite();
			subContainer.mask = subMask;
			super.addChild(subContainer);
			
			// 监听鼠标事件来实现拖动
			addEventListener(MouseEvent.MOUSE_DOWN, onDown);
		}
		
		// MOUSE_WHEEL
		private function onWheel(e:MouseEvent):void 
		{
			if (isX && subContainer.width > length) 
			{
				subContainer.x += e.delta * wheelDelta;
				
				// 超出边界就对齐到边界
					 if (subContainer.x > 0)								subContainer.x = 0;
				else if (subContainer.x < -subContainer.width + length)		subContainer.x = -subContainer.width + length;
			}
			else if (!isX && subContainer.height > length)
			{
				subContainer.y += e.delta * wheelDelta;
				
				// 超出边界就对齐到边界
					 if (subContainer.y > 0) 								subContainer.y = 0;
				else if (subContainer.y < -subContainer.height + length)	subContainer.y = -subContainer.height + length;
			}
			
			// 处理滚动条
			if (_scrollBar)	
			{
				// 清除旧缓动
				TweenLite.killTweensOf(_scrollBar);
				
				// 显示滚动条（拖动对象大于显示区域时）
				if ((isX && subContainer.width > length) || (!isX && subContainer.height > length)) 
				{
					_scrollBar.alpha = 1;
				}
				// 更新滚动条
				updateScrollBar();
				// 隐藏滚动条
				hideScrollBar();		
			}
		}
		// MOUSE_DOWN
		private function onDown(e:MouseEvent):void 
		{
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove); 
			stage.addEventListener(MouseEvent.MOUSE_UP, onUp);
			stage.addEventListener(MouseEvent.ROLL_OUT, onUp);
			
			// 存储位置信息
			pStg = new Point(stage.mouseX, stage.mouseY);
			pCtn = new Point(subContainer.x, subContainer.y);
			
			// 清除旧缓动
			TweenLite.killTweensOf(subContainer);
			// 重置单击标识
			_clicked = false;
			
			// 处理滚动条
			if (_scrollBar)	
			{
				// 清除旧缓动
				TweenLite.killTweensOf(_scrollBar);
				
				// 显示滚动条（拖动对象大于显示区域时）
				if ((isX && subContainer.width > length) || (!isX && subContainer.height > length))
				{
					_scrollBar.alpha = 1;
				}
				
				// 更新滚动条
				updateScrollBar();
			}
		}
		// MOUSE_MOVE
		private function onMove(e:MouseEvent):void 
		{
			// 拖动
			if (isX) subContainer.x = pCtn.x + (stage.mouseX - pStg.x);	
			else	 subContainer.y = pCtn.y + (stage.mouseY - pStg.y);
			
			// 更新滚动条
			updateScrollBar();
		}
		// MOUSE_UP
		private function onUp(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE	, onMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP	, onUp	);
			stage.removeEventListener(MouseEvent.ROLL_OUT	, onUp	);
			
			// 拖出边缘时弹回
			if (isX)
			{
				// 被拖动对象的尺寸小于或等于显示区域时，始终对齐起始端
				if (subContainer.width <= length)
				{
					TweenLite.to(subContainer, 0.5, { x:0, 								onUpdate:updateScrollBar, onComplete:hideScrollBar } );
				}
				// 左边缘被拖出
				else if (subContainer.x > 0)
				{
					TweenLite.to(subContainer, 0.5, { x:0, 								onUpdate:updateScrollBar, onComplete:hideScrollBar } );
				}
				// 右边缘被拖出
				else if (subContainer.x < -subContainer.width + length)
				{
					TweenLite.to(subContainer, 0.5, { x:-subContainer.width + length,	onUpdate:updateScrollBar, onComplete:hideScrollBar } );  
				}
				// 被拖动对象的尺寸大于显示区域，且边缘未被拖出时，隐藏滚动条
				else
				{
					hideScrollBar();
				}
			}
			else
			{
				if (subContainer.height < length)
				{
					TweenLite.to(subContainer, 0.5, { y:0, 								onUpdate:updateScrollBar, onComplete:hideScrollBar } );
				}
				else if (subContainer.y > 0)
				{
					TweenLite.to(subContainer, 0.5, { y:0, 								onUpdate:updateScrollBar, onComplete:hideScrollBar } );
				}
				else if (subContainer.y < -subContainer.height + length)
				{
					TweenLite.to(subContainer, 0.5, { y:-subContainer.height + length,	onUpdate:updateScrollBar, onComplete:hideScrollBar } );
				}
				else
				{
					hideScrollBar();
				}
			}
			
			// 判断是否符合单击条件。
			if (Math.abs(stage.mouseX - pStg.x) < _clickDeviation && Math.abs(stage.mouseY - pStg.y) < _clickDeviation) 
			{
				_clicked = true;
			}
		}
		
		/** 隐藏滚动条 */
		private function hideScrollBar():void 
		{
			// 有滚动条时才操作
			if (!_scrollBar) return;
			
			TweenLite.to(_scrollBar, 0.5, { alpha:0 } );
		}
		/** 更新滚动条 */
		private function updateScrollBar():void 
		{
			// 有滚动条时才操作
			if (!_scrollBar) return;
			
			var pa:Number;	// 滚动条大小
			var pb:Number;	// 滚动条位置
			
			// 水平方向
			if (isX)
			{
				// 显示内容小于显示区域
				if (subContainer.width < length )
				{ 
					pa = 1; 
					pb = 0; 
				}
				// 显示内容大于显示区域
				else
				{
					// 左边缘被拖出
					if (subContainer.x > 0)
					{
						pa = length / (subContainer.x + subContainer.width); 
						pb = 0;
					}
					// 右边缘被拖出
					else if (subContainer.x < -subContainer.width + length)
					{
						pa = length / ( -subContainer.x + length);
						pb = 1 - pa;
					}
					// 边缘未被拖出
					else
					{
						pa = length / subContainer.width;
						pb = -subContainer.x / subContainer.width;
					}
				}
			}
			// 垂直方向
			else
			{
				// 显示内容小于显示区域
				if (subContainer.height < length)
				{ 
					pa = 1;
					pb = 0;
				}
				// 显示内容大于显示区域
				else 
				{
					if (subContainer.y > 0)
					{
						pa = length / (subContainer.y + subContainer.height);
						pb = 0;
					}
					else if (subContainer.y < -subContainer.height + length)
					{
						pa = length / ( -subContainer.y + length);
						pb = 1 - pa;
					}
					else
					{
						pa = length / subContainer.height;
						pb = -subContainer.y / subContainer.height;
					}
				}
			}
			
			// 更新滚动条
			_scrollBar.update(pa, pb); 	
		}
		/** 根据 subContainer 容器的大小更新 cover 和 subMask 的尺寸 */
		private function updateViewRect():void
		{
			// 更新遮罩和填充对象的尺寸。因为初始化本对象时并不知道被拖动的子对象尺寸，无法确定遮罩和充填对象的大小。所以在这里确定。
			if (isX)
			{
				cover  .height =
				subMask.height = subContainer.height;
			}
			else
			{
				cover  .width =
				subMask.width = subContainer.width;
			}
			
			// 重定位滚动条边距
			if (_scrollBar)
			{
				if (isX) _scrollBar.y = subContainer.height - _scrollBar.height - _scrollBar.offset;
				else	 _scrollBar.x = subContainer.width  - _scrollBar.width  - _scrollBar.offset;
			}
		}
		
		
		// 重写所有操作子显示对象的方法。都转移操作到 subContainer 容器上。
		override public function addChild(child:DisplayObject):DisplayObject {
			var obj:DisplayObject = subContainer.addChild(child);
			updateViewRect();
			return obj;
		}
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject {
			var obj:DisplayObject = subContainer.addChildAt(child, index);
			updateViewRect();
			return obj;
		}
		override public function getChildAt(index:int):DisplayObject {
			var obj:DisplayObject = subContainer.getChildAt(index);
			updateViewRect();
			return obj;
		}
		override public function getChildByName(name:String):DisplayObject {
			var obj:DisplayObject = subContainer.getChildByName(name);
			updateViewRect();
			return obj;
		}
		override public function getChildIndex(child:DisplayObject):int {
			var obj:int = subContainer.getChildIndex(child);
			updateViewRect();
			return obj;
		}
		override public function removeChild(child:DisplayObject):DisplayObject {
			var obj:DisplayObject = subContainer.removeChild(child);
			updateViewRect();
			return obj;
		}
		override public function removeChildAt(index:int):DisplayObject {
			var obj:DisplayObject = subContainer.removeChildAt(index);
			updateViewRect();
			return obj;
		}
		override public function removeChildren(beginIndex:int = 0, endIndex:int = 2147483647):void {
			subContainer.removeChildren(beginIndex, endIndex);
			updateViewRect();
		}
		
		
		
		/**
		 * 滚动条。
		 * <p>此属性为空时则没有滚动条（缺省为空）。</p>
		 */
		public function get scrollBar():ScrollBar {
			return _scrollBar;
		}
		public function set scrollBar(value:ScrollBar):void {
			// 清除旧滚动条（如果有）
			if (_scrollBar) removeChild(_scrollBar);
			
			_scrollBar = value;
			
			if (_scrollBar)
			{
				// 边距定位
				if (isX) _scrollBar.y = subMask.height - _scrollBar.height - _scrollBar.offset;
				else	 _scrollBar.x = subMask.width  - _scrollBar.width  - _scrollBar.offset;
				
				// 添加新滚动条
				_scrollBar.alpha = 0;
				super.addChild(_scrollBar);
				// 更新滚动条
				updateScrollBar();
			}
		}
		
		/**
		 * 最近一次拖动操作是否被判断为单击。
		 * <p>可与子元素自身的 MOUSE_CLICK 事件配合来判断拖动时子元素是否被单击（不能与子元素的 MOUSE_UP 事件配合，原因参考鼠标事件发生顺序）。</p>
		 */
		public function get clicked():Boolean {
			return _clicked;
		}
		
		/**
		 * 单击最大偏差值。即拖动操作被判断为单击操作时，DOWN和UP的位置的最大偏差值（单位：象素，缺省值：10）。
		 * @default 10
		 */
		public function get clickDeviation():uint {
			return _clickDeviation;
		}
		public function set clickDeviation(value:uint):void {
			_clickDeviation = value;
		}
		
		/**
		 * 是否允许用鼠标滚轮滚动页面（缺省值：false）。
		 * @default false
		 */
		public function get wheelEnabled():Boolean {
			return _wheelEnabled;
		}
		public function set wheelEnabled(value:Boolean):void {
			_wheelEnabled = value;
			
			if (_wheelEnabled)	addEventListener(MouseEvent.MOUSE_WHEEL, onWheel);
			else				removeEventListener(MouseEvent.MOUSE_WHEEL, onWheel);
		}
		
		/**
		 * 鼠标滚轮事件delta参数加持。加持量为[滚动距离 = MouseEvent.delta * wheelDelta]（单位：象素，缺省值：20）。
		 * @default	20
		 */
		public function get wheelDelta():uint {
			return _wheelDelta;
		}
		public function set wheelDelta(value:uint):void {
			_wheelDelta = value;
		}
		
	}

}