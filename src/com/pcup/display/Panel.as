package com.pcup.display 
{
	import com.greensock.TweenLite;
	import flash.display.Sprite;
	import flash.display.Stage;
	import flash.events.EventDispatcher;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	
	/**
	 * 视图面板父类(用于项目)
	 * 
	 * @author ph
	 */
	public class Panel extends Sprite 
	{
		/** 舞台			*/	static public var stg:Stage;
		/** 应用视窗尺寸	*/	static public var appView:Rectangle;
		/** 单击热区透明度	*/	static public var hotAreaAlpha:Number = 0;
		
		
		
		/** 重置。回到初始状态 */
		public function reset():void
		{
		}
		/** 移入 */
		public function moveIn():void
		{
			this.visible = true;
		}
		/** 移出 */
		public function moveOut():void
		{
			this.visible = false;
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