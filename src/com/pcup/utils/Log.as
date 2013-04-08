package com.pcup.utils 
{
	import flash.display.Stage;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	/**
	 * Log 类用于写程序运行日志。日志文件是按天保存的，每天都会有一个独立的日志文件。
	 * 
	 * @author PH
	 */
	public class Log 
	{
		static private var f:File;															// 写文件用的
		static private var fs:FileStream;													// 写文件用的
		static private var date:Date;														// 获取日期时间用的
		
		static private var nowDate:String;													// String 类型的日期
		static private var nowTime:String;													// String 类型的时间
		
		
		public function Log() 
		{
			throw new Error("[Log][错]单例。");
		}
		
		/**
		 * 初始化。
		 * @param	stg	Stage对象，用来监听关窗窗口的事件。
		 * @param	url	日志存放位置（相对于程序安装目录）。
		 */
		static public function init(stg:Stage, url:String = "/log"):void 
		{
			fs = new FileStream();
			date = new Date();
			nowDate = date.fullYear + "-" + (date.month + 1) + "-" + date.date;
			
			// 判断当天的日志是否已经创建。没创建就创建，创建了就跳过。
			f = new File(File.applicationDirectory.nativePath + url + "/lastdate");
			if (f.exists)
			{
				fs.open(f, FileMode.READ);
				var oldDate:String = fs.readUTFBytes(fs.bytesAvailable);
				fs.close();
				
				if (nowDate != oldDate)
				{
					createNewLog();
				}
			}
			else
			{
				createNewLog();
			}
			
			// 打开当天的日志文件。
			f = new File(File.applicationDirectory.nativePath + url + "/" + nowDate);
			fs.open(f, FileMode.APPEND);
			add("program start.");
			
			
			stg.nativeWindow.addEventListener(Event.CLOSE, windowCloseHandler);
		}
		
		// 创建一个新日志文件。
		static private function createNewLog():void 
		{
			fs.open(f, FileMode.WRITE);
			fs.writeUTFBytes(nowDate);
			fs.close();
		}
		
		// 关闭窗口。
		static private function windowCloseHandler(e:Event):void 
		{
			add("program over.");
			fs.close();
		}
		
		
		/**
		 * 向日志中写入数据。
		 * @param	str	要写入的字符串。
		 * @param	...rest	要写入的字符串。
		 */
		static public function add(str:*, ...rest):void
		{
			// 先写入当前时间
			date = new Date();
			fs.writeUTFBytes(date.fullYear + "-" + (date.month + 1) + "-" + date.date + " " + date.hours + ":" + date.minutes + ":" + date.seconds + " > ");
			
			// 再写入指定数据
			fs.writeUTFBytes(String(str));
			for each (var item:* in rest) 
			{
				fs.writeUTFBytes(" " + String(item));
			}
			
			// 最后换行
			fs.writeUTFBytes("\n");
		}
	}

}