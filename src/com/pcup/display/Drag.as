package com.pcup.display 
{
    import com.greensock.TweenLite;
    import flash.display.Sprite;
    import flash.events.Event;
    import flash.events.MouseEvent;
    import flash.geom.Point;
    
    /** 单击(可拖动时用拖动距离判断, 不可拖动时用 MouseEvent.CLICK 判断) */
    [Event(name = "dragClick", type = "com.pcup.display.Drag")]
    /** 开始拖动 */
    [Event(name = "startDrag", type = "com.pcup.display.Drag")]
    /** 停止拖动 */
    [Event(name = "stopDrag" , type = "com.pcup.display.Drag")]
	
	/**
     * 可拖动的对象
     * @author ph
     */
    public class Drag extends Sprite 
    {
        static public const DRAG_CLICK:String = "dragClick";
        static public const START_DRAG:String = "startDrag";
        static public const STOP_DRAG :String = "stopDrag";
        
        /** 是否可拖动 */
        private var _allowDrag:Boolean;
        
		/** 鼠标位置(开始拖动时)*/	private var _m0:Point;
		/** 内容位置(开始拖动时)*/	private var _c0:Point;
        
		/** 是否正在作拖动操作 */
		private var _isDragging:Boolean;
        
        
        public function Drag() 
        {
            _m0 = new Point();
            _c0 = new Point();
            
            allowDrag = true;
        }
        
        
        private function downHandler(e:MouseEvent):void 
        {
            stage.addEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
            stage.addEventListener(MouseEvent.MOUSE_UP,   upHandler);
            stage.addEventListener(MouseEvent.ROLL_OUT,   upHandler);
            
			_isDragging = false;
            
            _m0.x = e.stageX;
            _m0.y = e.stageY;
			_c0.x = x;
			_c0.y = y;
        }
        private function moveHandler(e:MouseEvent):void 
        {
			// 还没开始拖动
			if (!_isDragging)
			{
				// 是否满足拖动条件(拖动距离大于5象素时才开始拖动, 以此防止误操作, 也防止了内容单击过于敏感的问题)
				if (Math.abs(e.stageX - _m0.x) > 5
                    ||
					Math.abs(e.stageY - _m0.y) > 5)
				{
					_isDragging = true;
                    dispatchEvent(new Event(Drag.START_DRAG));
					
					// 更新位置
					_m0.x = e.stageX;
					_m0.y = e.stageY;
					_c0.x = x;
					_c0.y = y;
				}
			}
			
			// 正在拖动
			if (_isDragging)
			{
				x = _c0.x + (e.stageX - _m0.x);
				y = _c0.y + (e.stageY - _m0.y);
			}
        }
        private function upHandler(e:MouseEvent):void 
        {
            stage.removeEventListener(MouseEvent.MOUSE_MOVE, moveHandler);
            stage.removeEventListener(MouseEvent.MOUSE_UP  , upHandler);
            stage.removeEventListener(MouseEvent.ROLL_OUT  , upHandler);
            
            // 停止拖动
            if (_isDragging)
            {
                dispatchEvent(new Event(Drag.STOP_DRAG)); 
            }
            
            // 没有移动就触发单击
            if (e.type == MouseEvent.MOUSE_UP && _c0.x == x && _c0.y == y)
            {
                dispatchEvent(new Event(Drag.DRAG_CLICK));
            }
        }
        private function clickHandler(e:MouseEvent):void 
        {
            if (!allowDrag) dispatchEvent(new Event(Drag.DRAG_CLICK));
        }
        
        
        /** 回到上一个位置 */
        public function backPreviousPlace():void
        {
            TweenLite.to(this, 0.5, { x:_c0.x, y:_c0.y } );
        }
        
        
        /**
         * 是否可拖动.
		 * @default	true
         */
        public function get allowDrag():Boolean 
        {
            return _allowDrag;
        }
        public function set allowDrag(value:Boolean):void 
        {
            _allowDrag = value;
            
            if (_allowDrag)
            {
                   addEventListener(MouseEvent.MOUSE_DOWN,  downHandler);
                removeEventListener(MouseEvent.CLICK     , clickHandler);
            } else {
                removeEventListener(MouseEvent.MOUSE_DOWN,  downHandler);
                   addEventListener(MouseEvent.CLICK     , clickHandler);
            }
        }
        
    }

}