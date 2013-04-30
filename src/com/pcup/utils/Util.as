package com.pcup.utils 
{
	import com.adobe.serialization.json.JSON;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.IBitmapDrawable;
	import flash.geom.Matrix;
	import flash.geom.Rectangle;
	/**
	 * 一些不好归类就放在这里。
	 * 
	 * @author ph
	 */
	public class Util 
	{
		/**
		 * 将任意对象转换为指定类型的对象。
		 * <p>[要求]目标对象可添加动态属性, 或者目标对象已经声明所有要添加的属性</p>
		 * <p>如果转换出错则返回Error对象</p>
		 * @param	object		原始对象
		 * @param	UserObject	目标对象[类]
		 * @return				指定类型的对象（as一下再用），如果转换出错则返回Error对象。
		 */
		static public function formatObject(object:Object, UserObject:Class):Object
		{
			if (!object) return new Error("原始对象为空！");
			
			// [注意]因为只能遍历对象的动态属性，所以要先转换为JSON对象，再转为目标对象。（JSON对象的属性为动态属性）
			var json:Object = com.adobe.serialization.json.JSON.decode(com.adobe.serialization.json.JSON.encode(object));
			
			// 目标对象
			var userObject:Object = new UserObject();
			
			try
			{
				for (var name:String in json) 
				{
					userObject[name] = json[name];
				}
			}
			catch (e:Error)
			{
				return e;
			}
			
			return userObject;
		}
		
		/**
		 * 将对象B的所有属性添加到对象A中。
		 * <p>[要求]对象A可添加动态属性, 或者对象A已经声明所有要添加的属性</p>
		 * <p>如果转换出错则返回Error对象</p>
		 * @param	objectA		被添加属性的对象
		 * @param	objectB		数据来源对象
		 * @param	prefix		前缀. 如果此参数不为空字符串(""), 则为每个添加的属性的属性名加上此前缀
		 * @return				添加好属性的 objectA 对象（as一下再用），如果转换出错则返回Error对象。
		 */
		static public function addPropertyToObject(objectA:Object, objectB:Object, prefix:String = ""):Object
		{
			if (!objectA || !objectB) return new Error("参数为空！");
			
			// [注意]因为只能遍历对象的动态属性，所以要先转换为JSON对象，再转为目标对象。（JSON对象的属性为动态属性）
			var json:Object = com.adobe.serialization.json.JSON.decode(com.adobe.serialization.json.JSON.encode(objectB));
			
			try
			{
				for (var name:String in json) 
				{
					objectA[prefix + name] = json[name];
				}
			}
			catch (e:Error)
			{
				return e;
			}
			
			return objectA;
		}
		
		
		/**
		 * 把显示对象的指定区域画为 Bitmap 对象。
		 * @param	source	源显示对象。
		 * @param	area	要画的区域。
		 * @return			画好的`Bitmap`对象。
		 */
		static public function draw(source:IBitmapDrawable, area:Rectangle):Bitmap
		{
			if (area.width <= 0 || area.height <= 0) 
				throw new Error("com.pcup.utils.Util.draw()::area宽高值不能小于零。");
			
			var bmd:BitmapData = new BitmapData(area.width, area.height, true, 0);
			bmd.draw(source, new Matrix(1, 0, 0, 1, -area.x, -area.y));
			return new Bitmap(bmd);
		}
		
	}

}