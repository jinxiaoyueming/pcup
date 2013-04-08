package com.pcup.utils 
{
	import flash.net.SharedObject;
	import flash.net.SharedObjectFlushStatus;
	
	/**
	 * Cookie 类可以读写沙箱中的数据。功能类似于Web的cookie。
	 * 
	 * @author PH
	 */
	public class Cookie 
	{
		static private var so:SharedObject;													// 读写数据的对象
		static private var name:String;														// 本程序存储数据时的标识
		static private var _data:Object;													// 存储的数据
		
		
		/**
		 * 初始化。
		 * @param	name	应用程序名称（作为提取数据的唯一标识）。
		 */
		static public function init(name:String):void
		{
			Cookie.name = name;
			so = SharedObject.getLocal(name, "/");
		}
		
		/**
		 * 清除 init() 方法初始化时用参数 name 作为标识所存储的数据。
		 */
		static public function clear():void
		{
			if (!name) 
			{
				trace("[Cookie]本模块还未初始化。使用 init() 方法初始化。");
				return;
			}
			
			so = SharedObject.getLocal(name, "/");
			so.clear();
		}
		
		
		/**
		 * 存储的数据。
		 * 
		 * <p>写本属性即是设置当前参数。</p>
		 */
		static public function get data():Object 
		{
			if (!name) 
			{
				trace("[Cookie]本模块还未初始化。使用 init() 方法初始化。");
				return null;
			}
			
			// 读出数据
			so = SharedObject.getLocal(name, "/");
			_data = so.data.cookie;
			
			return _data;
		}
		static public function set data(value:Object):void 
		{
			if (!name) 
			{
				trace("[Cookie]本模块还未初始化。使用 init() 方法初始化。");
				return;
			}
			
			// 写入数据
			so.data.cookie = value;
			var flushStatus:String = null;
			try 
			{
                flushStatus = so.flush();
            } 
			catch (e:Error) 
			{
                trace("[Cookie][错]写入失败。\n", e);
            }
			
			if (flushStatus == SharedObjectFlushStatus.PENDING) 
			{
				trace("[Cookie][错]写入失败。分配的空间量不足以存储该对象。");
            }
			else if (flushStatus == SharedObjectFlushStatus.FLUSHED) 
			{
				//trace("[Cookie]写入成功。");
            }
			
			_data = value;
		}
		
	}

}