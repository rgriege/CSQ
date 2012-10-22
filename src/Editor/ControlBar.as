package Editor
{
	import assets.BottomBar;
	
	import flash.display.Sprite;
	
	public class ControlBar extends Sprite
	{
		private var icons:Vector.<Icon>;
		
		public function ControlBar()
		{
			var graphic:Sprite = new BottomBar();
			addChild(graphic);
			
			icons = new Vector.<Icon>();
			var len:uint = Icon.TYPES.length;
			var offset:uint = len-2;
			for(var i:uint = len-2; i < len; i++) {
				icons.push(new Icon(Icon.TYPES[i] as String,15));
				icons[i-offset].x = 7 + (i-offset)*icons[i-offset].width;
				addChild(icons[i-offset]);
			}
		}
	}
}