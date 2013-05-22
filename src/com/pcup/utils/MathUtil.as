package com.pcup.utils 
{
	/**
	 * 数学工具.
	 * 
	 * @author ph
	 */
	public class MathUtil 
	{
		/**
		 * 判断一个值是否属于指定域. 若不属于则取域相近的下界值或上界值.
		 * @param	num		匹配值
		 * @param	scope	匹配域. 只取前两个元素作为 Number 类型进行比较.
		 * @return			匹配后的值
		 */
		static public function matchScope(num:Number, scope:Array):Number
		{
				 if (num < scope[0])	return scope[0];
			else if (num > scope[1])	return scope[1];
			else						return num;
		}
		
	}

}