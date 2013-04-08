package com.pcup.utils 
{
	/**
	 * 日期工具。
	 * 
	 * @author ph
	 */
	public class DateUtil 
	{
		/**
		 * 验证日期是否合法。
		 * @param	Y	年。
		 * @param	M	月。
		 * @param	D	日。
		 * @return	true表示合法，false表示非法。
		 */
		static public function legal(Y:int, M:int, D:int):Boolean 
		{
			if 
			(
				(
					M < 1 || M > 12
				)
				||
				(
					(M == 2) 
					&& 
					(D < 1 || D > ((Y % 4 == 0 ) ? 29 : 28))
				) 
				||
				(
					(M == 1 || M == 3  || M == 5  || M == 7  || M == 8  || M == 10  || M == 12) 
					&& 
					(D < 1 || D > 31)
				) 
				||
				(
					(M == 2 || M == 4 || M == 6 || M == 11) 
					&& 
					(D < 1 || D > 30)
				)
			)
			return false;
			
			return true;
		}
		
	}

}