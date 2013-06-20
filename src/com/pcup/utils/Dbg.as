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
	 * <li>Ctrl+V: 切换调试信息的visible属性。</li>
	 * <li>Ctrl+M: 切换调试信息的mouseEnabled属性。</li>
	 * <li>Ctrl+C: 清空调试信息。</li>
	 * </p>
	 * 
	 * <p>在移动设备上没有键盘控制，就在初始化时禁用鼠标事件。这样可以在显示调试信息的情况下操作程序。</p>
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
		 * @param	stage		舞台对象，调试信息是直接放在添加在舞台的显示列表中。
		 * @param	dbgAble		是否显示调试信息。
		 * @param	mouseAble	是否允许鼠标事件。
		 */
		static public function init(stage:Stage, dbgAble:Boolean = true, mouseAble:Boolean = false):void 
		{
			DBG_ABLE = dbgAble;
			
			if (DBG_ABLE)
			{
				txt = new TextField();
				txt.mouseEnabled = mouseAble;
				txt.width = stage.stageWidth;
				txt.height = stage.stageHeight;
				txt.alpha = 0.7;
				txt.background = true;
				txt.backgroundColor = 0xffffff;
				txt.wordWrap = true;
				txt.text = "---------------- 调 试 信 息 ----------------\n";
				
				stage.addChild(txt);
				stage.addEventListener(KeyboardEvent.KEY_DOWN, keyDown);
			}
		}
		
		// 控制状态
		static private function keyDown(e:KeyboardEvent):void 
		{
            if (!e.ctrlKey) return;
            
            switch (e.keyCode) 
            {
                case Keyboard.V:
                    txt.visible = !txt.visible;
                break;
                case Keyboard.M:
                    txt.mouseEnabled = !txt.mouseEnabled;
                break;
                case Keyboard.C:
                    txt.text = "---------------- 调 试 信 息 ----------------\n";
                break;
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