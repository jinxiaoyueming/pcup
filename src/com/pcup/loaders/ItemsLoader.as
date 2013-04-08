package com.pcup.loaders 
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	
	
	/**
	 * 所有项目加载完成时调度此事件。
	 * <p>加载的项目存储在 ItemsLoader.items 中（加载失败的项目以null占位）。</p>
	 * @eventType	com.pcup.loaders.ItemsLoader.COMPLETE
	 */
	[Event(name = "complete", type = "com.pcup.loaders.ItemsLoader")]
	/**
	 * 每个项目加载完成时都会调度此事件。
	 * <p>ItemsLoader.loadedQuantity 已加载完成的项目的数量。</p>
	 * @eventType	com.pcup.loaders.ItemsLoader.COMPLETE_ONE
	 */
	[Event(name = "completeOne", type = "com.pcup.loaders.ItemsLoader")]
	
	
	/**
	 * ItemsLoader 类是 PicturesLoader 和 TextsLoader 的父类。
	 * 
	 * @example	
a simple example.
<listing version="3.0">
var l:ItemsLoader = new PicturesLoader();
l.addEventListener(ItemsLoader.COMPLETE_ONE,  function (e:Event):void {
	var loadedQuantity:uint = (e.target as ItemsLoader).loadedQuantity;
});
l.addEventListener(ItemsLoader.COMPLETE, function (e:Event):void {
	trace("all load complete");
});
l.load(["a.png", "b.png"]);
</listing>
	 * 
	 * @author PH
	 */
	public class ItemsLoader extends EventDispatcher 
	{
		/** 定义 complete 事件对象的 type 属性值。 */
		public static const COMPLETE:String = "complete";
		/** 定义 completeOne 事件对象的 type 属性值。 */
		public static const COMPLETE_ONE:String = "completeOne";
		
		private var N:uint;					// 计数
		private var _items:Array;			// 加载完的项目按排序放在这个数组中
		private var _urls:Array;			// 所有项目的路径
		
		
		public function ItemsLoader():void
		{
		}
		
		/**
		 * 加载一组项目
		 * @param	urls	要加载的项目的路径。
		 */
		public function load(urls:Array):void 
		{
			if (urls == null || urls.length == 0) return;
			
			_urls = urls;
			_items = new Array;
			N = 0;
			
			loadOne(_urls[N]);
		}
		
		/**
		 * 加载一个项目（根据加载项目的不同对此方法进行重写）
		 * @param	url		要加载的项目的路径。
		 */ 
		protected function loadOne(url:*):void 
		{
		}
		// 一个项目加载完成
		protected function loadHandler(e:Event):void 
		{
			// 加载出错
			if (e.type == IOErrorEvent.IO_ERROR) 
			{
				_items.push(null);
				
				trace("[ItemsLoader][IO_ERROR]一个项目加载出错（已用null占位）：", _urls[N]);
			}
			// 加载成功
			else
			{
				_items.push(getLoadData(e));
				
				trace("[ItemsLoader]成功加载一个项目：", _urls[N]);
				
				dispatchEvent(new Event(ItemsLoader.COMPLETE_ONE));
			}
			
			N++;
			// 所有项目加载完成
			if (N == _urls.length)
			{
				trace("[ItemsLoader][ALL]所有项目加载完成。");
				
				dispatchEvent(new Event(ItemsLoader.COMPLETE));
			}
			// 继续加载下一个项目
			else
			{
				loadOne(_urls[N]);
			}
		}
		
		/** 获取加载事件中的项目（根据加载项目的不同对此方法进行重写） */
		protected function getLoadData(loadEvent:Event):* 
		{
		}
		
		/** 所有加载的项目 */
		public function get items():Array {
			return _items;
		}
		/** 已加载的项目的数量 */
		public function get loadedQuantity():uint {
			return N;
		}
		
		
		
	}

}