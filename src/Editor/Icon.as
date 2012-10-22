package Editor
{
	import assets.*;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	public class Icon extends Sprite
	{
		private var hitBox:Sprite;
		private var graphic:Sprite;
		private var highlightBox:HighlightBox;
		public static const DEFAULT_ICON_SIZE:int = 25;
		public static const GAP_RATIO:Number = 2/5;
		public static const DEFAULT_HITBOX_SIZE:int = 40;
		public static const TYPES:Array = ["new","open","save","select","polygon","rectangle","disk","ring",
											"group","move","play","reset"];
		private var type:String;
		
		public function Icon(type:String, size:int=DEFAULT_ICON_SIZE)
		{
			this.type = type;
			hitBox = new Sprite();
			hitBox.graphics.beginFill(0xff0000,0);
			hitBox.graphics.drawRect(0,0,DEFAULT_HITBOX_SIZE,DEFAULT_HITBOX_SIZE);
			addChild(hitBox);
			
			addGraphic(type);
			addChildAt(graphic,0);
			highlightBox = new HighlightBox();
			var factor:Number = size/DEFAULT_ICON_SIZE;
			if(factor != 1.0) {
				graphic.scaleX = factor;
				graphic.scaleY = factor;
				highlightBox.scaleX = factor;
				highlightBox.scaleY = factor;
				hitBox.scaleX = factor;
				hitBox.scaleY = factor;
			}
			graphic.x = (hitBox.width - graphic.width)/2;
			graphic.y = (hitBox.height - graphic.height)/2;
			addEventListener(Event.ADDED_TO_STAGE, added);
		}
		
		// returns true if a graphic was successfully added
		private function addGraphic(type:String):void {
			switch(type) {
				case "new":
					graphic = new NewIcon();
					break;
				case "open":
					graphic = new OpenIcon();
					break;
				case "save":
					graphic = new SaveIcon();
					break;
				case "select":
					graphic = new SelectIcon();
					break;
				case "polygon":
					graphic = new PolygonIcon();
					break;
				case "rectangle":
					graphic = new RectangleIcon();
					break;
				case "disk":
					graphic = new DiskIcon();
					break;
				case "ring":
					graphic = new RingIcon();
					break;
				case "group":
					graphic = new GroupIcon();
					break;
				case "move":
					graphic = new MoveIcon();
					break;
				case "play":
					graphic = new PlayIcon();
					break;
				case "reset":
					graphic = new ResetIcon();
					break;
			}
		}
		
		private function added(evt:Event):void {
			removeEventListener(Event.ADDED_TO_STAGE, added);
			hitBox.addEventListener(MouseEvent.MOUSE_OVER, highlight);
			hitBox.addEventListener(MouseEvent.MOUSE_OUT, normalize);
			hitBox.addEventListener(MouseEvent.MOUSE_UP, released);
			addEventListener(Event.REMOVED_FROM_STAGE, removed);
		}
		
		private function highlight(evt:MouseEvent):void {
			if(!this.contains(highlightBox))
				addChildAt(highlightBox, 0);
		}
		
		private function released(evt:MouseEvent):void {
			dispatchEvent(new ToolSelectedEvent(ToolSelectedEvent.EVENT, type));
		}
		
		private function normalize(evt:MouseEvent):void {
			if(this.contains(highlightBox))
				removeChild(highlightBox);
		}
		
		private function removed(evt:Event):void {
			if(hitBox.hasEventListener(MouseEvent.MOUSE_OVER))
				hitBox.removeEventListener(MouseEvent.MOUSE_OVER, highlight);
			else if(hitBox.hasEventListener(MouseEvent.MOUSE_OUT))
				hitBox.removeEventListener(MouseEvent.MOUSE_OUT, normalize);
			addEventListener(Event.ADDED_TO_STAGE, added);
		}
	}
}