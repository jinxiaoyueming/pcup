package com.pcup.display 
{
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.utils.clearTimeout;
	import flash.utils.getTimer;
	import flash.utils.setTimeout;
	
	/**
	 * 仿Apple滑动。
	 * 
	 * <p>使用说明：</p>
	 * <p>1. 内容中的对象可直接用 MouseEvent.CLICK 事件来获取单击事件, 因为在拖动时会禁用内容的鼠标事件, 就排除了拖动也会触发单击的情况。</p>
	 * <p>2. this 的所有 child 操作均被重写为内容的 child 操作。</p>
	 * <p>3. 溢出: 指某对象出现在非正常停靠位置；停靠位置: 指某对象静止下来时所在的位置。</p>
	 * <p>4. 偷窃了前人成果(http://zwwdm.com/?post=84)，取其主要思想. 表示感谢！</p>
	 * 
	 * 下面是一个简单的使用示例。
<listing version="3.0">
// 底图
var bg:Bitmap = new Bitmap(new BitmapData(600, 400, true, 0xffffd7d7));
bg.x = bg.y = 50;
addChild(bg);

// Slip 对象
var slip:Slip = new Slip(Slip.DIRECTION_AUTO, new Rectangle(0, 0, 600, 400));
slip.x = bg.x;
slip.y = bg.y;
addChild(slip);

// 内容
var _content:Sprite = new Sprite();  
for (var i:int = 0; i 〈 30; i++)
{
	for (var j:int = 0; j 〈 30; j++)
	{
		var cube:Sprite = new Sprite();
		cube.graphics.beginFill(Math.random()*0xffffff);
		cube.graphics.drawRect(0, 0, 100, 100);
		cube.graphics.endFill();
		cube.name = "(" + i + "," + j + ")";
		cube.x = j * (cube.width + 10);
		cube.y = i * (cube.height + 10);
		cube.addEventListener(MouseEvent.CLICK, onClick);
		var t:TextField = new TextField();
		t.mouseEnabled = false;
		t.text = cube.name;
		cube.addChild(t);
		_content.addChild(cube);
	}
}
slip.addChild(_content);

// 内容的单击方法
private function onClick(e:MouseEvent):void 
{
	trace(e.currentTarget.name);
}
</listing>
	 * 
	 * @author ph
	 */
	public class Slip extends Sprite 
	{
		/** 水平方向。 */		static public const DIRECTION_HORIZONTAL:uint = 1;
		/** 垂直方向。 */		static public const DIRECTION_VERTICAL	:uint = 2;
		/** 任意方向。 */		static public const DIRECTION_AUTO		:uint = 3;
		
		/** 是否使用滚动条 */
		private var _barEnable:Boolean = true;
		/** 滚动条宽度 */
		private var _barWidth:uint = 6;
		/** 滚动条的最大停靠位置(为提高效率, 故存储于些, 以免每次都运算) */
		private var _barMaxPosition:Point;
		/** 滚动条心隐藏延迟的ID */
		private var _barIntervalId:uint;
		
		/** 滑动方向 */
		private var _direction:uint;
		
		/** 是否可以水平拖动 */	private var _isX:Boolean;
		/** 是否可以垂直拖动 */	private var _isY:Boolean;
		
		/** 内容容器 */
		private var _content:Sprite;
		
		/** 水平滚动条 */	private var _hBar:Shape;
		/** 垂直滚动条 */	private var _vBar:Shape;
		
		/** 视窗尺寸 */	private var   _viewRect:Rectangle;
		/** 滚动区域 */	private var _scrollRect:Rectangle;
		
		/** 鼠标位置(开始拖动时)*/	private var _m0:Point;
		/** 鼠标位置(当前)		*/	private var _m1:Point;
		/** 内容位置(开始拖动时)*/	private var _c0:Point;
		/** 内容位置(当前)		*/	private var _c1:Point;
		
		/** 速度 */
		private var _speed:Point;
		/** 舞台鼠标路径 */
		private var _path:Vector.<PathPoint>;
		/** 是否正在作拖动操作. 以此来代替是否达到拖动条件的运算判断, 提高效率 */
		private var _isDragging:Boolean;
		
		
		/**
		 * 创建一个新的 Slip 实例。
		 * 
		 * @param	direction	滑动方向。有效值[1, 2, 3]。
		 * @param	viewRect	视窗尺寸。
		 * 
		 * @see com.pcup.display.Slip#DIRECTION_HORIZONTAL
		 * @see com.pcup.display.Slip#DIRECTION_VERTICAL
		 * @see com.pcup.display.Slip#DIRECTION_AUTO
		 */
		public function Slip(direction:uint, viewRect:Rectangle) 
		{
			_direction = direction;
			_viewRect = viewRect;
			
			// 初始化参数
			_m0 = new Point();
			_m1 = new Point();
			_c0 = new Point();
			_c1 = new Point();
			_speed = new Point();
			_scrollRect = new Rectangle();
			_barMaxPosition = new Point();
			
			// 遮罩
			mask = new Bitmap(new BitmapData(_viewRect.width, _viewRect.height));
			super.addChild(mask);
			
			// 放一个填充对象, 防止点到空白时无法拖动
			super.addChild(new Bitmap(new BitmapData(_viewRect.width, _viewRect.height, true, 0)));
			
			// 内容容器
			_content = new Sprite();
			super.addChild(_content);
			
			// 设置状态
			this.direction = _direction;	// 方向
			this.barEnable = _barEnable;	// 是否使用滚动条
			this.barWidth  = _barWidth;		// 滚动条宽度
			
			// 开始拖动
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
		}
		
		// MOUSE_DOWN
		private function mouseDownHandler(e:MouseEvent):void 
		{
			removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			stage.addEventListener(MouseEvent.ROLL_OUT, mouseUpHandler);
			
			// 重置参数
			_speed.x = 0;
			_speed.y = 0;
			_isDragging = false;
			_path = new Vector.<PathPoint>();
			
			// 记录鼠标按下时的坐标
			_m0.x = e.stageX;
			_m0.y = e.stageY;
		}
		// MOUSE_MOVE
		private function mouseMoveHandler(e:MouseEvent):void 
		{
			// 禁止内容鼠标事件, 这样就内容就可以通过监听 MouseEvent.CLICK 事件来实现单击, 否则拖动后也会造成单击
			_content.mouseChildren = false;
			
			// 临时存储, 提高后面读取此数据的效率
			_m1.x = e.stageX;
			_m1.y = e.stageY;
			
			// 还没开始拖动
			if (!_isDragging)
			{
				// 是否满足拖动条件(拖动距离大于5象素时才开始拖动, 以此防止误操作, 也防止了内容单击过于敏感的问题)
				if (_isX && Math.abs(_m1.x - _m0.x) > 5
					||
					_isY && Math.abs(_m1.y - _m0.y) > 5)
				{
					_isDragging = true;
					
					// 更新鼠标位置
					_m0.x = _m1.x;
					_m0.y = _m1.y;
					
					// 记录内容位置
					_c0.x = _c1.x = _content.x;
					_c0.y = _c1.y = _content.y;
					
					// 清除滚动条隐藏延时
					clearTimeout(_barIntervalId);
					// 显示滚动条
					if (_hBar) _hBar.visible = true;
					if (_vBar) _vBar.visible = true;
				}
			}
			
			// 正在拖动
			if (_isDragging)
			{
				// 存储路径点
				_path.push(new PathPoint(_m1.x, _m1.y, getTimer()));
				
				// 计算内容当前位置
				_c1.x = _c0.x + (_m1.x - _m0.x);
				_c1.y = _c0.y + (_m1.y - _m0.y);
				
				// 溢出时拖动距离损失一半(内容可完全显示 || 左端溢出 || 右端溢出)
				if (_scrollRect.x > 0 || _c1.x > 0 || _c1.x < _scrollRect.x)
				{
					_c1.x -= (_c1.x - _c0.x) / 2;
				}
				if (_scrollRect.y > 0 || _c1.y > 0 || _c1.y < _scrollRect.y)
				{
					_c1.y -= (_c1.y - _c0.y) / 2;
				}
				
				// 更新
				update();
			}
		}
		// MOUSE_UP
		private function mouseUpHandler(e:MouseEvent):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			stage.removeEventListener(MouseEvent.ROLL_OUT, mouseUpHandler);
			
			// 恢复内容鼠标事件
			_content.mouseChildren = true;
			
			// 移除旧路径点
			removeOldPathPoint(getTimer());
			
			// 至少两个点才进行计算
			if (_path.length > 1)
			{
				// 临时存储 _path 中的第一个点和最后一个点
				var p0:PathPoint = _path[0];
				var p1:PathPoint = _path[(_path.length - 1)];
				
				// 总时长
				var totalTime:Number = (p1.t - p0.t) / 15;	// 为什么除15???
				
				// 计算速度
				if (_isX) _speed.x = (p1.x - p0.x) / totalTime;
				if (_isY) _speed.y = (p1.y - p0.y) / totalTime;
			}
			
			// 开始惯性运动
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		// ENTER_FRAME
		private function enterFrameHandler(e:Event):void 
		{
			// 更新位置
			_c1.x += _speed.x;
			_c1.y += _speed.y;
			
			// 减速(速度衰减存活率取0.95)
			_speed.x *= 0.95;
			_speed.y *= 0.95;
			
			// 溢出
			overflow();
			
			// 更新
			update();
		}
		
		
		/** 处理溢出(溢出即内容出现在非法停靠位置时) */
		private function overflow():void
		{
			// 溢出量
			var overX:Number = 0;
			var overY:Number = 0;
			
			if (_isX)
			{
				/**
				 * 内容可完全显示时, 随便怎么拖都是溢出.
				 * 本可用`_content.width < _viewRect.width`, 但不如`_scrollRect.x > 0`效率高.
				 */ 
				if (_content.width < _viewRect.width)	
				{
					overX = _c1.x;
				}
				// 内容超出显示范围
				else
				{
					// 左端溢出(向右拖)
					if (_c1.x > 0)
					{
						overX = _c1.x;
					}
					// 右端溢出(向左拖)
					else if (_c1.x < _scrollRect.x)
					{
						overX = _c1.x - _scrollRect.x;
					}
				}
				
				/**
				 * 溢出
				 * 情况一: 溢出量增大时, 溢出量 * 速度 > 0
				 * 情况二: 溢出量减小时, 溢出量 * 速度 < 0
				 */ 
				if (overX != 0)
				{
					if (overX * _speed.x > 0)
					{
						_speed.x -= overX * 0.08;	// 这个是从原速度过渡, 故用速度与溢出量做运算
					}
					else
					{
						_speed.x = -overX * 0.15;	// 回到边缘就停住, 故取溢出量的比例值
					}
				}
			}
			if (_isY)
			{
				if (_content.height < _viewRect.height)
				{
					overY = _c1.y;
				}
				else
				{
					if (_c1.y > 0)
					{
						overY = _c1.y;
					}
					else if (_c1.y < _scrollRect.y)
					{
						overY = _c1.y - _scrollRect.y;
					}
				}
				
				if (overY != 0)
				{
					if (overY * _speed.y > 0)
					{
						_speed.y -= overY * 0.08;
					}
					else
					{
						_speed.y = -overY * 0.15;
					}
				}
			}
			
			/**
			 * 没有溢出，且速度太小. 
			 * 
			 * 溢出量说明:
			 * 经测试, 取 1 作为比较值.
			 * 
			 * 速度说明:
			 * 为了提高效率没有做开方运算, 换以用最小速度的平方值来做比较.
			 * 比如最小速度为 0.5, 那么就用 0.25 (0.5的平方)来做比较.
			 * 经测试, 取 0.5 作为比较值.
			 * 
			 * 比较值说明:
			 * 溢出量和速度的比较值, 过小时会出现速度很慢内容移动起来像是在跳动, 过大时内容会停止得很突兀.
			 */
			if (overX * overX < 1 &&
				overY * overY < 1 &&
				_speed.x * _speed.x + _speed.y * _speed.y < 0.25)
			{
				removeEventListener(Event.ENTER_FRAME, enterFrameHandler);
				
				// 延迟隐藏滚动条(300毫秒)
				clearTimeout(_barIntervalId);
				_barIntervalId = setTimeout(hideBar, 300);
				
				// 对齐边缘
					 if ( _c1.x					 *  _c1.x				   < 1) _c1.x = 0;
				else if ((_c1.x - _scrollRect.x) * (_c1.x - _scrollRect.x) < 1) _c1.x = _scrollRect.x;
					 if ( _c1.y					 *  _c1.y				   < 1) _c1.y = 0;
				else if ((_c1.y - _scrollRect.y) * (_c1.y - _scrollRect.y) < 1) _c1.y = _scrollRect.y;
			}
		}
		
		/** 更新 */
		private function update():void 
		{
			updatePosition();
			updateBar();
		}
		/** 更新内容位置 */
		private function updatePosition():void 
		{
			if (_isX) _content.x = _c1.x;
			if (_isY) _content.y = _c1.y;
		}
		/** 更新滚动条*/
		private function updateBar():void 
		{
			if (!_barEnable) return;
			
			var L:Number;	// 滚动条长度
			var P:Number;	// 滚动条位置
			
			if (_isX)
			{
				// 清除旧图
				_hBar.graphics.clear();
				
				// 内容超出显示范围
				if (_content.width > _viewRect.width)
				{
					// 左端溢出
					if (_c1.x > 0)
					{
						L = _viewRect.width * _viewRect.width / (_content.x + _content.width);		if (L < _barWidth) L = _barWidth;
						P = 0;
					}
					// 右端溢出
					else if (_c1.x < _scrollRect.x)
					{
						L = _viewRect.width * _viewRect.width / ( -_content.x + _viewRect.width);	if (L < _barWidth) L = _barWidth;
						P = _viewRect.width - L;
					}
					// 无溢出, 即常规情况
					else
					{
						L = _viewRect.width * _viewRect.width / _content.width;						if (L < _barWidth) L = _barWidth;
						P = _viewRect.width * -_content.x	  / _content.width;
						
						// 防止: 滚动条长度小于其宽度时, 当滚动条滚动至右端时会跑出视窗
						if (P > _barMaxPosition.x) P = _barMaxPosition.x;
					}
					
					// 绘制新图
					_hBar.graphics.beginFill(0, 0.5);
					_hBar.graphics.drawRoundRect(0, 0, L, _barWidth, _barWidth, _barWidth);
					_hBar.graphics.endFill();
					
					// 定位
					_hBar.x = P;
				}
			}
			if (_isY)
			{
				_vBar.graphics.clear();
				
				if (_content.height > _viewRect.height)
				{
					if (_c1.y > 0)
					{
						L = _viewRect.height * _viewRect.height / (_content.y + _content.height);		if (L < _barWidth) L = _barWidth;
						P = 0;
					}
					else if (_c1.y < _scrollRect.y)
					{
						L = _viewRect.height * _viewRect.height / ( -_content.y + _viewRect.height);	if (L < _barWidth) L = _barWidth;
						P = _viewRect.height - L;
					}
					else
					{
						L = _viewRect.height * _viewRect.height / _content.height;						if (L < _barWidth) L = _barWidth;
						P = _viewRect.height * -_content.y		/ _content.height;
						
						if (P > _barMaxPosition.y) P = _barMaxPosition.y;
					}
					
					_vBar.graphics.beginFill(0, 0.5);
					_vBar.graphics.drawRoundRect(0, 0, _barWidth, L, _barWidth, _barWidth);
					_vBar.graphics.endFill();
					
					_vBar.y = P;
				}
			}
		}
		
		/** 重置滚动条 */
		private function resetBar():void
		{
			// 先全部删除
			if (_hBar) { _hBar.graphics.clear();	if (super.contains(_hBar)) super.removeChild(_hBar);	_hBar = null; }
			if (_vBar) { _vBar.graphics.clear();	if (super.contains(_vBar)) super.removeChild(_vBar);	_vBar = null; }
			
			// 再根据需要进行创建
			if (_barEnable)
			{
				if (_isX) { _hBar = new Shape();	super.addChild(_hBar);	_hBar.y = _viewRect.height - _barWidth - 2; }
				if (_isY) { _vBar = new Shape();	super.addChild(_vBar);	_vBar.x = _viewRect.width  - _barWidth - 2; }
			}
		}
		/** 隐藏滚动条 */
		private function hideBar():void
		{
			if (_hBar) _hBar.visible = false;
			if (_vBar) _vBar.visible = false;
		}
		
		
		/** 添加路径点 */
		private function addPathPoint(pathPoint:PathPoint):void
		{
			removeOldPathPoint(pathPoint.t);
			
			_path.push(pathPoint);
		}
		/**
		 * 整理路径. 删除100毫秒之前的点，只用100毫秒之内的点计算.
		 * @param	t	计算时间长度的基准时间点
		 */
		private function removeOldPathPoint(t:int):void
		{
			while (_path.length > 0)
			{
				if (t - _path[0].t < 101)
				{
					break;
				}
				_path.shift();
			}
		}
		
		
		
		/** _content 的 child 有更新 */
		private function updateContent():void 
		{
			// 更新滚动区域
			_scrollRect.x		= _viewRect.width  - _content.width;
			_scrollRect.y		= _viewRect.height - _content.height;
			_scrollRect.width	=					 _content.width;
			_scrollRect.height	=					 _content.height;
			
			// 开始惯性运动(防止滚动区域小于视窗时没有对齐)
			addEventListener(Event.ENTER_FRAME, enterFrameHandler);
		}
		override public function addChild(child:DisplayObject):DisplayObject {
			var obj:DisplayObject = _content.addChild(child);
			updateContent();
			return obj;
		}
		override public function addChildAt(child:DisplayObject, index:int):DisplayObject {
			var obj:DisplayObject = _content.addChildAt(child, index);
			updateContent();
			return obj;
		}
		override public function getChildAt(index:int):DisplayObject {
			var obj:DisplayObject = _content.getChildAt(index);
			updateContent();
			return obj;
		}
		override public function getChildByName(name:String):DisplayObject {
			var obj:DisplayObject = _content.getChildByName(name);
			updateContent();
			return obj;
		}
		override public function getChildIndex(child:DisplayObject):int {
			var obj:int = _content.getChildIndex(child);
			updateContent();
			return obj;
		}
		override public function removeChild(child:DisplayObject):DisplayObject {
			var obj:DisplayObject = _content.removeChild(child);
			updateContent();
			return obj;
		}
		override public function removeChildAt(index:int):DisplayObject {
			var obj:DisplayObject = _content.removeChildAt(index);
			updateContent();
			return obj;
		}
		/**
		 * @playerversion	AIR 3.0
		 * @playerversion	Flash 11
		 */
		/*override public function removeChildren(beginIndex:int = 0, endIndex:int = 2147483647):void {
			_content.removeChildren(beginIndex, endIndex);
			updateContent();
		}*/
		
		
		
		/**
		 * 滑动方向。
		 * @see com.pcup.display.Slip#DIRECTION_HORIZONTAL
		 * @see com.pcup.display.Slip#DIRECTION_VERTICAL
		 * @see com.pcup.display.Slip#DIRECTION_AUTO
		 */
		public function get direction():uint 
		{
			return _direction;
		}
		public function set direction(value:uint):void 
		{
			// 设置的值既不是水平也不是垂直时就置为任意方向
			_direction = (value != DIRECTION_HORIZONTAL && value != DIRECTION_VERTICAL) ? DIRECTION_AUTO : value;
			
			// 设置方向标记
			_isX = Boolean(_direction & 1);
			_isY = Boolean(_direction & 2);
			
			// 重置滚动条
			resetBar();
		}
		/**
		 * 是否使用滚动条。
		 * @default true
		 */
		public function get barEnable():Boolean 
		{
			return _barEnable;
		}
		public function set barEnable(value:Boolean):void 
		{
			_barEnable = value;
			
			// 重置滚动条
			resetBar();
		}
		/**
		 * 滚动条宽度。
		 * @default	6
		 */
		public function get barWidth():uint 
		{
			return _barWidth;
		}
		public function set barWidth(value:uint):void 
		{
			// 做两次位操作是为了取大偶数, 因为宽度为奇数时画出的滚动条是虚的
			_barWidth = value >> 1 << 1;
			
			// 更新滚动条最大停靠位置
			_barMaxPosition.x = _viewRect.width  - _barWidth;
			_barMaxPosition.y = _viewRect.height - _barWidth;
		}
		
		
	}

}


/**
 * 舞台鼠标在某一时刻的位置
 */
class PathPoint
{
	/** x坐标 */	public var x:Number;
	/** y坐标 */	public var y:Number;
	/** 时间  */	public var t:int;
	
	public function PathPoint(x:Number, y:Number, t:int) 
	{
		this.x = x;
		this.y = y;
		this.t = t;
	}
}
