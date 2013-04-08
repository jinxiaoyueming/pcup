package com.pcup.display 
{
	import com.greensock.TweenLite;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	
	/**
	 * PageSpr 类的实例是一个可拖动翻页的 Sprite 对象。
	 * 
	 * <p>会自动为拖动对象生成遮罩。遮罩在手动方向上的长度由构造方法中的 L 参数来确定，另一方向上的长度会根据添加的对象的大小自动调整。</p>
	 * 
	 * <p>说明：所有被添加到拖动容器（subCtn）中的对象我们称之为“子元素”。</p>
	 * 
	 * @example	
下面是一个简单的使用示例。首先会创建一个 PageSpr 实例，然后添加拖动子元素，并设置页标记点。
<listing version="3.0">
// 创建实例
var p:PageSpr = new PageSpr(300, true);
addChild(p);

// 添加拖动子元素
[Embed(source = "a.png")]
var EA:Class;
p.addSub(new EA);

// 设置页标记点
p.pageDot = new PageDot(true);
</listing>
	 * 
	 * @see	com.pcup.display.PageDot
	 * 
	 * @author PH
	 */
	public class PageSpr extends Sprite 
	{
		private var PstgD:Point;															// MOUSE_DOWN 时，光标在舞台上的坐标（拖动用）
		private var PctnD:Point;															// MOUSE_DOWN 时，光标在Pctn中的坐标（拖动用）
		private var Pstg:Point;																// MOUSE_DOWN 时，光标在舞台上的坐标（翻页用）
		private var Pctn:Point;																// MOUSE_DOWN 时，光标在Pctn中的坐标（翻页用）
		
		private var subCtn:Sprite;															// 子元素的容器。
		private var M:Shape;																// subCtn 的遮罩。
		private var fillObj:Shape;															// 用来填充的对象，防止在空白处无法拖动。
		
		private var L:int;																	// 一页的长度。
		private var isX:Boolean;															// 拖动方向，true为水平方向，false为垂直方向。
		private var ready:Boolean;															// 翻页完成的标记。完成后才允许 Pstg&Pctn 记录数据，否则在上次缓动未完成时拖动会造成位置判断异常。
		
		private var _pageDot:PageDot;														// 当此参数有值时，显示页点。
		private var _clicked:Boolean;														// 本对象的最近一次拖动操作是否被判断为单击。
		private var _clickDeviation:uint = 10;												// 单击最大偏差值。即拖动操作被判断为单击操作时，DOWN和UP的位置的最大偏差值（单位：象素，缺省值：10）。
		private var _pageThreshold:Number = 0.15;											// 翻页阀值。即拖动操作被判断为翻页操作的最小拖动距离（以页长的百分比来计算，缺省值：15%）
		
		
		/**
		 * 创建一个新的 PageSpr 实例。
		 * @param	L	在拖动方向上一页的长度。
		 * @param	isX	翻页的方向（ture表示水平方向，false表示垂直方向）。
		 */
		public function PageSpr(L:uint, isX:Boolean) 
		{
			this.L = L;
			this.isX = isX;
			
			// 用来填充的对象，防止在空白处无法拖动。
			fillObj = new Shape();
			fillObj.graphics.beginFill(0);
			if (isX) fillObj.graphics.drawRect(0, 0, L, 1);
			else	 fillObj.graphics.drawRect(0, 0, 1, L);
			fillObj.graphics.endFill();
			fillObj.alpha = 0;
			addChild(fillObj);
			
			// 拖动容器的遮罩
			M = new Shape();
			M.graphics.beginFill(0);
			M.graphics.drawRect(0, 0, fillObj.width, fillObj.height);
			M.graphics.endFill();
			addChild(M);
			
			// 拖动容器
			subCtn = new Sprite();
			subCtn.mask = M;
			addChild(subCtn);
			
			// 允许 Pstg&Pctn 记录数据
			ready = true;
			
			// 监听 MOUSE_DOWN 来开始拖动
			addEventListener(MouseEvent.MOUSE_DOWN, onDown);
		}
		
		// MOUSE_DOWN
		private function onDown(e:MouseEvent):void 
		{
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove);
			stage.addEventListener(MouseEvent.MOUSE_UP, onUp);
			stage.addEventListener(MouseEvent.ROLL_OUT, onUp);
			
			TweenLite.killTweensOf(subCtn);													// 清除旧缓动
			_clicked = false;																// 重置单击标识
			
			// 记录下当前坐标数据（拖动用）
			PstgD = new Point(stage.mouseX, stage.mouseY);
			PctnD = new Point(subCtn.x, subCtn.y);
			
			// 是否需要更新坐标数据（翻页用）,当翻页完成后才需要更新（即 ready == true 时）。
			if(ready)
			{
				ready = false;
				
				Pstg = PstgD;
				Pctn = PctnD;
			}
		}
		// MOUSE_MOVE
		private function onMove(e:MouseEvent):void 
		{
			if (isX) subCtn.x = PctnD.x + (stage.mouseX - PstgD.x);
			else	 subCtn.y = PctnD.y + (stage.mouseY - PstgD.y);
		}
		// MOUSE_UP
		private function onUp(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onUp);
			stage.removeEventListener(MouseEvent.ROLL_OUT, onUp);
			
			
			// 临时参数，下面的翻页判断需要。
			var offset:int = isX ? (stage.mouseX - Pstg.x) : (stage.mouseY - Pstg.y);							// 当前拖动的位置偏移值
			var min:uint = L * _pageThreshold;																	// 判断为翻页的最小值
			
			// 翻页判断
			if (offset > min && (isX ? Pctn.x : Pctn.y) < 0)													// 向右（下）翻
			{
				if (isX)	TweenLite.to(subCtn, 0.5, { x:Pctn.x + L, onComplete:pageComplete } );
				else		TweenLite.to(subCtn, 0.5, { y:Pctn.y + L, onComplete:pageComplete } );
			}
			else if (offset < -min && (isX ? Pctn.x : Pctn.y) > ((isX ? -subCtn.width : -subCtn.height) + L))	// 向左（上）翻
			{
				if (isX)	TweenLite.to(subCtn, 0.5, { x:Pctn.x - L, onComplete:pageComplete } );
				else		TweenLite.to(subCtn, 0.5, { y:Pctn.y - L, onComplete:pageComplete } );
			}
			else																								// 不符合翻页条件时，回到拖动前的位置。
			{
				if (isX)	TweenLite.to(subCtn, 0.5, { x:Pctn.x, onComplete:pageComplete } );
				else		TweenLite.to(subCtn, 0.5, { y:Pctn.y, onComplete:pageComplete } );
			}
			
			
			// 判断是否符合单击条件。
			if (Math.abs(stage.mouseX - Pstg.x) < _clickDeviation && Math.abs(stage.mouseY - Pstg.y) < _clickDeviation) 
			{
				_clicked = true;		// 本参数可以配合子对象自身的 MOUSE_CLICK 事件来判断拖动时子对象是是否被单击了。
			}
		}
		// 翻页缓动完成
		private function pageComplete():void 
		{
			// 更新页点
			if(_pageDot) _pageDot.update(Math.floor(Math.abs(isX ? subCtn.x : subCtn.y) / L));
			
			// 允许 Pstg&Pctn 记录数据
			ready = true;
		}
		
		
		/**
		 * 添加一个显示对象到拖动容器中。
		 * @param	obj	要添加的显示对象。
		 */
		public function addSub(obj:DisplayObject):void
		{
			subCtn.addChild(obj);
			
			// 更新遮罩和填充对象的尺寸。因为初始化本对象时并不知道被拖动的子对象尺寸，无法确定遮罩和充填对象的大小。所以在这里确定。
			if (isX) fillObj.height = M.height = subCtn.height;
			else	 fillObj.width = M.width = subCtn.width;
			
			// 更新页点
			if (_pageDot)
			{
				// 设置总页点数
				_pageDot.setQuantity(Math.ceil((isX ? width : height) / L));
				// 激活页点
				_pageDot.update(Math.floor(Math.abs(isX ? subCtn.x : subCtn.y) / L));
				
				if (isX) 
				{
					_pageDot.x = (L - _pageDot.width) / 2;					// 居中定位
					_pageDot.y = subCtn.height + _pageDot.offset;			// 边距定位
				}
				else
				{
					_pageDot.y = (L - _pageDot.height) / 2;
					_pageDot.x = subCtn.width + _pageDot.offset;
				}
			}
		}
		
		/**
		 * 设置当前页。
		 * 当子元素需要被显示到可见区域来时就需要这个方法。
		 * @param	num	当前页（第一页为0，第二页为1，以此类推）。
		 */
		public function page(p:uint):void
		{
			if (isX) subCtn.x = -L * p;
			else	 subCtn.y = -L * p;
		}
		
		
		
		
		
		/**
		 * 页点。
		 * 
		 * <p>此属性为空时则没有页点（缺省为空）。</p>
		 */
		public function get pageDot():PageDot 
		{
			return _pageDot;
		}
		public function set pageDot(value:PageDot):void 
		{
			// 清除旧页点（如果有）
			if (_pageDot) removeChild(_pageDot);
			
			_pageDot = value;
			
			if (_pageDot)
			{
				// 设置总页点数
				_pageDot.setQuantity(Math.ceil((isX ? width : height) / L));
				// 激活页点
				_pageDot.update(Math.floor(Math.abs(isX ? subCtn.x : subCtn.y) / L));
				
				if (isX) 
				{
					_pageDot.x = (L - _pageDot.width) / 2;					// 居中定位
					_pageDot.y = subCtn.height + _pageDot.offset;			// 边距定位
				}
				else
				{
					_pageDot.y = (L - _pageDot.height) / 2;
					_pageDot.x = subCtn.width + _pageDot.offset;
				}
				
				// 添加新页点
				addChild(_pageDot);
			}
		}
		
		/**
		 * 最近一次拖动操作是否被判断为单击。
		 * 
		 * <p>可与子元素自身的 MOUSE_CLICK 事件配合来判断拖动时子元素是否被单击（不能与子元素的 MOUSE_UP 事件配合，原因参考鼠标事件发生顺序）。</p>
		 */
		public function get clicked():Boolean 
		{
			return _clicked;
		}
		
		/**
		 * 单击最大偏差值。即拖动操作被判断为单击操作时，DOWN和UP的位置的最大偏差值（单位：象素，缺省值：10）。
		 * @default 10
		 */
		public function get clickDeviation():uint 
		{
			return _clickDeviation;
		}
		public function set clickDeviation(value:uint):void 
		{
			_clickDeviation = value;
		}
		
		/**
		 * 翻页阀值。即拖动操作被判断为翻页操作的最小拖动距离（以页长的百分比来计算，缺省值：15%）
		 * @default 0.15
		 */
		public function get pageThreshold():Number 
		{
			return _pageThreshold;
		}
		public function set pageThreshold(value:Number):void 
		{
			_pageThreshold = value;
		}
	}

}