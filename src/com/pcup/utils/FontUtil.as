package com.pcup.utils 
{
	import com.pcup.display.DragSlip;
	import com.pcup.display.ScrollBar;
	import flash.display.Sprite;
	import flash.text.Font;
	import flash.text.TextField;
	import flash.text.TextFieldAutoSize;
	import flash.text.TextFormat;
	/**
	 * 字体工具
	 * 
	 * @author ph
	 */
	public class FontUtil 
	{
		/**
		 * 枚举所有字体
		 * @param	enumerateDeviceFonts	是否枚举设备字体
		 * @param	chineseTest				测试内容中是否加入中文(因为有的字体加了中文就显示不正常，不知何故)
		 * @return
		 */
		static public function enumerateFonts(enumerateDeviceFonts:Boolean = false, chineseTest:Boolean = true):DragSlip
		{
			// 容器
			var c:Sprite = new Sprite();
			// 格式
			var f:TextFormat = new TextFormat(null, 24, null, null, null, null, null, null, null, null, null, null, 10);
			// 所有字体
			var fonts:Array = Font.enumerateFonts(enumerateDeviceFonts);
			
			// 字体数量
			var t:TextField = new TextField();
			t.autoSize = TextFieldAutoSize.LEFT;
			t.defaultTextFormat = f;
			t.text = "[字体数量:" + fonts.length + "]";
			c.addChild(t);
			
			// 生成
			for each (var item:Font in fonts) 
			{
				f.font = item.fontName;
				
				t = new TextField();
				t.autoSize = TextFieldAutoSize.LEFT;
				t.defaultTextFormat = f;
				t.text = item.fontName + "_____ABC.abcd.123" + (chineseTest ? ".测试" : "");
				
				t.y = c.getChildAt(c.numChildren - 1).y + c.getChildAt(c.numChildren - 1).height;
				c.addChild(t);
			}
			
			// 底色
			c.graphics.beginFill(0xFFD7D7);
			c.graphics.drawRect(0, 0, c.width, c.height);
			c.graphics.endFill();
			
			// 拖动对象
			var d:DragSlip = new DragSlip(false, 600);
			d.scrollBar = new ScrollBar(false, 600);
			d.wheelEnabled = true;
			d.addChild(c);
			return d;
		}
		
	}

}