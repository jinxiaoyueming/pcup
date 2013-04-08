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
	 * DragSpr 类的实例是一个可拖动的 Sprite 对象。
	 * 
	 * <p>会自动为拖动对象生成遮罩。遮罩在手动方向上的长度由构造方法中的 L 参数来确定，另一方向上的长度会根据添加的对象的大小自动调整。</p>
	 * 
	 * <p>说明：所有被添加到拖动容器（subCtn）中的对象我们称之为“子元素”。</p>
	 * 
	 * @example	
下面是一个简单的使用示例。首先会创建一个 DragSpr 实例，然后添加拖动子元素，并设置滚动条。
<listing version="3.0">
// 创建实例
var d:DragSpr = new DragSpr(300, true);
addChild(d);

// 添加拖动子元素
[Embed(source = "a.png")]
var EA:Class;
d.addSub(new EA);

// 设置滚动条
d.scrollBar = new ScrollBar(300, true);
</listing>
	 * 
	 * @see	com.pcup.display.ScrollBar
	 * 
	 * @author PH
	 */
	public class DragSpr extends Sprite 
	{
		private var Pstg:Point;							// MOUSE_DOWN事件时，鼠标的舞台坐标。
		private var Pctn:Point;							// MOUSE_DOWN事件时，鼠标的本对象坐标。
		
		private var subCtn:Sprite;						// 子元素的容器。
		private var M:Shape;							// subCtn 的遮罩。
		
		private var L:uint;								// 可视区域在拖动方向上的长度。
		private var isX:Boolean;						// 拖动方向，true为水平方向，false为垂直方向。
		
		private var _scrollBar:ScrollBar;				// 当此参数有值时，显示滚动条。
		private var _clicked:Boolean;					// 本对象的最近一次拖动操作是否被判断为单击。
		private var _clickDeviation:uint = 10;			// 单击最大偏差值。即拖动操作被判断为单击操作时，DOWN和UP的位置的最大偏差值（单位：象素，缺省值：10）。
		private var _wheelEnabled:Boolean = false;		// 是否允许用鼠标滚轮滚动页面（缺省值：false）。
		private var _wheelDelta:uint = 20;				// 鼠标滚轮事件delta参数加持。加持量为[滚动距离 = MouseEvent.delta * wheelDelta]（单位：象素，缺省值：20）。
		
		
		/**
		 * 创建一个新的 DragSpr 实例。
		 * @param	L	可视区域在拖动方向上的长度。
		 * @param	isX	拖动的方向（ture表示水平方向，false表示垂直方向）。
		 */
		public function DragSpr(L:uint, isX:Boolean) 
		{
			this.L = L;
			this.isX = isX;
			
			// 拖动容器的遮罩
			M = new Shape();
			M.graphics.beginFill(0);
			if (isX) M.graphics.drawRect(0, 0, L, 1);
			else	 M.graphics.drawRect(0, 0, 1, L);
			M.graphics.endFill();
			addChild(M);
			
			// 拖动容器
			subCtn = new Sprite();
			subCtn.mask = M;
			addChild(subCtn);
			
			// 监听鼠标事件来实现拖动
			addEventListener(MouseEvent.MOUSE_DOWN, onDown);
		}
		
		// MOUSE_WHEEL
		private function onWheel(e:MouseEvent):void 
		{
			if (isX && subCtn.width > L) 
			{
				subCtn.x += e.delta * wheelDelta;
				
				// 超出边界就对齐到边界
					 if (subCtn.x > 0)					subCtn.x = 0;
				else if (subCtn.x < -subCtn.width + L)  subCtn.x = -subCtn.width + L;
			}
			else if (!isX && subCtn.height > L)
			{
				subCtn.y += e.delta * wheelDelta;
				
				// 超出边界就对齐到边界
					 if (subCtn.y > 0) 					subCtn.y = 0;
				else if (subCtn.y < -subCtn.height + L) subCtn.y = -subCtn.height + L;
			}
			
			// 显示滚动条
			if (_scrollBar)	
			{
				TweenLite.killTweensOf(_scrollBar);													// 清除旧缓动
				if ((isX && subCtn.width > L) || (!isX && subCtn.height > L)) _scrollBar.alpha = 1;	// 显示滚动条（拖动对象大于显示区域时）
				update();																			// 更新滚动条
				hide();																				// 缓动隐藏
			}
		}
		// MOUSE_DOWN
		private function onDown(e:MouseEvent):void 
		{
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMove); 
			stage.addEventListener(MouseEvent.MOUSE_UP, onUp);
			stage.addEventListener(MouseEvent.ROLL_OUT, onUp);
			
			Pstg = new Point(stage.mouseX, stage.mouseY);		// 存储位置信息
			Pctn = new Point(subCtn.x, subCtn.y);
			
			TweenLite.killTweensOf(subCtn);		// 清除旧缓动
			_clicked = false;					// 重置单击标识
			
			// 显示滚动条
			if (_scrollBar)	
			{
				TweenLite.killTweensOf(_scrollBar);													// 清除旧缓动
				if ((isX && subCtn.width > L) || (!isX && subCtn.height > L)) _scrollBar.alpha = 1;	// 显示滚动条（拖动对象大于显示区域时）
				update();																			// 更新滚动条
			}
		}
		// MOUSE_MOVE
		private function onMove(e:MouseEvent):void 
		{
			if (isX) subCtn.x = Pctn.x + (stage.mouseX - Pstg.x);							// 拖动
			else	 subCtn.y = Pctn.y + (stage.mouseY - Pstg.y);
			
			update();																		// 更新滚动条
		}
		// MOUSE_UP
		private function onUp(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMove);
			stage.removeEventListener(MouseEvent.MOUSE_UP, onUp);
			stage.removeEventListener(MouseEvent.ROLL_OUT, onUp);
			
			// 拖出边缘时弹回
			if (isX)
			{
					 if (subCtn.width < L)				TweenLite.to(subCtn, 0.5, { x:0, 					onUpdate:update, onComplete:hide } );	// 被拖动对象的尺寸不大于显示区域时，始终对齐起始端
				else if (subCtn.x > 0)					TweenLite.to(subCtn, 0.5, { x:0, 					onUpdate:update, onComplete:hide } );   // 左边缘被拖出
				else if (subCtn.x < -subCtn.width + L) 	TweenLite.to(subCtn, 0.5, { x: -subCtn.width + L, 	onUpdate:update, onComplete:hide } );   // 右边缘被拖出
				else 									hide();
			}
			else
			{
					 if (subCtn.height < L) 			TweenLite.to(subCtn, 0.5, { y:0, 					onUpdate:update, onComplete:hide } );
				else if (subCtn.y > 0) 					TweenLite.to(subCtn, 0.5, { y:0, 					onUpdate:update, onComplete:hide } );
				else if (subCtn.y < -subCtn.height + L) TweenLite.to(subCtn, 0.5, { y:-subCtn.height + L, 	onUpdate:update, onComplete:hide } );
				else 									hide();
			}
			
			
			// 判断是否符合单击条件。
			if (Math.abs(stage.mouseX - Pstg.x) < _clickDeviation && Math.abs(stage.mouseY - Pstg.y) < _clickDeviation) 
			{
				_clicked = true;		// 本参数可以配合子对象自身的 MOUSE_CLICK 事件来判断拖动时子对象是是否被单击了。
			}
		}
		// 隐藏滚动条
		private function hide():void 
		{
			if (_scrollBar) TweenLite.to(_scrollBar, 0.5, { alpha:0 } );
		}
		
		// 更新滚动条
		private function update(e:Event = null):void 
		{
			if (_scrollBar)			// 有滚动条时才更新
			{
				var pa:Number;		// 滚动条大小
				var pb:Number;		// 滚动条位置
				
				if (isX)			// 水平方向
				{
					if (subCtn.width < L )	{ pa = 1; pb = 0; }		// 显示内容小于显示区域
					else 											// 显示内容大于显示区域
					{
							 if (subCtn.x > 0) 					{ pa = L / (subCtn.x + subCtn.width); 	pb = 0; 						}
						else if (subCtn.x < -subCtn.width + L) 	{ pa = L / (-subCtn.x + L); 			pb = 1 - pa; 					}
						else									{ pa = L / subCtn.width; 				pb = -subCtn.x / subCtn.width; 	}
					}
				}
				else
				{
					if (subCtn.height < L)	{ pa = 1; pb = 0; }	
					else 
					{
							 if (subCtn.y > 0) 					{ pa = L / (subCtn.y + subCtn.height); 	pb = 0; 						}
						else if (subCtn.y < -subCtn.height + L) { pa = L / (-subCtn.y + L); 			pb = 1 - pa; 					}
						else									{ pa = L / subCtn.height; 				pb = -subCtn.y / subCtn.height; }
					}
				}
				
				// 更新滚动条
				_scrollBar.update(pa, pb); 	
			}
		}
		
		
		/**
		 * 添加一个显示对象到拖动容器中（只有通过此方法添加的了元素才会被拖动）。
		 * @param	obj	要添加的显示对象。
		 */
		public function addSub(obj:DisplayObject):void
		{
			subCtn.addChild(obj);
			
			// 更新遮罩和填充对象的尺寸。因为初始化本对象时并不知道被拖动的子对象尺寸，无法确定遮罩和充填对象的大小。所以在这里确定。
			if (isX) M.height = subCtn.height;
			else	 M.width = subCtn.width;
			
			// 重定位滚动条边距
			if (_scrollBar)
			{
				if (isX) _scrollBar.y = subCtn.height - _scrollBar.height - _scrollBar.offset;
				else	 _scrollBar.x = subCtn.width - _scrollBar.width - _scrollBar.offset;
			}
		}
		
		
		
		
		/**
		 * 滚动条。
		 * <p>此属性为空时则没有滚动条（缺省为空）。</p>
		 */
		public function get scrollBar():ScrollBar 
		{
			return _scrollBar;
		}
		public function set scrollBar(value:ScrollBar):void 
		{
			// 清除旧滚动条（如果有）
			if (_scrollBar) removeChild(_scrollBar);
			
			_scrollBar = value;
			
			if (_scrollBar)
			{
				// 边距定位
				if (isX) _scrollBar.y = subCtn.height - _scrollBar.height - _scrollBar.offset;
				else	 _scrollBar.x = subCtn.width - _scrollBar.width - _scrollBar.offset;
				
				// 添加新滚动条
				_scrollBar.alpha = 0;
				addChild(_scrollBar);
				
				update();
			}
		}
		
		/**
		 * 最近一次拖动操作是否被判断为单击。
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
		 * 是否允许用鼠标滚轮滚动页面（缺省值：false）。
		 * @default false
		 */
		public function get wheelEnabled():Boolean 
		{
			return _wheelEnabled;
		}
		public function set wheelEnabled(value:Boolean):void 
		{
			_wheelEnabled = value;
			
			if (_wheelEnabled)	addEventListener(MouseEvent.MOUSE_WHEEL, onWheel);
			else				removeEventListener(MouseEvent.MOUSE_WHEEL, onWheel);
		}
		
		/**
		 * 鼠标滚轮事件delta参数加持。加持量为[滚动距离 = MouseEvent.delta * wheelDelta]（单位：象素，缺省值：20）。
		 * @default	20
		 */
		public function get wheelDelta():uint 
		{
			return _wheelDelta;
		}
		public function set wheelDelta(value:uint):void 
		{
			_wheelDelta = value;
		}
		
	}

}