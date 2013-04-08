package com.pcup.loaders 
{
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.IOErrorEvent;
	import flash.net.URLRequest;
	
	
	/**
	 * 所有图片加载完成时调度此事件。
	 * <p>加载的图片存储在 PicturesLoader.items 中（加载失败的图片以null占位）。</p>
	 * @eventType	com.pcup.loaders.ItemsLoader.COMPLETE
	 */
	[Event(name = "complete", type = "com.pcup.loaders.ItemsLoader")]
	/**
	 * 每个图片加载完成时都会调度此事件。
	 * <p>PicturesLoader.loadedQuantity 已加载完成的图片的数量。</p>
	 * @eventType	com.pcup.loaders.ItemsLoader.COMPLETE_ONE
	 */
	[Event(name = "completeOne", type = "com.pcup.loaders.ItemsLoader")]
	
	
	/**
	 * PicturesLoader 类可以按顺序加载一组图片（加载失败的项目以null占位）。
	 * 
	 * @author ph
	 */
	public class PicturesLoader extends ItemsLoader 
	{
		
		/**
		 * 
		 * @param	urls	要加载的图片路径。
		 */
		public function PicturesLoader(urls:Array = null) 
		{
			load(urls);
		}
		
		/**
		 * 加载一个图片
		 * @param	url		要加载的图片的路径。
		 */ 
		override protected function loadOne(url:*):void 
		{
			var loader:Loader = new Loader();
			loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, loadHandler);
			loader.contentLoaderInfo.addEventListener(Event.COMPLETE, loadHandler);
			
			loader.load(new URLRequest(String(url)));
		}
		
		/** 获取加载事件中的图片 */
		override protected function getLoadData(loadEvent:Event):* 
		{
			return loadEvent.target.content;
		}
		
	}

}