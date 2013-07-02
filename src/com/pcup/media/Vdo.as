package com.pcup.media 
{
	import flash.display.Sprite;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import flash.events.ErrorEvent;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.NetStatusEvent;
    import flash.events.SecurityErrorEvent;
    import flash.geom.Rectangle;
    import flash.media.SoundTransform;
    import flash.media.Video;
    import flash.net.NetConnection;
    import flash.net.NetStream;
    
    
    /** 出现错误 */
    [Event(name = "error", type = "flash.events.ErrorEvent")]
    /** 已获取到视频描述信息. 可通过 Vdo.duration 获取视频时长(单位:秒) */
    [Event(name = "metaData", type = "com.pcup.media.Vdo")]
    
	
	/**
     * 视频播放器
     * 
	 * 下面是一个简单的使用示例。
<listing version="3.0">
var v:Vdo = new Vdo(600, 400);
addChild(v);
v.addEventListener(ErrorEvent.ERROR, trace);
v.addEventListener(Vdo.META_DATA, onMeta);
v.open("d:/video/Alizee-La isla bonita.flv");

stage.addEventListener(KeyboardEvent.KEY_DOWN, onDown);

private function onDown(e:KeyboardEvent):void 
{
    switch (e.keyCode) 
    {
        case Keyboard.SPACE:
            v.togglePause();
        break;
        case Keyboard.LEFT:
            v.seek(v.time - 5);
        break;
        case Keyboard.RIGHT:
            v.seek(v.time + 5);
        break;
        case Keyboard.A:
            v.seek(10);
        break;
        default:
    }
}
private function onMeta(e:Event):void 
{
    trace("视频时长:" + v.duration);
}
</listing>
     * 
     * 
     * @author ph
     */
    public class Vdo extends Sprite 
    {
        static public const META_DATA:String = "metaData";
        
        private var video:Video;
		private var netConnection:NetConnection;
		private var netStream:NetStream;
        
        /** 本模块显示区域. 视频未填充到的地方用黑色填充. 仅取宽高两个参数 */
        private var vdoRect:Rectangle;
        /** 视频时长(单位:秒) */
        private var _duration:Number = 0;
        /** 视频路径 */
        private var url:String;
        
        
        /**
         * 创建一个新的 Vdo 实例
         * @param  width    本模块显示区域宽度
         * @param  height   本模块显示区域高度
         */
        public function Vdo(width:int = 320, height:int = 240) 
        {
            vdoRect = new Rectangle(0, 0, width, height);
            
            // 底
            addChild(new Bitmap(new BitmapData(vdoRect.width, vdoRect.height, false, 0xff000000)));
            
            // video
			video = new Video();
			video.smoothing = true;
			addChild(video);
			
			// 连接对象
			netConnection = new NetConnection();
			netConnection.client = new Object();
            netConnection.addEventListener(IOErrorEvent.IO_ERROR            , errorHandler);
            netConnection.addEventListener(SecurityErrorEvent.SECURITY_ERROR, errorHandler);
            netConnection.addEventListener(NetStatusEvent.NET_STATUS        , netStatusHandler);
            netConnection.connect(null);
        }
        
        /**
         * 打开视频
         * @param   url   视频地址
         */
        public function open(url:String):void
        {
            if (!netConnection.connected) dispError("还未连接视频服务");
            
            reset();
			
			// 播放新视频
			netStream = new NetStream(netConnection);
			netStream.client = new Object(); 
			netStream.client.onMetaData = onMetaData; 
            netStream.addEventListener(IOErrorEvent.IO_ERROR    , errorHandler);
			netStream.addEventListener(NetStatusEvent.NET_STATUS, netStatusHandler);
			video.attachNetStream(netStream);
			
            this.url = url;
			netStream.play(url);
		}
        
        
        /** 播放 */
        public function play():void
        {
            if (!checkReady()) return;
            
            netStream.resume();
        }
        /** 暂停 */
        public function pause():void
        {
            if (!checkReady()) return;
            
            netStream.pause();
        }
        /** 播放/暂停 */
        public function togglePause():void
        {
            if (!checkReady()) return;
            
            netStream.togglePause();
        }
        /** 停止 */
        public function stop():void
        {
            if (!checkReady()) return;
            
            netStream.seek(0);
            netStream.pause();
        }
        /**
         * 从指定时间点播放
         * @param   offset    播放起始时间点(单位:秒)
         */
        public function seek(offset:Number):void
        {
            if (!checkReady()) return;
            
                 if (offset < 0        ) offset = 0;
            else if (offset > _duration) offset = _duration;
            
            netStream.seek(offset);
        }
        /** 音量(音量值有效值:0~1) */
        public function get volume():Number
        {
            if (!checkReady()) return 1;
            return netStream.soundTransform.volume;
        }
        public function set volume(value:Number):void
        {
            if (!checkReady()) return;
            
                 if (value < 0) value = 0;
            else if (value > 1) value = 1;
            
            var st:SoundTransform = netStream.soundTransform;
            st.volume = value;
            netStream.soundTransform = st;
        }
        /** 当前播放位置 */
        public function get time():Number
        {
            if (!checkReady()) return 0;
            else               return netStream.time;
        }
        /** 视频总时长 */
        public function get duration():Number
        {
            return _duration;
        }
        /** 释放 NetStream 对象存放的所有资源 */
        public function dispose():void
        {
            if (netStream) netStream.dispose();
        }
        
        /**
         * 检查是否一切就绪
         * @return  一切就绪返回true, 否则返回false.
         */
        private function checkReady():Boolean 
        {
            if (!netConnection.connected)
            {
                dispError("还未连接视频服务");
                return false;
            }
            if (!netStream)
            {
                dispError("还未打开一个视频");
                return false;
            }
            
            return true;
        }
        /** 重置视频流 */
        private function reset():void 
        {
            // 释放当前流
			if (netStream)
			{
                netStream.dispose();
				netStream = null;
			}
            
            // 重置视频尺寸
            video.width  = vdoRect.width;
            video.height = vdoRect.height;
            
            // 重置视频时长
            _duration = 0;
        }
        
        
        /** 连接状态 */
        private function netStatusHandler(e:NetStatusEvent):void 
		{
            switch (e.info.code) 
			{
                case "NetStream.Play.Stop":
                    stop();
                break;
                case "NetConnection.Connect.Success":
                    
                break;
                case "NetConnection.Connect.Failed":
                case "NetConnection.Connect.Rejected":
					dispError("服务器连接失败");
                break;
				case "NetStream.Play.StreamNotFound":
					dispError("视频无效" + url);
                break;
            }
        }
        /**
         * 处理视频描述性信息
         * @param   info   视频描述性信息. 包含属性: 秒计时长(_duration), 宽度(width), 高度(height), 帧率(framerate).
         */
        public function onMetaData(info:Object):void 
		{
			//trace("metadata: _duration=" + info._duration + " width=" + info.width + " height=" + info.height + " framerate=" + info.framerate);
            
			// 如果未获取到视频描述性信息
			if (info._duration == 0 || info.width == 0 || info.height == 0) return;
            
            // 时长
            _duration = info.duration;
            
			// 比例控制
			if (info.width / info.height > vdoRect.width / vdoRect.height)
			{
				video.width  = vdoRect.width;
				video.height = video.width * (info.height / info.width);
			} else {
				video.height = vdoRect.height;
				video.width  = video.height * (info.width / info.height);
			}
            
			// 居中
			video.x = vdoRect.x + (vdoRect.width - video.width) / 2;
			video.y = vdoRect.y + (vdoRect.height - video.height) / 2;
            
            // 调度事件
            dispatchEvent(new Event(Vdo.META_DATA));
		}
        
        
        /** 错误处理 */
        private function errorHandler(e:ErrorEvent):void 
        {
            dispError(e.text);
        }
        /**
         * 抛出错误
         * @param  text  错误内容
         */
        private function dispError(text:String):void 
        {
            var e:ErrorEvent = new ErrorEvent(ErrorEvent.ERROR);
            e.text = text;
            dispatchEvent(e);
        }
        
    }

}