package com.pcup.project 
{
	import com.greensock.easing.Linear;
	import com.greensock.TweenLite;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	
	
	/** 需要提示时调度此事件 */
	[Event(name = "show", type = "com.pcup.project.TipEvent")]
	
	/**
	 * 视图面板父类
	 * 
	 * @author ph
	 */
	public class Panel extends Sprite 
	{
		/** 舞台			*/	static public var stg:Stage;
		/** 应用视窗宽		*/	static public var appWidth:uint;
		/** 应用视窗高		*/	static public var appHeight:uint;
		/** 单击热区透明度	*/	static public var hotAreaAlpha:Number = 0;
		
		
		/**
		 * 监听一组对象的 TipEvent 事件，并由 this 把此事件转抛出去。
		 * @param	list	需要转抛 TipEvent 事件的对象列表。
		 */
		protected function listTipEventDispatcher(list:Vector.<EventDispatcher>):void
		{
			for each (var item:EventDispatcher in list) 
			{
				item.addEventListener(TipEvent.SHOW, handleTipEvent);
			}
		}
		private function handleTipEvent(e:TipEvent):void {
			dispatchEvent(e);
		}
		
		
		
		/** 重置。回到初始状态 */
		public function reset():void
		{
		}
		/** 移入 */
		public function moveIn():void
		{
			this.x = appWidth;
			this.visible = true;
			TweenLite.to(this, 0.3, { x:0, ease:Linear.easeNone } );
		}
		/** 移出 */
		public function moveOut():void
		{
			TweenLite.to(this, 0.3, { x:-appWidth, onComplete:moveOutCompleteHandler, ease:Linear.easeNone } );
		}
		/** 移出完成后的操作 */
		protected function moveOutCompleteHandler():void {
			this.visible = false;
		}
		
		
		
		/**
		 * 创建一个单击热区
		 * @param	x		x坐标
		 * @param	y		y坐标
		 * @param	w		宽
		 * @param	h		高
		 * @param	name	热区name值
		 * @return
		 */
		protected function buildHotArea(x:int, y:int, w:uint, h:uint, name:String = null):Sprite
		{
			var s:Sprite = new Sprite();
			if (name) s.name = name;
			s.buttonMode = true;
			s.graphics.beginFill(0xff0000, hotAreaAlpha);
			s.graphics.drawRect(0, 0, w, h);
			s.graphics.endFill();
			s.x = x;
			s.y = y;
			addChild(s);
			s.addEventListener(MouseEvent.CLICK, handleHotArea);
			
			return s;
		}
		/** 热区的单击事件处理 */
		protected function handleHotArea(e:MouseEvent):void 
		{
		}
		
	}

}