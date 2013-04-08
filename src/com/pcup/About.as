package com.pcup 
{
	/**
	 * About.
	 * 
	 * @author PH
	 */
	public class About 
	{
		/** Author. */
		static public const author:String = "ph";
		/** Author E-mail. */
		static public const email:String = "kissyid@qq.com";
		
		/** Version */
		static public const version:String = "？？？";
		/** History */
		static public const history:String = <![CDATA[
???
* 删除了LoadPic类，添加了ImagesLoader和TextsLoader。
* 删除了PHEvent和其它自定义的事件类，把事件的定义都放在相应的类中，不单独定义事件类。
* 类名更改：PHArray / ArrayUtil，RotScaSpr / Twotouch。
* 调整：DragSelect类在为selectIndex属性赋值时抛出SELECT事件。
* 增加CheckBox(复选框)和Radio(单选按钮组)类。
* 增加Panel类。
* 增加DateUtil类。
* 增加FontUtil类。

20121203161239
* 优化RotScaSpr类。

20121126172553
* RotScaSpr类的双击算法改为用触摸事件来写。
* 修复RotScaSpr类有多个不同位置的子显示对象时拖动异常的BUG。
* 增加RotScaSprEvent事件类，RotScaSpr类不再调用PHEvent事件类。
* 修复Btn类的按钮素材为可接收事件的显示对象时无法调度MouseEvent.CLICK事件的BUG。
* Btn类改为Button类。
* 增加ButtonEvent事件类。

12.11.02.18.53.05
* 添加PictureWheel类即其事件类。
* 包结构调整。

12.07.24.15.47.28
* DragSpr增加鼠标滚轮滚动页面的功能。

12.07.12.13.59.35
* Btn类增加activePlus属性，用以优化拖动逻辑。

12.06.25.15.57.15
* 删除Label类。
* 增强Btn类。实现了原Label类的功能；添加了拖动判断的功能（通过PHEvent.DRAG_OUT事件）。
* Btn的包路径修改。

12.06.19.10.50.25
* DragSpr类：修复垂直拖动时不显示滚动条的BUG。

12.05.13.11.30.09
* 源码目录从lib转移到src。
* Btn类、Label类：A、B改为p0、p1，构造方法增加_mouseChildren参数。
* 增加PHArray函数类。
* 去掉ABCSort类，其中的方法转移到了PHArray中。
* 整理事件。用事件传递参数。
* PH类增加版本历史。

12.05.04.01.00.16
* 添加Cookie类。
* 编译环境改为AIR3.2。
]]>;

		
		
	}

}