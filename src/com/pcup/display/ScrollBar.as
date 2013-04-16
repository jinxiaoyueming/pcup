package com.pcup.display 
{
	import com.pcup.utils.Util;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.geom.Rectangle;
	
	/**
	 * ScrollBar 类的实例是作为 DragSlip 对象的配置项而存在，这就是滚动条。
	 * 
	 * <p>缺省的滚动条素材是用代码画的灰色方块，可通过 setMaterail() 方法来更新素材。</p>
	 * 
	 * @see	com.pcup.display.drag.DragSlip
	 * 
	 * @author PH
	 */
	public class ScrollBar extends Sprite 
	{
		private var isX:Boolean;			// 滚动条的方向
		private var _length:uint;			// 滚动条长度
		private var _offset:int;			// 滚动条对象在 DragSlip 对象中与停靠边缘的距离偏移值（正值表示向内偏移，负值表示向外偏移）。
		
		private var bgA:DisplayObject;		// 滚动条的背景 - 上
		private var bgB:DisplayObject;		// 滚动条的背景 - 中
		private var bgC:DisplayObject;		// 滚动条的背景 - 上
		private var barA:DisplayObject;		// 滑块 - 上
		private var barB:DisplayObject;		// 滑块 - 中
		private var barC:DisplayObject;		// 滑块 - 上
		
		
		/**
		 * 创建一个新的 ScrollBar 实例。
		 * @param	isX		滚动方向（ture表示水平方向，false表示垂直方向）。
		 * @param	length	滚动条长度。
		 * @param	width	默认素材的滚动条宽度。
		 * @param	offset	在 DragSlip 对象中与停靠边缘的距离偏移值（正值表示向内偏移，负值表示向外偏移）。
		 */
		public function ScrollBar(isX:Boolean, length:Number, width:Number = 6, offset:Number = 3) 
		{
			this.isX = isX;
			this._length = length;
			this._offset = offset;
			
			// 默认素材
			setDefaultMaterail(width);
			
			// 本模块不需要鼠标事件
			mouseEnabled  = 
			mouseChildren = false;
		}
		
		/**
		 * 设置默认素材
		 * @param	w	滚动条宽度。
		 */
		private function setDefaultMaterail(w:Number):void
		{
			// 半径
			var r:Number = w / 2;
			
			// (底)画一个圆，用来切半圆用的
			var cBg:Sprite = new Sprite();
			cBg.graphics.beginFill(0, 0);
			cBg.graphics.drawCircle(r, r, r);
			cBg.graphics.endFill();
			// (滑块)画一个圆，用来切半圆用的
			var cBar:Sprite = new Sprite();
			cBar.graphics.beginFill(0, 0.4);
			cBar.graphics.drawCircle(r, r, r);
			cBar.graphics.endFill();
			// (底)画一个矩形，用来做中间可拉伸部分的素材
			var rBg:Shape = new Shape();
			rBg.graphics.beginFill(0, 0);
			if (isX) rBg.graphics.drawRect(0, 0, 1, w);
			else	 rBg.graphics.drawRect(0, 0, w, 1);
			rBg.graphics.endFill();
			// (滑块)画一个矩形，用来做中间可拉伸部分的素材
			var rBar:Shape = new Shape();
			rBar.graphics.beginFill(0, 0.4);
			if (isX) rBar.graphics.drawRect(0, 0, 1, w);
			else	 rBar.graphics.drawRect(0, 0, w, 1);
			rBar.graphics.endFill();
			
			if (isX)
			{
				var mBgA :Bitmap = Util.draw(cBg , new Rectangle(0, 0, r, w));
				var mBgC :Bitmap = Util.draw(cBg , new Rectangle(r, 0, r, w));
				var mBarA:Bitmap = Util.draw(cBar, new Rectangle(0, 0, r, w));
				var mBarC:Bitmap = Util.draw(cBar, new Rectangle(r, 0, r, w));
			}
			else
			{
				mBgA  = Util.draw(cBg , new Rectangle(0, 0, w, r));
				mBgC  = Util.draw(cBg , new Rectangle(0, r, w, r));
				mBarA = Util.draw(cBar, new Rectangle(0, 0, w, r));
				mBarC = Util.draw(cBar, new Rectangle(0, r, w, r));
			}
			var mBgB :Shape  = rBg;
			var mBarB:Shape  = rBar;
			
			setMaterail(mBgA, mBgB, mBgC, mBarA, mBarB, mBarC);
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
					pa = (barA.width + barB.width + barC.width) / _length;
					pb = barA.x / _length;
				}
				else
				{
					pa = (barA.height + barB.height + barC.height) / _length;
					pb = barA.y / _length;
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
				bgB.width = _length - bgA.width - bgC.width;
				bgB.x = bgA.width;
				bgC.x = bgB.width + bgB.x;
			}
			else
			{
				bgB.height = _length - bgA.height - bgC.height;
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
				// 最小取0，不然出现负值时滚动条长度会出现异常；
				// 用 uint() 取整，不然素材定位时会因为浮点数而出现对不齐的现象。
				barB.width = Math.max(0, uint(_length * pA) - barA.width - barC.width);	
				
				barA.x = uint(_length * pB);
				barB.x = barA.x + barA.width;
				barC.x = barB.x + barB.width;
			}
			else
			{
				barB.height = Math.max(0, uint(_length * pA) - barA.height - barC.height);
				
				barA.y = uint(_length * pB);
				barB.y = barA.y + barA.height;
				barC.y = barB.y + barB.height;
			}
		}
		
		
		
		
		/**
		 * 滚动条对象在 DragSlip 对象中与停靠边缘的距离偏移值（正值表示向内偏移，负值表示向外偏移）。
		 * <p>说明：给 DragSlip 对象使用的。DragSlip 对象获取这个参数用以为滚动条对象定位。</p>
		 */
		public function get offset():int {
			return _offset;
		}
		/** 滚动条长度。 */
		public function get length():uint {
			return _length;
		}
		
		
	}

}