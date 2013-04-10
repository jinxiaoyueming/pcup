package com.pcup.utils 
{
	import flash.display.Stage;
	import flash.events.KeyboardEvent;
	import flash.text.TextField;
	import flash.ui.Keyboard;
	
	/**
	 * Dbg 类用于在舞台上显示调试信息。
	 * 
	 * <p>
	 * 在PC上可以有以下键盘控制：
	 * <li>空格键：切换调试信息的visible属性。</li>
	 * <li>V键：切换调试信息的mouseEnabled属性。</li>
	 * <li>X键：清空调试信息。</li>
	 * </p>
	 * 
	 * <p>在移动设备上没有键盘控制，就在初始化时禁用鼠标事件（相当于PC上V键的功能）。这样可以在显示调试信息的情况下操作程序。</p>
	 * 
	 * @author PH
	 */
	public class Dbg 
	{
		static private var txt:TextField;		// 显示调试信息的文本
		static private var DBG_ABLE:Boolean;	// 是否显示调试信息
		
		
		public function Dbg() 
		{
			throw new Error("[Dbg][错]单例。");
		}
		
		
		/**
		 * 初始化。
		 * @param	stg	舞台对象，调试信息是直接放在添加在舞台的显示列表中。
		 * @param	dbgAble	是否显示调试信息。
		 * @param	mouseAble	是否允许鼠标事件。
		 */
		static public function init(stg:Stage, dbgAble:Boolean, mouseAble:Boolean):void 
		{
			DBG_ABLE = dbgAble;
			
			if (DBG_ABLE)
			{
				txt = new TextField();
				txt.mouseEnabled = mouseAble;
				txt.width = stg.stageWidth;
				txt.height = stg.stageHeight;
				txt.alpha = 0.7;
				txt.background = true;
				txt.backgroundColor = 0xffffff;
				txt.wordWrap = true;
				txt.text = "---------------- 调 试 信 息 ----------------\n";
				
				stg.addChild(txt);
				stg.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			}
		}
		
		// 控制状态
		static private function keyDown(e:KeyboardEvent):void 
		{
			if (e.keyCode == Keyboard.SPACE) 
			{
				txt.visible = !txt.visible;
			}
			else if (e.keyCode == Keyboard.V) 
			{
				if (txt.mouseEnabled)
				{
					txt.alpha = 0.3;
					txt.mouseEnabled = false;
				}
				else
				{
					txt.alpha = 0.7;
					txt.mouseEnabled = true;
				}
			}
			else if (e.keyCode == Keyboard.X) 
			{
				txt.text = "---------------- 调 试 信 息 ----------------\n";
			}
		}
		
		
		/**
		 * 显示调试信息。
		 * @param	...rest	要显示的信息。
		 */
		static public function add(...rest):void
		{
			if (DBG_ABLE)
			{
				var content:String = "";
				for each (var item:* in rest) 
				{
					content += String(item) + " ";
				}
				txt.appendText(content + "\n");
				
				txt.scrollV = txt.maxScrollV;
			}
		}
	}

}