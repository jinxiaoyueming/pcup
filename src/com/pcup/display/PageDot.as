package com.pcup.display 
{
	import flash.display.Shape;
	import flash.display.Sprite;
	
	/**
	 * PageDot 类的实例是作为 PageSpr 对象的配置项而存在，这就是页标记点。
	 * 
	 * @see	com.pcup.display.PageSpr
	 * 
	 * @author PH
	 */
	public class PageDot extends Sprite 
	{
		private var isX:Boolean;					// 拖动条的方向
		private var r:uint;							// 页点半径
		private var _offset:int;					// 页标记点对象在 PageSpr 对象中与停靠边缘的距离偏移值（正值表示向内偏移，负值表示向外偏移）。
		
		private var dots:Vector.<Button>;				// 页点数组
		
		
		/**
		 * 创建一个新的 PageDot 实例。
		 * @param	isX	页点摆放的方向（ture表示水平方向，false表示垂直方向）。
		 * @param	r	一个页点的半径。
		 * @param	_offset	在 PageSpr 对象中与停靠边缘的距离偏移值（正值表示向内偏移，负值表示向外偏移）。
		 */
		public function PageDot(isX:Boolean, r:uint = 3, _offset:int = 5) 
		{
			this.isX = isX;
			this.r = r;
			this._offset = _offset;
			
			// 本模块不需要鼠标事件
			mouseEnabled = false;
			mouseChildren = false;
		}
		
		
		/**
		 * 创建所有页点。
		 * @param	quantity	总页点数。
		 */
		public function setQuantity(quantity:uint):void
		{
			// 清除旧页点
			var tmp:uint = numChildren;
			for (var j:int = 0; j < tmp; j++) removeChildAt(0);
			dots = new Vector.<Button>;
			
			for (var i:int = 0; i < quantity; i++) 
			{
				// 普通状态
				var c:Shape = new Shape();
				c.graphics.beginFill(0xffffff, .3);
				c.graphics.drawCircle(r, r, r);
				c.graphics.endFill();
				var dA:Shape = c;
				// 激活状态
				c = new Shape();
				c.graphics.beginFill(0xffffff);
				c.graphics.drawCircle(r, r, r);
				c.graphics.endFill();
				var dB:Shape = c;
				
				// 生成页点
				var l:Button = new Button(dA, dB, false);
				if (isX) l.x = i * (l.width * 2);
				else 	 l.y = i * (l.width * 2);
				addChild(l);
				
				dots.push(l);
			}
		}
		
		/**
		 * 更新页点状态。即激活其中一个页点，其它的置为非激活状态。
		 * @param	index	要激活的页点的序号。
		 */
		public function update(index:uint):void
		{
			// 异常处理
			if (index + 1 > dots.length)
			{
				trace("[com.pcup.display.PageDot][错]要激活的页点超过总页点数。");
				return;
			}
			
			// 更新
			for (var i:* in dots) 
			{
				dots[i].active = (i == index);
			}
			
		}
		
		
		
		/**
		 *页标记点对象在 PageSpr 对象中与停靠边缘的距离偏移值（正值表示向内偏移，负值表示向外偏移）。
		 * 
		 * <p>说明：给 PageSpr 对象使用的。PageSpr 对象获取这个参数用以为页标记点对象定位。</p>
		 */
		public function get offset():int 
		{
			return _offset;
		}
		
	}

}