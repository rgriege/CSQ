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
			for(var i:uint = 0; i < 2; i++) {
				icons.push(new Icon(Icon.TYPES[i+offset] as String,15));
				icons[i].x = 7 + (i)*icons[i].width;
				addChild(icons[i]);
			}
		}
	}
}