package com.pcup.utils 
{
	import flash.events.GeolocationEvent;
	import flash.geom.Point;
	import flash.sensors.Geolocation;
	
	/**
	 * GPS类有两个功能：
	 * <li>可获取设备当前位置的经纬度。</li>
	 * <li>计算两点间的距离（单位：千米）。</li>
	 * 
	 * @author PH
	 */
	public class GPS 
	{
		static private var g:Geolocation;													// AIR传感器对象。
		static private var _position:Point;													// 当前的GPS位置。x为经度，y为纬度。
		
		
		/**
		 * 开始获取GPS数据。
		 * @param	requestedUpdateInterval	GPS数据更新的时间间隔（单位：毫秒，默认值：1000）。
		 */
		static public function start(requestedUpdateInterval:uint = 1000):void
		{
			// 当前设备不支持位置传感器。
			if (!Geolocation.isSupported) 
			{
				trace("[GPS]当前设备不支持位置传感器。");
			}
			else
			{
				g = new Geolocation();
				
				// 程序是否被允许对 Geolocation 的访问。
				if (g.muted)
				{
					trace("[GPS]程序被禁止对 Geolocation 的访问。");
				}
				else
				{
					g.setRequestedUpdateInterval(requestedUpdateInterval);
					g.addEventListener(GeolocationEvent.UPDATE, update);
				}
			}
		}
		/**
		 * 停止获取GPS数据。
		 */
		static public function stop():void
		{
			if (Geolocation.isSupported)
			{
				g.removeEventListener(GeolocationEvent.UPDATE, update);
				g = null;
			}
		}
		// 更新 _position 的值。
		static private function update(e:GeolocationEvent):void 
		{
			_position = new Point(e.longitude, e.latitude);
		}
		
		/**
		 * 当前位置的经纬度（x为经度，y为纬度）。
		 * 
		 * <p>
		 * 以下四种情况会返回 null 值：
		 * <li>当前设备不支持传感器。</li>
		 * <li>程序被禁止使用传感器（例如发布Android版本时没有在XML配置中添加GPS权限）。</li>
		 * <li>未开始获取（用 GPS.start() 方法开始获取）。</li>
		 * <li>未获取到GPS数据。</li>
		 * </p>
		 */
		static public function get position():Point 
		{
			// 当前设备不支持位置传感器。
			if (!Geolocation.isSupported) return null;
			
			if (!g) 
			{
				trace("[GPS]还未开始获取GPS数据。用 GPS.start() 方法开始获取。");
				return null;
			}
			else if (g.muted)
			{
				trace("[GPS]程序被禁止对 Geolocation 的访问。");
				return null;
			}
			else if (!_position)
			{
				trace("[GPS]还未获取到GPS数据。");
				return null;
			}
			else
			{
				return _position;
			}
		}
		
		
		
		
		/**
		 * 计算两点间的距离。
		 * 
		 * <p> 用两点的经纬度计算出它们之间的距离（单位: 千米），并返回此距离。</p>
		 * 
		 * @param	pA	A点坐标（x为经度, y为纬度）。
		 * @param	pB	B点坐标（x为经度, y为纬度）。
		 * @return	距离（单位：千米）。传入参数无效时返回 -1。
		 */
		static public function distance(pA:Point, pB:Point):Number
		{
			// 无效情况处理
			if (!(pA is Point) || !(pB is Point)) 
				return -1;
			if (Math.abs(pA.x) > 180 || Math.abs(pB.x) > 180 || Math.abs(pA.y) > 90 || Math.abs(pB.y) > 90) 
				return -1;
			
			// 计算并返回
			return 6378.137 * 2 * Math.asin(Math.sqrt(Math.pow(Math.sin((radians(pA.y) - radians(pB.y)) / 2), 2) + Math.cos(radians(pA.y)) * Math.cos(radians(pB.y)) * Math.pow(Math.sin((radians(pA.x) - radians(pB.x)) / 2), 2)));
		}
		// 角度转换为弧度
		static private function radians(angle:Number):Number
		{
			var tmp:Number = Math.PI / 180;
			return angle * tmp;
		}
		
		
		
		
		
	}

}