package 
{
	import com.pcup.*;
	import com.pcup.display.*;
	import com.pcup.loaders.*;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filters.BlurFilter;
	import flash.geom.Rectangle;
	import flash.text.TextField;
	import flash.text.TextFormat;
	
	/**
	 * 更新步骤：
	 * 1、About
	 * 2、"d:\Program Files\flex_sdk\bin\asdoc.exe" -doc-sources "e:\ph\GitHub\pcup\src" -main-title "pcup API Documentation" -output "e:\ph\GitHub\pcup\docs" -external-library-path "e:\ph\GitHub\pcup\lib\greensock.swc" "e:\ph\GitHub\pcup\lib\airglobal.swc" "e:\ph\GitHub\pcup\lib\as3corelib.swc"  -window-title "pcup API Documentation" -footer "kissyid@qq.com"
	 * 3、swc
	 * 
	 * @author PH
	 */
	public class Main extends Sprite 
	{
		
		
		
		public function Main():void 
		{
			trace("Here we go....");
// 底图
var bg:Bitmap = new Bitmap(new BitmapData(600, 400, true, 0xffffd7d7));
bg.x = bg.y = 50;
addChild(bg);

// Slip 对象
var slip:Slip = new Slip(Slip.DIRECTION_AUTO, new Rectangle(0, 0, 600, 400));
slip.x = bg.x;
slip.y = bg.y;
addChild(slip);

// 内容
var _content:Sprite = new Sprite();  
for (var i:int = 0; i < 30; i++)
{
	for (var j:int = 0; j < 30; j++)
	{
		var cube:Sprite = new Sprite();
		cube.graphics.beginFill(Math.random()*0xffffff);
		cube.graphics.drawRect(0, 0, 100, 100);
		cube.graphics.endFill();
		cube.name = "(" + i + "," + j + ")";
		cube.x = j * (cube.width + 10);
		cube.y = i * (cube.height + 10);
		var t:TextField = new TextField();
		t.mouseEnabled = false;
		t.text = cube.name;
		cube.addChild(t);
		_content.addChild(cube);
	}
}
slip.addChild(_content);

		}
		
		
		
		
		
		
		
	}
	
}