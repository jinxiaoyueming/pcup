package com.pcup.utils 
{
	
	/**
	 * ArrayUtil 类是一个与数组相关的函数类。
	 * 
	 * @author PH
	 */
	public class ArrayUtil 
	{
		
		/**
		 * 把数组按照中文字符拼音的打头字母26个字母分段排序。
		 * <p>被排序的数组可以是字符串数组，也可以是对象数组。对象数组将按照每个对象的一个指定属性来进行排序。</p>
		 * 
		 * <p>
		 * 注意：
		 * <li>本类需要 com.z.Chinese 类配合才能使用。</li>
		 * <li>返回的 Object 对象只有23个属性，因为“i”、“u”、“v”这三个字母打头的拼音。</li>
		 * </p>
		 * 
		 * @example	
示例一：下面的示例将直接以数组元素为排序值进行排序：
<listing version="3.0">
var a:Array = ["深圳", "重庆", "悉尼", "长岛", "北京", "纽约", "剑桥", "伦敦"];
var o:Object = ArrayUtil.abcSort(a);
trace(o.C[0]);	// 长岛
</listing>

示例二：下面的示例将以数组元素中的指定字段的值作为排序值进行排序：
<listing version="3.0">
var a:Array = new Array();
a.push( { city:"深圳", country:"中国" } );
a.push( { city:"重庆", country:"中国" } );
a.push( { city:"悉尼", country:"澳大利亚" } );
a.push( { city:"长岛", country:"日本" } );
a.push( { city:"北京", country:"中国" } );
a.push( { city:"纽约", country:"美国" } );
a.push( { city:"剑桥", country:"英国" } );
a.push( { city:"伦敦", country:"英国" } );
o = ArrayUtil.abcSort(a, "city");
trace(o.L[0].city, o.L[0].country);	// 伦敦 英国
</listing>
		 * 
		 * @param	arr	要排序的数组。
		 * @param	key	一个字符串，它标识要用作排序值的字段（对象数组时使用）。
		 * @return	一个 Object 对象。此对象有23个属性（即“A”、“B”...."Z"），即23个数组，每个数组对应该分段的结果。
		 */
		static public function abcSort(a:Array, key:String = null):Object 
		{
			// 用来为每个字母分段的中文参照字符（如“袄”，是A打头的拼音中按字母排序的最后一个）
			var cuts:Array = ["袄袄袄袄袄", 		/*		 0 : a 			*/
							  "不不不不不", 		/*		 1 : b 			*/
							  "错错错错错", 		/*		 2 : c 			*/
							  "多多多多多", 		/*		 3 : d 			*/
							  "饿饿饿饿饿", 		/*		 4 : e 			*/
							  "副副副副副", 		/*		 5 : f 			*/
							  "国国国国国", 		/*		 6 : g 			*/
							  "或或或或或", 		/*		 7 : h、i		*/
							  "句句句句句", 		/*		 8 : j 			*/
							  "阔阔阔阔阔", 		/*		 9 : k 			*/
							  "落落落落落", 		/*		10 : l 			*/
							  "木木木木木", 		/*		11 : m 			*/
							  "诺诺诺诺诺", 		/*		12 : n 			*/
							  "哦哦哦哦哦", 		/*		13 : o 			*/
							  "扑扑扑扑扑", 		/*		14 : p 			*/
							  "去去去去去", 		/*		15 : q 			*/
							  "若若若若若", 		/*		16 : r 			*/
							  "所所所所所", 		/*		17 : s 			*/
							  "拖拖拖拖拖", 		/*		18 : t、u、v 	*/
							  "无无无无无", 		/*		19 : w			*/
							  "许许许许许", 		/*		20 : x			*/
							  "与与与与与" 			/*		21 : y			*/
							  ];
			
			// 直接以数组元素为排序值进行排序
			if (key == null)
			{
				a = a.concat(cuts);															// 把定义的参照字符放入要排序的数组中
				a = Chinese.sort(a);														// 按拼音排序
			}
			// 以数组元素中的指定字段的值作为排序值进行排序
			else
			{
				// 把参照字符转换为具有指定字段的 Object 对象。这样才能用 Chinese 类进行排序。
				var tmpArr:Array = new Array();
				for each (var item:String in cuts) 
				{
					var tmpO:Object = new Object();
					tmpO[key] = item;
					
					tmpArr.push(tmpO);
				}
				cuts = tmpArr;
				
				a = a.concat(tmpArr);														// 把定义的参照字符放入要排序的数组中
				a = Chinese.sort(a, key);													// 用 key 字段的值来按拼音排序
			}
			
			
			
			// 分段后的数据放入此对象的一个属性（属性名称为对应分段的大家字母）中
			var o:Object = new Object();
			
			var k:uint = 0;
			for (var i:* in a) 																// 用 Array.slice() 方法时，已经过滤掉了我们的参照字符。
			{
					 if (a[i] == cuts[0])		{ o.A = a.slice(0, i);	 k = i + 1; }
				else if (a[i] == cuts[1])		{ o.B = a.slice(k, i);	 k = i + 1; }
				else if (a[i] == cuts[2])		{ o.C = a.slice(k, i);	 k = i + 1; }
				else if (a[i] == cuts[3])		{ o.D = a.slice(k, i);	 k = i + 1; }
				else if (a[i] == cuts[4])		{ o.E = a.slice(k, i);	 k = i + 1; }
				else if (a[i] == cuts[5])		{ o.F = a.slice(k, i);	 k = i + 1; }
				else if (a[i] == cuts[6])		{ o.G = a.slice(k, i);	 k = i + 1; }
				else if (a[i] == cuts[7])		{ o.H = a.slice(k, i);	 k = i + 1; }
				else if (a[i] == cuts[8])		{ o.J = a.slice(k, i);	 k = i + 1; }
				else if (a[i] == cuts[9])		{ o.K = a.slice(k, i);	 k = i + 1; }
				else if (a[i] == cuts[10])		{ o.L = a.slice(k, i);	 k = i + 1; }
				else if (a[i] == cuts[11])		{ o.M = a.slice(k, i);	 k = i + 1; }
				else if (a[i] == cuts[12])		{ o.N = a.slice(k, i);	 k = i + 1; }
				else if (a[i] == cuts[13])		{ o.O = a.slice(k, i);	 k = i + 1; }
				else if (a[i] == cuts[14])		{ o.P = a.slice(k, i);	 k = i + 1; }
				else if (a[i] == cuts[15])		{ o.Q = a.slice(k, i);	 k = i + 1; }
				else if (a[i] == cuts[16])		{ o.R = a.slice(k, i);	 k = i + 1; }
				else if (a[i] == cuts[17])		{ o.S = a.slice(k, i);	 k = i + 1; }
				else if (a[i] == cuts[18])		{ o.T = a.slice(k, i);	 k = i + 1; }
				else if (a[i] == cuts[19])		{ o.W = a.slice(k, i);	 k = i + 1; }
				else if (a[i] == cuts[20])		{ o.X = a.slice(k, i);	 k = i + 1; }
				else if (a[i] == cuts[21])		{ o.Y = a.slice(k, i);	 k = i + 1; }
				else if (i == (a.length - 1))	{ o.Z = a.slice(k, a.length); 		}
			}
			
			return o;
		} 
		
		
		/**
		 * 修正数组元素的间隔值。
		 * <p>这种修正是左对齐的。即最小值不变，其它值如果间距小于指定值就往后进行修正。例如下面的示例，因40-30=10小于20，则40会被修正为50，以保持和30的间隔为20。后面以此类推。</p>
		 * 
		 * @example	
示例：下面的示例将把数组中元素按间隔值为20进行修正（注意：因AS文档标准原因，请把下面Vector类后的中括号替换为尖括号）：
<listing version="3.0">
var arr:Vector.[Number] = Vector.[Number]([40, 30, 50, 60]);
trace(ArrayUtil.fixOffset(arr, 20).join());	// 50,30,70,90
</listing>
			
		 * @param	arr	要修正的数组。
		 * @param	inerval	需要修正的最大间隔值（如果间隔小于这个值就需要修正）。
		 * @param	allowOver	是否允许有相等的值（即间隔为0）。
		 * @return	修正后的数据。
		 */
		static public function fixOffset(arr:Vector.<Number>, inerval:uint, allowOver:Boolean = false):Vector.<Number>
		{
			// 备份原数据
			var arr0:Vector.<Number> = new Vector.<Number>();		
			for each (var item:Number in arr) 
			{
				arr0.push(item);
			}
			
			// 按大小排序
			arr.sort(Array.NUMERIC);
			
			// 把未排序时的索引存起来，以便排序后恢复。
			var position:Vector.<uint> = new Vector.<uint>(arr.length);
			for (var i:* in arr) 
			{
				for (var j:* in arr0) 
				{
					if (arr[i] == arr0[j])
					{
						position[i] = j;
						break;
					}
				}
			}
			
			// 修正
			for (i in arr) 
			{
				if (i == 0) continue;								// 最小的这个值不用修正。
				
				if (allowOver && arr[i] == arr[i - 1]) continue;	// 允许相等 且 相等 时，不用修正。
				
				if (arr[i] - arr[i - 1] < inerval) arr[i] = arr[i - 1] + inerval;
			}
			
			// 把修正后的数据恢复原来的顺序
			for (i in arr) 
			{
				arr0[position[i]] = arr[i];
			}
			
			// 返回修正后的数据
			return arr0;
		}
		
		
		/**
		 * 将任意对象转换为指定对象（当然，要属性一致才能得到正确的结果），如果转换出错则返回Error对象。
		 * @param	object		原始对象
		 * @param	UserObject	目标对象
		 * @return				返回目标对象（as一下再用），如果转换出错则返回Error对象。
		 */
		static public function formatObject(object:Object, UserObject:Class):Object
		{
			if (!object) return new Error("原始对象不能为空！");
			
			// [注意]因为只能遍历对象的动态属性，所以要先转换为JSON对象，再转为目标对象。（JSON对象的属性为动态属性）
			var json:Object = JSON.parse(JSON.stringify(object));
			
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
		
	}

}