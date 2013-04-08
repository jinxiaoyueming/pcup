package com.pcup.loaders 
{
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	
	/**
	 * 所有文本加载完成时调度此事件。
	 * <p>加载的文本存储在 TextsLoader.items 中（加载失败的文本以null占位）。</p>
	 * @eventType	com.pcup.loaders.ItemsLoader.COMPLETE
	 */
	[Event(name = "complete", type = "com.pcup.loaders.ItemsLoader")]
	/**
	 * 每个文本加载完成时都会调度此事件。
	 * <p>TextsLoader.loadedQuantity 已加载完成的文本的数量。</p>
	 * @eventType	com.pcup.loaders.ItemsLoader.COMPLETE_ONE
	 */
	[Event(name = "completeOne", type = "com.pcup.loaders.ItemsLoader")]
	
	
	/**
	 * TextsLoader 类可以按顺序加载一组文本（加载失败的项目以null占位）。
	 * 
	 * @author ph
	 */
	public class TextsLoader extends ItemsLoader 
	{
		
		/**
		 * 
		 * @param	urls	要加载的文本路径。
		 */
		public function TextsLoader(urls:Array = null) 
		{
			load(urls);
		}
		
		/**
		 * 加载一个文本
		 * @param	url		要加载的文本的路径。
		 */ 
		override protected function loadOne(url:*):void 
		{
			var loader:URLLoader = new URLLoader();
			loader.addEventListener(IOErrorEvent.IO_ERROR, loadHandler);
			loader.addEventListener(Event.COMPLETE, loadHandler);
			
			loader.load(new URLRequest(String(url)));
		}
		
		/** 获取加载事件中的文本 */
		override protected function getLoadData(loadEvent:Event):* 
		{
			return loadEvent.target.data;
		}
		
	}

}