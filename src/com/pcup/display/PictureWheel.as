package com.pcup.display 
{
	import com.greensock.TweenLite;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.geom.Rectangle;
	
	/**
	 * Dispatch this event when click a image。
	 * <p>You can get the array index of the picture which be clicked by PictureWheel.clickIndex</p>
	 * @eventType	flash.events.Event.SELECT
	 */
	[Event(name = "select", type = "flash.events.Event")]
	
	/**
	 * Wheel effects of picture browsing.
	 * 
	 * @example	
a simple example.
<listing version="3.0">
[Embed(source = "../lib/embed/basemap.png")]
var EBasemap:Class;
[Embed(source = "../lib/embed/movie.png")]
var EMovie:Class;

var p:PictureWheel = new PictureWheel(
	Vector.《Bitmap》([new EMovie, new EMovie, new EMovie, new EMovie, new EMovie, new EMovie, new EMovie]), 
	new Rectangle(0, 0, 470, 270), 
	new EBasemap, 
	7,
	100,
	.7,
	.2,
	[new BlurFilter()]
);
p.pageDot = new PageDot(true);
addChild(p);
p.addEventListener(Event.SELECT, function(e:Event):void { trace(e.target.clickIndex); } );
</listing>
	 * 
	 * @see	com.pcup.display.PageDot
	 * 
	 * @author ph
	 */
	public class PictureWheel extends Sprite 
	{
		/** swap picture if the distance of mouse move larger than this value */
		private var _dragOffset:uint;
		/** size decay rate of the bigger picture to the smaller picture */
		private var _sizeDecay:Number;
		/** distance decay rate of the bigger picture to the smaller picture */
		private var _distanceDecay:Number;
		/** the filters of the side pictures */
		private var _filters:Array;
		/** there is a "PageDot" if this value is not null */
		private var _pageDot:PageDot;
		/** max quantity of display picture */
		private var _quantity:uint;
		/** display seven picture(value for "quantity" of PictureWheel constructor) */
		static public const QUANTITY_SEVEN	:uint = 7;
		/** display five picture(value for "quantity" of PictureWheel constructor) */
		static public const QUANTITY_FIVE	:uint = 5;
		/** display three picture(value for "quantity" of PictureWheel constructor) */
		static public const QUANTITY_THREE	:uint = 3;
		
		/** all picture */
		private var _pictures:Vector.<Sprite>;
		/** 被单击的图片在数组中的索引 */
		private var _clickIndex:uint;
		
		/** container of all picture */
		private var _pictureContainer:Sprite;
		/** the index of the middle picture in array */
		private var _currentIndex:int = -1;		// current index is the first from the bottom, because pictures will be swapped once at the beginning.
		/** the picture size that not be scaled */
		private var _pictureArea:Rectangle;
		/** the area of picture have taken up */
		private var _wheelArea:Rectangle;
		
		/** store "stageX" when mouse down */
		private var _downX:int;
		
		/**
		 * build a new PictureWheel
		 * @param	pictures		pictures
		 * @param	rect			the display area of the picture on the base map
		 * @param	baseMap			base map
		 * @param	quantity		max quantity of display(Tip: max is 5)
		 * @param	dragOffset		swap picture if the distance of mouse move larger than this value
		 * @param	sizeDecay		size decay rate of the bigger picture to the smaller picture
		 * @param	distanceDecay	distance decay rate of the bigger picture to the smaller picture
		 * @param	filters			filters of the side pictures
		 */
		public function PictureWheel(pictures:Vector.<Bitmap>, rect:Rectangle = null, baseMap:Bitmap = null, quantity:uint = PictureWheel.QUANTITY_FIVE, dragOffset:uint = 100, sizeDecay:Number = 0.8, distanceDecay:Number = 0.3, filters:Array = null) 
		{
			if (pictures.length == 0) throw new Error("Guys, NO Picture!!!");
			
			_pictures = standardPictures(pictures, rect, baseMap);
			_quantity = standardQuantity(quantity);
			_dragOffset = dragOffset;
			_sizeDecay = sizeDecay;
			_distanceDecay = distanceDecay;
			_filters = filters;
			
			_pictureArea = new Rectangle(0, 0, _pictures[0].width, _pictures[0].height);
			_wheelArea = getWheelArea();
			buildView();
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			
			// set the initial state
			swap(true);
		}
		private function buildView():void 
		{
			// picture container
			_pictureContainer = new Sprite();
			addChild(_pictureContainer);
			
			// pictures
			for each (var item:Sprite in _pictures) 
			{
				item.x = _wheelArea.width / 2;
				item.y = _wheelArea.height / 2;
				item.scaleX = item.scaleY = .1;
				item.alpha = 0;
				item.mouseEnabled = false;
				_pictureContainer.addChild(item);
				
				item.name = String(_pictures.indexOf(item));
				item.addEventListener(MouseEvent.CLICK, clickPictureHandler);
			}
			
		}
		
		// MOUSE_DOWN
		private function mouseDownHandler(e:MouseEvent):void 
		{
			stage.addEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			stage.addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			stage.addEventListener(MouseEvent.ROLL_OUT, mouseUpHandler);
			
			_downX = e.stageX;
		}
		// MOUSE_MOVE
		private function mouseMoveHandler(e:MouseEvent):void 
		{
			if (e.stageX - _downX > _dragOffset) 
			{
				mouseUpHandler();
				swap(false);
			}
			else if (e.stageX - _downX < -_dragOffset) 
			{
				mouseUpHandler();
				swap(true);
			}
		}
		// MOUSE_UP or ROLL_OUT
		private function mouseUpHandler(e:MouseEvent = null):void 
		{
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, mouseMoveHandler);
			stage.removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			stage.removeEventListener(MouseEvent.ROLL_OUT, mouseUpHandler);
		}
		
		// click the middle picture
		private function clickPictureHandler(e:MouseEvent):void 
		{
			_clickIndex = uint((e.currentTarget as Sprite).name);
			dispatchEvent(new Event(Event.SELECT));
		}
		
		/**
		 * swap picture
		 * @param	isNext	swap to next picture or not.
		 */
		public function swap(isNext:Boolean):void
		{
			// one picture width when scale is 1
			var W:uint = _pictures[0].width / _pictures[0].scaleX;
			
			// old picture whhich will been swapped out
			var distance:uint = (_quantity - 1) / 2;	// the distance of the middle picture to the old picture
			var oldIndex:uint = isNext ? correctIndex(_currentIndex - distance) : correctIndex(_currentIndex + distance);
			var oldPicture:Sprite = _pictures[oldIndex];
			var toX:int = _wheelArea.width / 2;
			var toScale:Number = .1;
			TweenLite.to(_pictures[oldIndex], 0.5, { alpha:0, x:toX, scaleX:toScale, scaleY:toScale } );
			
			// update current index
			_currentIndex = isNext ? correctIndex(_currentIndex + 1) : correctIndex(_currentIndex - 1);
			// update page dot
			if (_pageDot)_pageDot.update(_currentIndex);
			
			
			// ------------------------------------------ pictures size and scale ------------------------------------------
			// middle one
			var i:uint = _currentIndex;
			_pictureContainer.setChildIndex(_pictures[i], _pictures.length - 1);
			toX = _wheelArea.width / 2;
			toScale = 1;
			TweenLite.to(_pictures[i], 0.5, { alpha:1, x:toX, scaleX:toScale, scaleY:toScale } );
			_pictures[i].mouseEnabled = true;	// "mouseEnabled" of the middle picture is "true" only, other is "false".
			_pictures[i].filters = [];
			
			if (_quantity >= PictureWheel.QUANTITY_THREE)
			{
				// left-1
				i = correctIndex(_currentIndex - 1);
				_pictureContainer.setChildIndex(_pictures[i], _pictures.length - 2);
				toX = getX(-1);
				toScale = _sizeDecay;
				TweenLite.to(_pictures[i], 0.5, { alpha:1, x:toX, scaleX:toScale, scaleY:toScale } );
				_pictures[i].mouseEnabled = false;
				_pictures[i].filters = _filters;
				
				// right-1
				i = correctIndex(_currentIndex + 1);
				_pictureContainer.setChildIndex(_pictures[i], _pictures.length - 3);
				toX = getX(1);
				toScale = _sizeDecay;
				TweenLite.to(_pictures[i], 0.5, { alpha:1, x:toX, scaleX:toScale, scaleY:toScale } );
				_pictures[i].mouseEnabled = false;
				_pictures[i].filters = _filters;
				
				if (_quantity >= PictureWheel.QUANTITY_FIVE)
				{
					// left-2
					i = correctIndex(_currentIndex - 2);
					_pictureContainer.setChildIndex(_pictures[i], _pictures.length - 4);
					toX = getX(-2);
					toScale = _sizeDecay * _sizeDecay;
					TweenLite.to(_pictures[i], 0.5, { alpha:1, x:toX, scaleX:toScale, scaleY:toScale } );
					_pictures[i].mouseEnabled = false;
					_pictures[i].filters = _filters;
					
					// right-2
					i = correctIndex(_currentIndex + 2);
					_pictureContainer.setChildIndex(_pictures[i], _pictures.length - 5);
					toX = getX(2);
					toScale = _sizeDecay * _sizeDecay;
					TweenLite.to(_pictures[i], 0.5, { alpha:1, x:toX, scaleX:toScale, scaleY:toScale } );
					_pictures[i].mouseEnabled = false;
					_pictures[i].filters = _filters;
					
					if (_quantity >= PictureWheel.QUANTITY_SEVEN)
					{
						// left-3
						i = correctIndex(_currentIndex - 3);
						_pictureContainer.setChildIndex(_pictures[i], _pictures.length - 6);
						toX = getX(-3);
						toScale = _sizeDecay * _sizeDecay * _sizeDecay;
						TweenLite.to(_pictures[i], 0.5, { alpha:1, x:toX, scaleX:toScale, scaleY:toScale } );
						_pictures[i].mouseEnabled = false;
						_pictures[i].filters = _filters;
						
						// right-3
						i = correctIndex(_currentIndex + 3);
						_pictureContainer.setChildIndex(_pictures[i], _pictures.length - 7);
						toX = getX(3);
						toScale = _sizeDecay * _sizeDecay * _sizeDecay;
						TweenLite.to(_pictures[i], 0.5, { alpha:1, x:toX, scaleX:toScale, scaleY:toScale } );
						_pictures[i].mouseEnabled = false;
						_pictures[i].filters = _filters;
					}
				}
			}
		}
		
		/**
		 * Correct the index in picture array.
		 * @param	i	the index that will be corrected
		 * @return	the right index in picture array
		 */
		private function correctIndex(i:int):int
		{
			if (i < 0)
			{
				return correctIndex(i + _pictures.length);
			}
			else if(i > _pictures.length - 1)
			{
				return correctIndex(i - _pictures.length);
			}
			else
			{
				return i;
			}
		}
		
		
		/**
		 * page dot.
		 * there is a "PageDot" if this value is not null.
		 */
		public function get pageDot():PageDot 
		{
			return _pageDot;
		}
		public function set pageDot(value:PageDot):void 
		{
			// clear old page dot if it exists
			if (_pageDot) removeChild(_pageDot);
			
			_pageDot = value;
			
			if (_pageDot)
			{
				// set total quantity of dot
				_pageDot.setQuantity(_pictures.length );
				// update current dot
				_pageDot.update(_currentIndex);
				
				// page dot position
				_pageDot.x = (_wheelArea.width - _pageDot.width) / 2;
				_pageDot.y = _wheelArea.height + _pageDot.offset;
				addChild(_pageDot);
			}
		}
		
		/**
		 * Get the area of picture  have taken up.
		 * @return	the area rectangle
		 */
		private function getWheelArea():Rectangle
		{
			var W:uint = _pictureArea.width;
			
			// this size
			var thisW:uint;
			if (_quantity == PictureWheel.QUANTITY_SEVEN)
			{
				thisW = W + (W * _sizeDecay * _distanceDecay * 2) + (W * _sizeDecay * _sizeDecay * _distanceDecay * 2) + (W * _sizeDecay * _sizeDecay * _sizeDecay * _distanceDecay * 2);
			}
			else if (_quantity == PictureWheel.QUANTITY_FIVE)
			{
				thisW = W + (W * _sizeDecay * _distanceDecay * 2) + (W * _sizeDecay * _sizeDecay * _distanceDecay * 2);
			}
			else if (_quantity == PictureWheel.QUANTITY_THREE)
			{
				thisW = W + (W * _sizeDecay * _distanceDecay * 2);
			}
			else	// _quantity == 1
			{
				thisW = W;
			}
			
			var rect:Rectangle = new Rectangle(0, 0, thisW, _pictureArea.height);
			return rect;
		}
		/**
		 * Get x of picture
		 * @param	distance	the distance of middle picture to the target pictue(positive is right side, negative is left side)
		 * @return
		 */
		private function getX(distance:int):int
		{
			// in the middle at beginning
			var X:int = _wheelArea.width / 2;
			
			for (var i:int = 0; i < Math.abs(distance); i++) 
			{
				if (distance < 0)
				{
					X = X - (_pictureArea.width * Math.pow(_sizeDecay, i) * .5) + (_pictureArea.width * Math.pow(_sizeDecay, i + 1) * (.5 - _distanceDecay));
				}
				else
				{
					X = X + (_pictureArea.width * Math.pow(_sizeDecay, i) * .5) - (_pictureArea.width * Math.pow(_sizeDecay, i + 1) * (.5 - _distanceDecay));
				}
				
			}
			
			return X;
		}
		
		/**
		 * standard pictures, and align the middle of the picure to the registration point.
		 * @param	pictures
		 * @param	rect
		 * @param	baseMap
		 * @return	"Sprite Vector"
		 */
		private function standardPictures(pictures:Vector.<Bitmap>, rect:Rectangle, baseMap:Bitmap):Vector.<Sprite> 
		{
			// use pictures[0] size when the rect is null
			if (!rect) rect = new Rectangle(0, 0, pictures[0].width, pictures[0].height);
			
			var standard:Vector.<Sprite> = new Vector.<Sprite>();
			for each (var item:Bitmap in pictures) 
			{
				// container
				var container:Sprite = new Sprite();
				// baseMap
				if (baseMap) container.addChild(baseMap);
				// picture
				var scaleWidth:Number = rect.width / item.width;
				var scaleHeight:Number = rect.height / item.height;
				var scale:Number = Math.min(scaleWidth, scaleHeight);
				item.scaleX = item.scaleY = scale;
				container.addChild(item);
				if (baseMap)
				{
					item.x = (baseMap.width - item.width) / 2;
					item.y = (baseMap.height - item.height) / 2;
				}
				// draw on a bitmap
				var bitmapData:BitmapData = new BitmapData(container.width, container.height, true, 0);
				bitmapData.draw(container);
				var bitmap:Bitmap = new Bitmap(bitmapData);
				
				// align the middle of the picure to the registration point
				container = new Sprite();
				bitmap.x = -bitmap.width / 2;
				bitmap.y = -bitmap.height / 2;
				container.addChild(bitmap);
				
				standard.push(container);
			}
			
			return standard;
		}
		/**
		 * standard "quantity" value
		 * @param	quantity	max quantity of display picture
		 * @return	the right "quantity" value
		 */
		private function standardQuantity(quantity:uint):uint
		{
			// take FIVE if not the three value(3, 5, 7)
			if (quantity != PictureWheel.QUANTITY_THREE && quantity != PictureWheel.QUANTITY_FIVE && quantity != PictureWheel.QUANTITY_SEVEN)
			{
				return standardQuantity(PictureWheel.QUANTITY_FIVE);
			}
			// if picture quantity lager than "quantity"
			else if (quantity > _pictures.length)
			{
				if (quantity == PictureWheel.QUANTITY_SEVEN)
				{
					return standardQuantity(PictureWheel.QUANTITY_FIVE);
				}
				else if (quantity == PictureWheel.QUANTITY_FIVE)
				{
					return standardQuantity(PictureWheel.QUANTITY_THREE);
				}
				else // quantity == PictureWheel.QUANTITY_THREE
				{
					return 1;
				}
			}
			// it's OK if no problem
			else
			{
				return quantity;
			}
		}
		
		/** 被单击的图片在数组中的索引 */
		public function get clickIndex():uint {
			return _clickIndex;
		}
		
		
	}

}