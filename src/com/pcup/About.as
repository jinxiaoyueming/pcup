package com.pcup 
{
	/**
	 * About.
	 * 
	 * @author PH
	 */
	public class About 
	{
		/** 作者。 */
		static public const author :String = "kissyid";
		/** 作者邮箱。 */
		static public const email  :String = "kissyid@qq.com";
		/** 版本号。 */
		static public const version:String = "20130703021027";
		
		/** 更新历史。 */
		static public const history:String = <![CDATA[
20130703021027
    * +TCPCommunication类，封装TCP连接
    * +Vdo类，封装本地视频播放
    * 调整包结构
    * 优化调整：Util、Slip、Panel、TipEvent等类
20130621011930
    * Dbg类：优化快捷键。
20130523160211
	* 修改：Slip的滚动条默认宽度改为5象素。
	* 去除：Slip滚动条宽度时强制取偶数（泥马取奇数也没见虚啊）。
	* 优化：溢出时滚动条长度直接损失溢出量（仿苹果啊）。
	* 修复：开始拖动前是否已经溢出，未分开处理。导致拖动时出现抖动。
20130523131341
	* Slip的滚动条透明度改为0.5。
20130523115442
	* 修复：Slip内容过度溢出时滚动条长度小于其宽度的问题（再次修复）。
	* 修复：滚动条长度小于其宽度时, 当滚动条滚动至右端时会跑出视窗。
	* 设置滚动条宽度时强制取偶数。
20130523102701
	* 修复：Slip内容过度溢出时滚动条长度小于其宽度的问题。
20130523001921
	* ArrayUtil改名为ArrUtil，防止与AS3自带类重名。
	* ArrUtil增加match方法。
	* 增加MathUtil类.
	* 增加Slip类。删除DragSlip类, 删除ScrollBar类。
20130509102104
	* DragSelect调整.增加底图,效果优化.
	* 增加DataEvent类。
	* DragSpr改为DragSlip，并做了大量调整。
	* 修复ScrollBar中的bug，并画成了圆角。
	* 增加了Util类。用来存放不好归类的方法。
20130410115032
	* 所有三方包迁移到pcup包
20130408113419
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
