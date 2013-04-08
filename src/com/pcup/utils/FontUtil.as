package com.pcup.utils 
{
	import com.pcup.display.DragSpr;
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
		 * @return
		 */
		static public function enumerateFonts(enumerateDeviceFonts:Boolean = false):DragSpr
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
				t.text = item.fontName + "_____ABC.abcd.123.测试";
				
				t.y = c.getChildAt(c.numChildren - 1).y + c.getChildAt(c.numChildren - 1).height;
				c.addChild(t);
			}
			
			// 底色
			c.graphics.beginFill(0xc0c0c0);
			c.graphics.drawRect(0, 0, c.width, c.height);
			c.graphics.endFill();
			
			// 拖动对象
			var d:DragSpr = new DragSpr(600, false);
			d.scrollBar = new ScrollBar(600, false);
			d.wheelEnabled = true;
			d.addSub(c);
			return d;
		}
		
	}

}