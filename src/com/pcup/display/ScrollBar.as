package com.pcup.display 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	
	/**
	 * ScrollBar 类的实例是作为 DragSpr 对象的配置项而存在，这就是滚动条。
	 * 
	 * <p>缺省的滚动条素材是用代码画的灰色方块，可通过 setMaterail() 方法来更新素材。</p>
	 * 
	 * @see	com.pcup.display.drag.DragSpr
	 * 
	 * @author PH
	 */
	public class ScrollBar extends Sprite 
	{
		private var L:uint;																	// 滚动条长度
		private var isX:Boolean;															// 滚动条的方向
		private var _offset:int;															// 滚动条对象在 DragSpr 对象中与停靠边缘的距离偏移值（正值表示向内偏移，负值表示向外偏移）。
		
		private var bgA:DisplayObject;														// 滚动条的背景 - 上
		private var bgB:DisplayObject;														// 滚动条的背景 - 中
		private var bgC:DisplayObject;														// 滚动条的背景 - 上
		private var barA:DisplayObject;														// 滑块 - 上
		private var barB:DisplayObject;														// 滑块 - 中
		private var barC:DisplayObject;														// 滑块 - 上
		
		
		/**
		 * 创建一个新的 ScrollBar 实例。
		 * @param	L	长度。
		 * @param	isX	方向（ture表示水平方向，false表示垂直方向）。
		 * @param	w	宽度。
		 * @param	_offset	在 DragSpr 对象中与停靠边缘的距离偏移值（正值表示向内偏移，负值表示向外偏移）。
		 */
		public function ScrollBar(L:uint, isX:Boolean, w:uint = 5, _offset:int = 3) 
		{
			this.L = L;
			this.isX = isX;
			this._offset = _offset;
			
			
			// 画缺省的素材
			var mBgA :Shape = drawShape(isX ? w / 2 : w, isX ? w : w / 2, 0.2);
			var mBgB :Shape = drawShape(isX ? 1 	: w, isX ? w : 1	, 0.2);
			var mBgC :Shape = drawShape(isX ? w / 2 : w, isX ? w : w / 2, 0.2);
			var mBarA:Shape = drawShape(isX ? w / 2 : w, isX ? w : w / 2, 1);
			var mBarB:Shape = drawShape(isX ? 1 	: w, isX ? w : 1	, 1);
			var mBarC:Shape = drawShape(isX ? w / 2 : w, isX ? w : w / 2, 1);
			setMaterail(mBgA, mBgB, mBgC, mBarA, mBarB, mBarC);
			
			// 本模块不需要鼠标事件
			mouseEnabled = false;
			mouseChildren = false;
		}
		private function drawShape(w:Number, h:Number, a:Number):Shape {
			var s:Shape = new Shape();
			s.graphics.beginFill(0, a);
			s.graphics.drawRect(0, 0, w, h);
			s.graphics.endFill();
			
			return s;
		}
		
		
		/**
		 * 设置素材（为 null 值的参数对应的素材不会被替换）。
		 * @param	mBgA	底 - 上。
		 * @param	mBgB	底 - 中。
		 * @param	mBgC	底 - 下。
		 * @param	mBarA	滑块 - 上。
		 * @param	mBarB	滑块 - 中。
		 * @param	mBarC	滑块 - 下。
		 */
		public function setMaterail(mBgA:DisplayObject = null, 
									mBgB:DisplayObject = null, 
									mBgC:DisplayObject = null, 
									mBarA:DisplayObject = null, 
									mBarB:DisplayObject = null, 
									mBarC:DisplayObject = null):void 
		{
			// 记录素材更新前的大小和位置（如果有的话，没有就取初始值），以便素材更新后恢复之前的大小和位置。
			var pa:Number = 1; 
			var pb:Number = 0;
			if (bgA)
			{
				if (isX)
				{
					pa = (barA.width + barB.width + barC.width) / L;
					pb = barA.x / L;
				}
				else
				{
					pa = (barA.height + barB.height + barC.height) / L;
					pb = barA.y / L;
				}
			}
			
			
			// 移除旧素材（在新、旧素材都存在的情况下）
			if (mBgA  && bgA  && contains(bgA))	 	removeChild(bgA);
			if (mBgB  && bgB  && contains(bgB))  	removeChild(bgB);
			if (mBgC  && bgC  && contains(bgC))  	removeChild(bgC);
			if (mBarA && barA && contains(barA)) 	removeChild(barA);
			if (mBarB && barB && contains(barB)) 	removeChild(barB);
			if (mBarC && barC && contains(barC)) 	removeChild(barC);
			
			// 换上新素材（如果有新素材的话）
			if (mBgA) 	bgA  = mBgA;
			if (mBgB) 	bgB  = mBgB;
			if (mBgC) 	bgC  = mBgC;
			if (mBarA)	barA = mBarA;	
			if (mBarB)	barB = mBarB;	
			if (mBarC)	barC = mBarC;	
			// 再全部添加一遍，防止添加部分素材时，盖住了本应该在上面的素材。
			addChild(bgA); 
			addChild(bgB); 
			addChild(bgC); 
			addChild(barA);
			addChild(barB);
			addChild(barC);
			
			// 新背景素材定位
			if (isX)
			{
				bgB.width = L - bgA.width - bgC.width;
				bgB.x = bgA.width;
				bgC.x = bgB.width + bgB.x;
			}
			else
			{
				bgB.height = L - bgA.height - bgC.height;
				bgB.y = bgA.height;
				bgC.y = bgB.height + bgB.y;
			}
			
			
			// 恢复更新前的大小和位置
			update(pa, pb);
		}
		
		/**
		 * 更新滚动条的长度和位置。
		 * <p />
		 * 以百分比表示（取值范围为0~1。如：0表示在顶端、0.5表示在中间、1表示在底端）。
		 * @param	pA	滑块长度与整个滚动条长度的比值。
		 * @param	pB	滑块顶端在整个滚动条中的位置。
		 */
		public function update(pA:Number, pB:Number):void
		{
			if (isX)
			{
				barB.width = uint(L * pA) - barA.width - barC.width;	// 要用 uint() 取整，不然素材定位时会因为浮点数而出现对不齐的现象。
				
				barA.x = uint(L * pB);
				barB.x = barA.x + barA.width;
				barC.x = barB.x + barB.width;
			}
			else
			{
				barB.height = uint(L * pA) - barA.height - barC.height;
				
				barA.y = uint(L * pB);
				barB.y = barA.y + barA.height;
				barC.y = barB.y + barB.height;
			}
		}
		
		
		// 画出一个显示对象的副本。
		private function draw(obj:DisplayObject):Bitmap 
		{
			var bmd:BitmapData = new BitmapData(obj.width, obj.height, true, 0);
			bmd.draw(obj);
			
			return new Bitmap(bmd);
		}
		
		
		
		
		/**
		 * 滚动条对象在 DragSpr 对象中与停靠边缘的距离偏移值（正值表示向内偏移，负值表示向外偏移）。
		 * <p />
		 * 说明：给 DragSpr 对象使用的。DragSpr 对象获取这个参数用以为滚动条对象定位。
		 */
		public function get offset():int 
		{
			return _offset;
		}
		
		/**
		 * 滚动条长度。
		 */
		public function get long():uint 
		{
			return L;
		}
		
		
	}

}