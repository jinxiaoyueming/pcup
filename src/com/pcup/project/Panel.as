package com.pcup.project 
{
	import com.greensock.easing.Linear;
	import com.greensock.TweenLite;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.MouseEvent;
	
	/**
	 * 视图面板父类
	 * 
	 * @author ph
	 */
	public class Panel extends Sprite 
	{
		/** 舞台			*/	static public var stg:Stage;
		/** 应用视窗宽		*/	static public var viewWidth:uint;
		/** 应用视窗高		*/	static public var viewHeight:uint;
		/** 单击热区透明度	*/	static public var hotAreaAlpha:Number = 0;
		
		
		/** 状态重置 */
		public function reset():void
		{
		}
		
		/** 移入 */
		public function moveIn():void
		{
			this.x = viewWidth;
			this.visible = true;
			TweenLite.to(this, 0.3, { x:0, ease:Linear.easeNone } );
		}
		/** 移出 */
		public function moveOut():void
		{
			TweenLite.to(this, 0.3, { x:-viewWidth, onComplete:moveOutCompleteHandler, ease:Linear.easeNone } );
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
			s.addEventListener(MouseEvent.CLICK, clickHotAreaHanler);
			
			return s;
		}
		/** 热区的单击事件处理 */
		protected function clickHotAreaHanler(e:MouseEvent):void 
		{
		}
		
	}

}